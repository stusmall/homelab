#!/bin/sh

LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube start --cpus='4' -m 24gb --disk-size=80g --extra-config=kubeadm.skip-phases=addon/kube-proxy --driver kvm2
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube ssh 'echo "sysctl -w vm.max_map_count=262144" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' # needed because https://github.com/kubernetes/minikube/issues/2367
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube ssh 'echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' # Cleans out some hubble noise
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube stop
LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube start --cpus='4' -m 24gb --disk-size=80g --extra-config=kubeadm.skip-phases=addon/kube-proxy --driver kvm2

LD_PRELOAD=$(nix-store -q $(which virsh))/lib/libvirt.so.0 minikube tunnel
