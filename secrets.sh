#!/bin/sh
ARGO_PW=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
KEYCLOAK_PW=$( kubectl -n keycloak get secret keycloak -o jsonpath="{.data.admin-password}" | base64 -d)
ELASTIC_PW=$(kubectl get secret -n elastic elastic-cluster-es-elastic-user -o jsonpath='{.data.elastic}' | base64 -d)
echo "ArgoCD admin: $ARGO_PW"
echo "Keycloak admin: $KEYCLOAK_PW"
echo "Elastic admin: $ELASTIC_PW"
