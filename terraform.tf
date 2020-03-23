locals {
  project_name = "codesuite-terraform-${random_id.random.hex}"
  region       = "eu-west-3"
}

provider aws {
  region = local.region
}

resource random_id random {
  byte_length = 3
}

#
# modules
#

module pipeline {
  source       = "./terraform/pipeline"
  project_name = local.project_name
}

#
# outputs
#

output project_name {
  value = local.project_name
}

output clone_url_http {
  value = module.pipeline.clone_url_http
}

output clone_url_ssh {
  value = module.pipeline.clone_url_ssh
}

output user_id {
  value = module.pipeline.user_id
}

output ssh_public_key_id {
  value = module.pipeline.ssh_public_key_id
}