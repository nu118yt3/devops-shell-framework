terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
resource "local_file" "framework_info" {
  filename = "${path.module}/framework-info.txt"
  content  = "Framework DevOps inicial creado con Terraform en laboratorio local."
}
