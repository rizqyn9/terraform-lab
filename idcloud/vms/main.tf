terraform {
  required_providers {
    idcloudhost = {
      version = "0.1.3"
      source  = "bapung/idcloudhost"
    }
  }
}

data "idcloudhost_vms" "all" {}

output "all_vms" {
  value = data.idcloudhost_vms.all
}