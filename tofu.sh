# kubectl port-forward -n keycloak services/keycloak 8080:80
pushd terraform
TF_VAR_keycloak_url=http://localhost:8080 TF_VAR_keycloak_admin_user=user  TF_VAR_keycloak_admin_password=$( kubectl -n keycloak get secret keycloak -o jsonpath="{.data.admin-password}" | base64 -d) tofu apply
