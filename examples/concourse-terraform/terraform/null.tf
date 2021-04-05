variable "env_name" {
  type        = string
  description = "Name of environment."
}

data "null_data_source" "values" {
  inputs = {
    env_name = var.env_name
  }
}

resource "null_resource" "cluster" {
}

output "env_name" {
  value = data.null_data_source.values.outputs["env_name"]
}
