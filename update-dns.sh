#!/usr/bin/env bash
set -euo pipefail

# Config
INGRESS_NAMESPACE="keycloak"
INGRESS_SERVICE="cilium-ingress-keycloak-ingress"
HOSTNAMES="keycloak.thenoodledragonlair.com argocd.thenoodledragonlair.com"

# Fetch ingress ClusterIP dynamically
INGRESS_IP=$(kubectl -n "$INGRESS_NAMESPACE" get service "$INGRESS_SERVICE" -o jsonpath='{.spec.clusterIP}')

if [[ -z "$INGRESS_IP" ]]; then
  echo "Failed to resolve ClusterIP for $INGRESS_SERVICE in $INGRESS_NAMESPACE" >&2
  exit 1
fi

# Fetch current Corefile
CURRENT=$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}')

# Insert our entry right after the "hosts {" block opener, not tied to any existing IP line
UPDATED=$(echo "$CURRENT" | sed "s|hosts {|hosts {\n       ${INGRESS_IP} ${HOSTNAMES}|")

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
