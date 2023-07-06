variable "rebuild_version" {}

resource "random_string" "this" {
  keepers = {
    version = var.rebuild_version #Increment will trigger a new stack id, causing the Cloudformation stack to rebuild
  }
  length            = 17
  special           = false
  upper             = false
  numeric          = true
}

output "id" {
  value = "stack-${random_string.this.result}"
}