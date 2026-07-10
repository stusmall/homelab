terraform {

  required_version = ">= 1.2"

  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~> 0.16"
    }
  }
}

provider "elasticstack" {
  elasticsearch {
  }
}
