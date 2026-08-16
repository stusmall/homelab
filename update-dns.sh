#!/usr/bin/env bash
set -euo pipefail

# Config
INGRESS_IP="10.100.191.117"
HOSTNAMES="keycloak.thenoodledragonlair.com argocd.thenoodledragonlair.com"
ANCHOR="192.168.39.1 host.minikube.internal"

# Fetch current Corefile
CURRENT=$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}')

# Insert our entry right after the existing hosts anchor line
UPDATED=$(echo "$CURRENT" | sed "s|${ANCHOR}|${ANCHOR}\n       ${INGRESS_IP} ${HOSTNAMES}|")

# Write it to a temp file so kubectl can load it cleanly
TMPFILE=$(mktemp)
echo "$UPDATED" > "$TMPFILE"

# Apply the updated Corefile
kubectl -n kube-system create configmap coredns \
  --from-file=Corefile="$TMPFILE" \
  --dry-run=client -o yaml | kubectl apply -f -

rm "$TMPFILE"

# Restart CoreDNS to pick up the change
kubectl -n kube-system rollout restart deployment coredns

echo "Done. CoreDNS now resolves: $HOSTNAMES -> $INGRESS_IP"
