#!/bin/sh
kubectl port-forward -n argocd services/argocd-server 8443:443
