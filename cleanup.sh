#!/bin/sh
kubectl delete namespaces argocd
kubectl delete customresourcedefinitions.apiextensions.k8s.io applications.argoproj.io
kubectl delete customresourcedefinitions.apiextensions.k8s.io applicationsets.argoproj.io
kubectl delete customresourcedefinitions.apiextensions.k8s.io appprojects.argoproj.io
