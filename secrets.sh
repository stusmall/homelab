#!/bin/sh
ARGO_PW=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
KEYCLOAK_PW=$( kubectl -n keycloak-advanced get secret my-keycloak-advanced -o jsonpath="{.data.admin-password}" | base64 -d)
echo "ArgoCD admin: $ARGO_PW"
echo "Keycloak admin: $KEYCLOAK_PW"
