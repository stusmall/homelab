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
    --namespace argocd  --create-namespace
kubectl apply -f helm/templates/argocd.yaml
wait_for "argocd" kubectl rollout status deployment --namespace argocd argocd-server
kubectl port-forward -n argocd services/argocd-server 8443:443
