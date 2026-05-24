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

minikube start --extra-config=kubeadm.skip-phases=addon/kube-proxy --host-only-cidr="192.168.99.100/24"
minikube ssh 'echo "sysctl -w vm.max_map_count=262144" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' # needed because https://github.com/kubernetes/minikube/issues/2367
minikube stop --extra-config=kubeadm.skip-phases=addon/kube-proxy --host-only-cidr="192.168.99.100/24"
minikube start
helm install cilium cilium/cilium \
  --namespace kube-system \
  --version 1.19.4 \
  --set k8sServiceHost=192.168.99.100 \
  --set k8sServicePort=8443 \
  --set operator.replicas=1 \
  --set kubeProxyReplacement=true \
  --set ingressController.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true
wait_for "cilium" kubectl rollout status deployment --namespace kube-system cilium-operator
helm install argocd argo/argo-cd --namespace argocd  --create-namespace
kubectl apply -f helm/templates/argocd.yaml
wait_for "argocd" kubectl rollout status deployment --namespace argocd argocd-server
kubectl port-forward -n argocd services/argocd-server 8443:443
#kubectl port-forward --namespace elastic  service/kibana-kb-http 5601 &
#kubectl get secrets --namespace elastic elastic-cluster-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode
