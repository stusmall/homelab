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

resource "elasticstack_elasticsearch_index" "my_index" {
  name = "my-index"

  alias = [{
    name = "my_alias_1"
    }, {
    name = "my_alias_2"
    filter = jsonencode({
      term = { "user.id" = "developer" }
    })
  }]

  mappings = jsonencode({
    properties = {
      field1 = { type = "keyword" }
      field2 = { type = "text" }
      field3 = {
        properties = {
          inner_field1 = { type = "text", index = false }
          inner_field2 = { type = "integer", index = false }
        }
      }
    }
  })

  number_of_shards   = 1
  number_of_replicas = 1
  search_idle_after  = "20s"
}
