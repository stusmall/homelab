#!/bin/sh

wait_for() {
  local desc="$1"
  shift
  echo "Waiting for $desc..."
  until "$@"; do
    sleep 5
    echo "trying again"
  done
  echo "$desc ready."
}

kubectl create ns keycloak-advanced

kubectl create secret generic keycloak-db-credentials \
    --from-literal=password="$(openssl rand -base64 24)" \
    --from-literal=postgres-password="$(openssl rand -base64 24)" \
    --namespace=keycloak-advanced

argocd login --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) --insecure localhost:8443
argocd app create apps --dest-server https://kubernetes.default.svc --repo https://github.com/stusmall/homelab.git --path helm
argocd app sync apps
# might need to add a second sync since things seems to be getting caught up on CRDs
wait_for "kibana" kubectl rollout status deployment --namespace elastic kibana-kb
