terraform {

  required_version = ">= 1.2"

  required_providers {
    # elasticstack = {
    #   source  = "elastic/elasticstack"
    #   version = "~> 0.16"
    # }

    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# provider "elasticstack" {
#   elasticsearch {
#     endpoints = ["https://localhost:9200"]
#     api_key   = "SkpCSFZwOEJDbmtfUUlUYm5RQy06b1pqeXR6QkxPVVlBNGExSENVY0pqdw=="
#     insecure  = true
#   }
# }

# resource "elasticstack_elasticsearch_data_stream_lifecycle" "metrics_data_streams" {
#   name           = "metrics-*"
#   data_retention = "7d"
# }

provider "kubernetes" {
  config_path = "~/.kube/config"
}


provider "keycloak" {
  client_id = "admin-cli"
  username  = var.keycloak_admin_user
  password  = var.keycloak_admin_password
  url       = var.keycloak_url
}

variable "keycloak_url" {}
variable "keycloak_admin_user" {}
variable "keycloak_admin_password" {
  sensitive = true
}

resource "keycloak_realm" "this" {
  realm        = "standard-realm"
  enabled      = true
  ssl_required = "none" # TODO: change this once I have proper certs
}


resource "keycloak_openid_client" "argocd" {
  realm_id              = keycloak_realm.this.id
  client_id             = "argocd"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  valid_redirect_uris   = ["http://argocd.thenoodledragonlair.com/auth/callback"] # TODO: change this once I have proper certs
  web_origins           = ["http://argocd.thenoodledragonlair.com"]               # TODO: change this once I have proper certs
}

resource "kubernetes_secret_v1" "argocd_oidc_secret" {
  metadata {
    name      = "argocd-oidc-secret"
    namespace = "argocd"
  }
  data = {
    clientSecret = keycloak_openid_client.argocd.client_secret
  }
}
