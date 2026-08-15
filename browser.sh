chromium \
    --host-resolver-rules="MAP argocd.thenoodledragonlair.com $(kubectl get ingress -n argocd agrocd-ingress  -o jsonpath="{.status.loadBalancer.ingress[0].ip}")" \
    --host-resolver-rules="MAP keycloak.thenoodledragonlair.com $(kubectl get ingress -n keycloak keycloak-ingress  -o jsonpath="{.status.loadBalancer.ingress[0].ip}")"
