terraform {
  required_version = ">= 1.12.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
  backend "gcs" {}
}

# Loads the IAM module to configure roles and permissions
module "iam" {
  source               = "./modules/iam"
  project_id           = var.project_id
  gh_connect_secret_id = var.gh_connect_secret_id
}

# Loads the Cloud build module to configure repo connections and triggers
module "cloudbuild" {
  source                             = "./modules/cloudbuild"
  project_id                         = var.project_id
  connection_name                    = var.connection_name
  packer_remote_uri                  = var.packer_remote_uri
  webapp_remote_uri                  = var.webapp_remote_uri
  webapp_git_sha                     = var.webapp_git_sha
  build_region                       = var.build_region
  build_zone                         = var.build_zone
  cloudbuild_filename                = var.cloudbuild_filename
  github_app_installation_id         = var.github_app_installation_id
  gh_connect_secret_name             = var.gh_connect_secret_name
  build_trigger_sa                   = module.iam.build_trigger_sa
  webapp_trigger_sa                  = module.iam.webapp_trigger_sa
  packer_vm_sa                       = module.iam.packer_vm_sa
  cloudbuild_secret_accessor_binding = module.iam.cloudbuild_secret_accessor_binding
}
