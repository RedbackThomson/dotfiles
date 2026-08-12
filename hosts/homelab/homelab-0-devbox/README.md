# homelab-0-devbox

Remote NixOS development VM on Proxmox, reached over Tailscale. Editing,
running projects, and running Claude Code all happen here; long-running agent
sessions survive client disconnects via a persistent zellij session.

- Arch: `x86_64-linux`
- Tailnet tag: `tag:devbox`
- LAN address: `192.168.1.154` (from `vars/networking.nix`)
- Disks: `/dev/sda` = OS + Nix store; `/dev/sdb` = `/work` (user work trees, service state)

## One-time setup before the first deploy

The Tailscale join key, git push key, and gh token are agenix secrets. agenix
decrypts them with an age identity derived from the host's own SSH key, so the
host's key must be a recipient in the `dotfiles-secrets` repo, and the `.age`
files must exist there.

1. Create and boot the VM (see below) so it has an SSH host key.
2. Derive its age public key and add it as a recipient, then create the secrets
   in the `redbackthomson/dotfiles-secrets` repo:
   - `secrets/devbox/tailscale-authkey.age`: a **reusable** Tailscale auth key
     (Admin console → Settings → Keys), ideally pre-tagged `tag:devbox`.
   - `secrets/devbox/git-key.age`: the **private** half of a new ed25519 key.
     Add the **public** half to GitHub as an SSH key.
   - `secrets/devbox/gh-token.age`: a GitHub token for `gh` / Claude Code.
3. Bump the `mysecrets` input: `nix flake update mysecrets`.

Until this is done the host builds and evaluates, but activation fails when
agenix cannot find or decrypt the files.

## Build the image

`nixos-generators` is wired into every NixOS host via `all-formats`, so a
Proxmox image comes straight off this config:

```bash
nix build .#nixosConfigurations.homelab-0-devbox.config.formats.proxmox
```

Import the resulting VMA into Proxmox, or provision a blank VM and install with
your usual disko-based flow. Give the VM **two virtio disks**. The second one
becomes `/work` and must not be the boot disk. Enable the QEMU guest agent in
the VM options. Nothing else is manual.

VM sizing (CPU/RAM/disk) is not encoded in this repo; set it in Proxmox to suit
the workload.

## Deploy

Deploys go over SSH with colmena (builds on the target, so an aarch64 Mac can
deploy this x86_64 host):

```bash
nix run .#colmena -- apply --on homelab-0-devbox
```

(Or `--on @devbox` to select by the tailnet tag.)

colmena connects to the LAN address as `root`. OpenSSH is bound to the LAN
address only, so this path does not depend on Tailscale being up.

## Reach the host

After a cold boot the node joins the tailnet unattended and Tailscale SSH owns
port 22 on the tailnet address:

```bash
ssh nicholasthomson@homelab-0-devbox
```

Break-glass, if Tailscale is unhealthy: SSH to the LAN address `192.168.1.154`,
or use the Proxmox serial console (the VM is configured for `ttyS0`).

## Attach to the persistent session

An interactive SSH login drops straight into the `main` zellij session
(auto-attach-or-create). To reattach by hand from any shell:

```bash
za
```

`za` is an alias for `zellij attach --create main`. A process started here keeps
running when the client sleeps or drops off the network; reconnecting reattaches
to it.

## Expose a dev server on the tailnet

The firewall trusts the `tailscale0` interface and blocks the LAN, so any dev
server bound to the tailnet (or `0.0.0.0`) is reachable from other tailnet
devices, with no editor tunnel needed. Bind to `0.0.0.0`, not loopback, and if
the dev server rejects unknown `Host` headers, allow the MagicDNS name.

- **Plain HTTP**: start the server on a port, then browse to
  `http://homelab-0-devbox:PORT` from any tailnet device.
- **TLS** under the host's tailnet name (for secure cookies, service workers,
  OAuth callbacks, webhooks). This requires HTTPS enabled for the tailnet in the
  admin console, then:

  ```bash
  tailscale serve --bg 3000
  ```

  This serves `https://homelab-0-devbox.<tailnet>.ts.net` with a trusted cert.
  `permitCertUid` lets the primary user run this without root.

Public internet ingress stays off. `tailscale funnel` would enable it and is
opt-in per service. Do not enable it by default.
