#!/bin/sh
kubectl port-forward -n keycloak-advanced services/my-keycloak-advanced 8080:80
