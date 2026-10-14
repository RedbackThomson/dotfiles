if [[ $# -ne 1 ]]; then
  echo "usage: vcluster-shell <namespace>" >&2
  exit 1
fi
namespace=$1
host_context=$(kubectl config current-context)

# vcluster stores its admin kubeconfig in secret vc-<name> and serves the API on service <name>.
secret=$(kubectl -n "$namespace" get secrets \
  -o jsonpath='{range .items[?(@.data.config)]}{.metadata.name}{"\n"}{end}' |
  grep -m1 '^vc-' || true)
if [[ -z $secret ]]; then
  echo "no vcluster kubeconfig secret (vc-*) found in namespace $namespace" >&2
  exit 1
fi
service=${secret#vc-}

remote_port=$(kubectl -n "$namespace" get service "$service" \
  -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
remote_port=${remote_port:-443}

tmpdir=${TMPDIR:-/tmp}
tmp=$(mktemp -d "${tmpdir%/}/vcluster-shell.XXXXXX")
pf_pid=""
cleanup() {
  if [[ -n $pf_pid ]]; then
    kill "$pf_pid" 2>/dev/null || true
  fi
  rm -rf "$tmp"
}
trap cleanup EXIT

# Port 0 lets kubectl pick a free local port, so several vcluster shells can run side by side.
log=$tmp/port-forward.log
kubectl -n "$namespace" port-forward "service/$service" ":$remote_port" >"$log" 2>&1 &
pf_pid=$!

local_port=""
for _ in $(seq 50); do
  local_port=$(sed -n 's/^Forwarding from 127\.0\.0\.1:\([0-9]*\) .*/\1/p' "$log" | head -n1)
  if [[ -n $local_port ]] || ! kill -0 "$pf_pid" 2>/dev/null; then
    break
  fi
  sleep 0.2
done
if [[ -z $local_port ]]; then
  echo "port-forward to service/$service in $namespace failed:" >&2
  cat "$log" >&2
  exit 1
fi

kubeconfig=$tmp/kubeconfig
kubectl -n "$namespace" get secret "$secret" -o jsonpath='{.data.config}' | base64 -d >"$kubeconfig"
cluster=$(KUBECONFIG=$kubeconfig kubectl config view -o jsonpath='{.clusters[0].name}')
KUBECONFIG=$kubeconfig kubectl config set-cluster "$cluster" --server="https://localhost:$local_port" >/dev/null
KUBECONFIG=$kubeconfig kubectl config rename-context \
  "$(KUBECONFIG=$kubeconfig kubectl config current-context)" "$host_context/$namespace" >/dev/null

echo "Port-forwarded vcluster running in namespace $namespace (localhost:$local_port, pid $pf_pid). Exit the shell to stop."
KUBECONFIG=$kubeconfig VCLUSTER_NAMESPACE=$namespace "${SHELL:-zsh}" || true
