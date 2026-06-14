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

LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0  minikube start --extra-config=kubeadm.skip-phases=addon/kube-proxy --driver kvm2
minikube ssh 'echo "sysctl -w vm.max_map_count=262144" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' # needed because https://github.com/kubernetes/minikube/issues/2367
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0  minikube stop --extra-config=kubeadm.skip-phases=addon/kube-proxy
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0  minikube start --extra-config=kubeadm.skip-phases=addon/kube-proxy
helm install cilium cilium/cilium \
  --namespace kube-system \
  --version 1.19.4 \
  --set k8sServiceHost=127.0.0.1 \
  --set k8sServicePort=8443 \
  --set operator.replicas=1 \
  --set kubeProxyReplacement=true \
  --set ingressController.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true
wait_for "cilium" kubectl rollout status deployment --namespace kube-system cilium-operator
wait_for "cilium network policy crd" kubectl get customresourcedefinitions.apiextensions.k8s.io ciliumnetworkpolicies.cilium.io
wait_for "cilium cluster wide network policy crd"  kubectl get customresourcedefinitions.apiextensions.k8s.io ciliumclusterwidenetworkpolicies.cilium.io
kubectl apply -f helm/templates/cilium-clusterwide-policies.yaml
helm install argocd argo/argo-cd --namespace argocd  --create-namespace
kubectl apply -f helm/templates/argocd.yaml
kubectl apply -f helm/templates/argocd-network-policies.yaml
wait_for "argocd" kubectl rollout status deployment --namespace argocd argocd-server
kubectl port-forward -n argocd services/argocd-server 8443:443
