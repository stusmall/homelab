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
    endpoints = ["https://localhost:9200"]
    api_key   = "SkpCSFZwOEJDbmtfUUlUYm5RQy06b1pqeXR6QkxPVVlBNGExSENVY0pqdw=="
    insecure  = true
  }
}

resource "elasticstack_elasticsearch_data_stream_lifecycle" "metrics_data_streams" {
  name           = "metrics-*"
  data_retention = "7d"
}
