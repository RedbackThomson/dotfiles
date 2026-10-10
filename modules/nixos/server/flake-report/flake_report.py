"""Preview what `nix flake update` would change on each NixOS host and post it
to the homelab dashboard.

For every host it builds the system the host is running (its deployed
revision, rebuilt from git) and the system main would produce with an updated
lock, then diffs the two closures. Builds are reproducible, so nothing has to
be copied off the hosts.
"""

import json
import os
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

REPO_URL = os.environ.get("REPO_URL", "https://github.com/redbackthomson/dotfiles.git")
GITHUB_REPO = os.environ.get("GITHUB_REPO", "redbackthomson/dotfiles")
VM_URL = os.environ.get("VM_URL", "https://metrics.tailb0b05.ts.net")
DASHBOARD_URL = os.environ.get("DASHBOARD_URL", "https://dashboard.tailb0b05.ts.net")
# Resolved because DynamicUser makes the state directory a symlink into
# /var/lib/private, and Nix refuses git+file:// paths that pass through one.
STATE = Path(os.environ.get("STATE_DIRECTORY", "/var/lib/flake-report")).resolve()
CREDENTIALS = Path(os.environ.get("CREDENTIALS_DIRECTORY", "/run/credentials"))

# Parts of a system whose change only takes effect after a reboot.
REBOOT_PARTS = ["kernel", "initrd", "kernel-modules", "systemd"]
# Derivations that are the system's own plumbing rather than packages.
PLUMBING = re.compile(r"^(nixos-system|etc|unit-|system-|X-|activate|boot\.json|users-groups|"
                      r"initrd|dbus-|NetworkManager-|udev-|extra-utils|perl-.*-env|man-paths|"
                      r"home-manager-|hm_|nixos-manual|source$)")
ANSI = re.compile(r"\x1b\[[0-9;]*m")
DIFF_LINE = re.compile(r"^(?P<name>[^:]+): (?P<from>.+?) → (?P<to>.+?)(?:, (?P<size>[+-][\d.]+ \w+))?$")
STORE_REF = re.compile(r"/nix/store/[a-z0-9]{32}-([^/\s\"']+)")


def log(msg):
    print(msg, file=sys.stderr, flush=True)


def run(*args, cwd=None):
    proc = subprocess.run(args, cwd=cwd, text=True, capture_output=True)
    if proc.returncode != 0:
        log(f"{' '.join(args)} failed:\n{proc.stderr[-4000:]}")
        proc.check_returncode()
    return proc.stdout.strip()


def credential(name):
    path = CREDENTIALS / name
    return path.read_text().strip() if path.exists() else ""


def http_json(url, token="", data=None):
    headers = {"Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    body = None
    if data is not None:
        body = json.dumps(data).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, headers=headers)
    with urllib.request.urlopen(req, timeout=30) as resp:
        raw = resp.read()
        return json.loads(raw) if raw else None


def iso(epoch):
    return datetime.fromtimestamp(epoch, timezone.utc).isoformat() if epoch else None


# ---- Sources ----

def sync_repo():
    repo = STATE / "dotfiles"
    if (repo / ".git").exists():
        run("git", "fetch", "--quiet", "origin", cwd=repo)
    else:
        run("git", "clone", "--quiet", REPO_URL, str(repo))
    return repo, run("git", "rev-parse", "origin/main", cwd=repo)


def deployed_revisions():
    """host → revision currently active, as each host reports to node_exporter."""
    try:
        result = http_json(f"{VM_URL}/api/v1/query?query=nixos_system_info")
    except (urllib.error.URLError, TimeoutError) as e:
        log(f"cannot read deployed revisions: {e}")
        return {}
    return {r["metric"]["host"]: r["metric"].get("revision", "") for r in result["data"]["result"]}


def updated_checkout(repo, head):
    """A copy of main with every input updated, which is what `nix flake update` would produce."""
    path = STATE / "updated"
    shutil.rmtree(path, ignore_errors=True)
    run("git", "clone", "--quiet", "--shared", str(repo), str(path))
    run("git", "checkout", "--quiet", "--detach", head, cwd=path)
    run("nix", "flake", "update", cwd=path)
    return path


def build(flake_ref, host):
    """Returns (store path, None) or (None, a one-line reason the build failed)."""
    attr = f"{flake_ref}#nixosConfigurations.{host}.config.system.build.toplevel"
    # One derivation at a time keeps the peak low: the Proxmox node has no
    # memory to spare for parallel builds.
    proc = subprocess.run(["nix", "build", "--no-link", "--print-out-paths", "--max-jobs", "1", "--cores", "2", attr],
                          text=True, capture_output=True)
    if proc.returncode != 0:
        log(f"build failed: {attr}\n{proc.stderr[-2000:]}")
        return None, build_error(proc.stderr)
    return proc.stdout.strip(), None


def build_error(stderr):
    """The line of a failed build's output that says what to fix, rather than its consequences."""
    text = ANSI.sub("", stderr)
    lines = [line.strip() for line in text.splitlines()]
    for i, line in enumerate(lines):
        if line.startswith("Failed assertions:") and i + 1 < len(lines):
            return lines[i + 1].lstrip("- ")
    if m := re.search(r"error: (attribute '[^']+' missing)", text):
        return m[1]
    # The derivation whose builder failed is the cause; the "Cannot build" lines
    # that follow are the systems depending on it.
    for pattern in (r"builder for '/nix/store/[a-z0-9]{32}-([^']+)\.drv' failed",
                    r"nix log /nix/store/[a-z0-9]{32}-(\S+)\.drv",
                    r"Cannot build '/nix/store/[a-z0-9]{32}-([^']+)\.drv'"):
        if m := re.search(pattern, text):
            return f"{m[1]} failed to build"
    errors = [line for line in lines if line.startswith("error:")]
    return (errors[-1] if errors else "build failed")[:300]


# ---- Diffs ----

def version_kind(old, new):
    if old == "∅":
        return "added"
    if new == "∅":
        return "removed"
    a, b = re.split(r"[.\-+]", old.split(", ")[-1]), re.split(r"[.\-+]", new.split(", ")[-1])
    if a[0] != b[0]:
        return "major"
    if len(a) > 1 and len(b) > 1 and a[1] != b[1]:
        return "minor"
    return "patch"


def closure_size(path):
    info = json.loads(run("nix", "path-info", "--json", "--closure-size", path))
    # The JSON shape changed between Nix releases: a list of objects, or an object keyed by path.
    entry = info[0] if isinstance(info, list) else next(iter(info.values()))
    return entry.get("closureSize", 0)


def changed_units(old, new):
    """Units whose files differ; switch-to-configuration restarts these."""
    units = {}
    new_dir, old_dir = Path(new, "etc/systemd/system"), Path(old, "etc/systemd/system")
    for unit in sorted(new_dir.glob("*.service")):
        if "@" in unit.name or not unit.is_file():
            continue
        before = old_dir / unit.name
        if before.exists() and before.resolve() == unit.resolve():
            continue
        units[unit.name] = set(STORE_REF.findall(unit.read_text(errors="ignore")))
    return units


def diff_host(host, old, new):
    entry = {"name": host, "buildOk": True, "upgraded": 0, "added": 0, "removed": 0, "packages": []}
    reboot = any(Path(old, p).resolve() != Path(new, p).resolve() for p in REBOOT_PARTS)
    units = changed_units(old, new)

    for line in ANSI.sub("", run("nix", "store", "diff-closures", old, new)).splitlines():
        m = DIFF_LINE.match(line.strip())
        if not m or PLUMBING.match(m["name"]):
            continue
        kind = version_kind(m["from"], m["to"])
        entry["upgraded" if kind not in ("added", "removed") else kind] += 1
        impact = "none"
        if reboot and m["name"] in ("linux", "systemd"):
            impact = "reboot"
        else:
            for unit, refs in units.items():
                if any(ref.startswith(m["name"] + "-") for ref in refs):
                    impact = f"restart {unit}"
                    break
        entry["packages"].append({"name": m["name"], "from": m["from"], "to": m["to"], "kind": kind, "impact": impact})

    rank = {"reboot": 0}
    entry["packages"].sort(key=lambda p: (rank.get(p["impact"], 1 if p["impact"] != "none" else 2), p["name"]))
    entry["total"] = len(entry["packages"])
    entry["reboot"] = reboot
    entry["restarts"] = sorted(units)
    entry["closureDelta"] = closure_size(new) - closure_size(old)
    return entry


# ---- Inputs ----

def input_report(old_lock, new_lock, token):
    nodes, new_nodes = old_lock["nodes"], new_lock["nodes"]
    out = []
    for name, node_id in sorted(nodes["root"]["inputs"].items()):
        if isinstance(node_id, list):  # follows another input
            continue
        node, new = nodes[node_id], new_nodes.get(node_id, {})
        locked, original = node.get("locked", {}), node.get("original", {})
        new_locked = new.get("locked", {})
        entry = {
            "name": name,
            "ref": original.get("ref") or original.get("rev", "")[:12] or original.get("url", "default branch"),
            "locked": locked.get("rev") or locked.get("narHash", ""),
            "lockedDate": iso(locked.get("lastModified")),
            "latest": new_locked.get("rev") or new_locked.get("narHash", ""),
            "latestDate": iso(new_locked.get("lastModified")),
            "behind": 0,
            "status": "current",
        }
        github = locked.get("type") == "github"
        repo = f"{locked.get('owner')}/{locked.get('repo')}"
        if "rev" in original:
            entry["status"] = "pinned"
        elif github and re.match(r"^v?\d", original.get("ref", "")):
            # A tag only moves when edited by hand, so look for a newer release instead.
            entry["status"] = "pinned"
            try:
                tag = http_json(f"https://api.github.com/repos/{repo}/releases/latest", token)["tag_name"]
                if tag != original["ref"]:
                    entry.update(status="newer-tag", latest=tag, latestDate=None)
            except (urllib.error.URLError, KeyError, TypeError):
                pass
        elif entry["latest"] != entry["locked"]:
            entry["status"] = "behind"
            if github:
                try:
                    cmp = http_json(f"https://api.github.com/repos/{repo}/compare/{entry['locked']}...{entry['latest']}", token)
                    entry["behind"] = cmp["ahead_by"]
                except (urllib.error.URLError, KeyError, TypeError):
                    entry["behind"] = None
            else:
                entry["behind"] = None
        out.append(entry)
    return out


def announce_start(ingest):
    """Tell the dashboard a run is under way, so its Flake page shows it as running."""
    if not ingest:
        return
    try:
        http_json(f"{DASHBOARD_URL}/api/flake/started", ingest, {})
    except (urllib.error.URLError, TimeoutError) as e:
        log(f"could not tell the dashboard the run started: {e}")


def main():
    STATE.mkdir(parents=True, exist_ok=True)
    announce_start(credential("ingest-token"))
    gh_token = credential("github-token")
    if gh_token:
        # Nix resolves github: inputs through the API, whose unauthenticated
        # limit is shared by every machine behind the house's public IP.
        os.environ["NIX_CONFIG"] = f"access-tokens = github.com={gh_token}\n" + os.environ.get("NIX_CONFIG", "")
    repo, head = sync_repo()
    log(f"main is {head[:7]}")
    hosts = json.loads(run("nix", "eval", "--json", f"git+file://{repo}?rev={head}#nixosConfigurations",
                           "--apply", "builtins.attrNames"))
    deployed = deployed_revisions()
    updated = updated_checkout(repo, head)

    report = {"generatedAt": datetime.now(timezone.utc).isoformat(), "main": head, "buildOk": True, "hosts": []}
    for host in hosts:
        rev = deployed.get(host, "")
        # A host that is stopped, dirty or running an unpushed commit is
        # compared against main as it stands.
        known = re.fullmatch(r"[0-9a-f]{40}", rev or "") and subprocess.run(
            ["git", "cat-file", "-e", f"{rev}^{{commit}}"], cwd=repo, capture_output=True).returncode == 0
        base = rev if known else head
        log(f"{host}: deployed {rev[:7] or 'unknown'}, comparing from {base[:7]}")
        old, old_err = build(f"git+file://{repo}?rev={base}", host)
        new, new_err = build(f"git+file://{updated}", host)
        if not old or not new:
            report["buildOk"] = False
            error = f"current system: {old_err}" if old_err else f"after update: {new_err}"
            report["hosts"].append({"name": host, "buildOk": False, "base": base, "error": error, "packages": [], "total": 0})
            continue
        entry = diff_host(host, old, new)
        entry["base"] = base
        entry["baseIsDeployed"] = bool(known)
        report["hosts"].append(entry)

    old_lock = json.loads(run("git", "show", f"{head}:flake.lock", cwd=repo))
    new_lock = json.loads((updated / "flake.lock").read_text())
    report["inputs"] = input_report(old_lock, new_lock, gh_token)

    ingest = credential("ingest-token")
    if not ingest:
        print(json.dumps(report, indent=2))
        log("no ingest token; printed the report instead of posting it")
        return
    http_json(f"{DASHBOARD_URL}/api/reports/flake", ingest, report)
    log(f"posted report: {sum(h['total'] for h in report['hosts'])} package changes across {len(hosts)} hosts")


if __name__ == "__main__":
    main()
