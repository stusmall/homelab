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

helm install cilium oci://helm.mini.dev/cilium \
  --namespace kube-system \
  --set cilium.k8sServiceHost=127.0.0.1 \
  --set cilium.k8sServicePort=8443 \
  --set cilium.operator.replicas=1 \
  --set cilium.kubeProxyReplacement=true \
  --set cilium.ingressController.enabled=true \
  --set cilium.hubble.relay.enabled=true \
  --set cilium.hubble.ui.enabled=true
wait_for "cilium" kubectl rollout status deployment --namespace kube-system cilium-operator
wait_for "cilium network policy crd" kubectl get customresourcedefinitions.apiextensions.k8s.io ciliumnetworkpolicies.cilium.io
wait_for "cilium cluster wide network policy crd"  kubectl get customresourcedefinitions.apiextensions.k8s.io ciliumclusterwidenetworkpolicies.cilium.io
kubectl apply -f helm/templates/cilium-clusterwide-policies.yaml
kubectl create namespace argocd
kubectl apply -f helm/templates/argocd-network-policies.yaml
helm install argocd oci://helm.mini.dev/argo-cd \
    --namespace argocd  --create-namespace \
    --set argo-cd.configs.params."server\.insecure"=true
kubectl apply -f helm/templates/argocd.yaml
wait_for "argocd" kubectl rollout status deployment --namespace argocd argocd-server


kubectl create ns keycloak
kubectl create secret generic keycloak-db-credentials \
    --from-literal=password="$(openssl rand -base64 24)" \
    --from-literal=postgres-password="$(openssl rand -base64 24)" \
    --namespace=keycloak

kubectl apply -f minikube.yaml

wait_for "kibana" kubectl rollout status deployment --namespace elastic kibana-kb
# curl -kv --resolve argocd.thenoodledragonlair.com:443:$( kubectl get ingress -n argocd agrocd-ingress  -o jsonpath="{.status.loadBalancer.ingress[0].ip}")  https://argocd.thenoodledragonlair.com
