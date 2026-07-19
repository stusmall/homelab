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

add_secret_to_namespace() {
    kubectl create namespace $@
    kubectl create secret --namespace $@ docker-registry helm-pull-secret \
      --docker-server=dhi.io \
      --docker-username=$DOCKER_USERNAME \
      --docker-password=$DOCKER_PAT \
      --docker-email=$DOCKER_EMAIL
}

LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube start --cpus='4' -m 24gb --extra-config=kubeadm.skip-phases=addon/kube-proxy --driver kvm2
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube ssh 'echo "sysctl -w vm.max_map_count=262144" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' # needed because https://github.com/kubernetes/minikube/issues/2367
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube stop
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube start --cpus='4' -m 24gb --extra-config=kubeadm.skip-phases=addon/kube-proxy --driver kvm2

#Load in secrets
source .env

add_secret_to_namespace argocd
add_secret_to_namespace elastic
add_secret_to_namespace cert-manager
add_secret_to_namespace kube-system
add_secret_to_namespace trivy

helm install cilium oci://quay.io/cilium/charts/cilium \
  --namespace kube-system \
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

kubectl apply -f helm/templates/argocd-network-policies.yaml
helm install argocd oci://dhi.io/argocd-chart \
    --namespace argocd  --create-namespace \
    --set global.imagePullSecrets[0].name=helm-pull-secret
kubectl apply -f helm/templates/argocd.yaml
wait_for "argocd" kubectl rollout status deployment --namespace argocd argocd-server
kubectl port-forward -n argocd services/argocd-server 8443:443
