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

#Load in secrets
source .env

argocd login --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) --insecure localhost:8443
argocd repo add dhi.io   --type helm   --name dhi   --enable-oci   --username $DOCKER_USERNAME   --password $DOCKER_PAT
argocd app create apps --dest-server https://kubernetes.default.svc --repo https://github.com/stusmall/homelab.git --path helm
argocd app sync apps
# might need to add a second sync since things seems to be getting caught up on CRDs
wait_for "kibana" kubectl rollout status deployment --namespace elastic kibana-kb
