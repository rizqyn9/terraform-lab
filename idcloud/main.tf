terraform {
  required_providers {
    idcloudhost = {
      version = "0.1.3"
      source  = "bapung/idcloudhost"
    }
  }
}

provider "idcloudhost" {
    auth_token = ""
}

resource "idcloudhost_floating_ip" "testip" {
    name = "my_test_ip"
    billing_account_id = 1337
}