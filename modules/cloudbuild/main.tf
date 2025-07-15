# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection
# Creates a Cloud Build connection to GitHub using a GitHub App installation using an OAUTH token
resource "google_cloudbuildv2_connection" "github" {
  project  = var.project_id
  location = var.build_region
  name     = var.connection_name

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = "${var.gh_connect_secret_name}/versions/latest"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_repository
# Registers the Packer GitHub repository with Cloud Build
resource "google_cloudbuildv2_repository" "packer_repo" {
  name              = "packer_repo"
  parent_connection = google_cloudbuildv2_connection.github.id
  remote_uri        = var.packer_remote_uri
  project           = var.project_id
  location          = var.build_region
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_repository
# Registers the Packer GitHub repository with Cloud Build
resource "google_cloudbuildv2_repository" "webapp_repo" {
  name              = "webapp_repo"
  parent_connection = google_cloudbuildv2_connection.github.id
  remote_uri        = var.webapp_remote_uri
  project           = var.project_id
  location          = var.build_region
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
# Creates a Cloud Build trigger for the 'main' branch of the packer_repo GitHub repository,
# using the specified service account and build configuration file.
resource "google_cloudbuild_trigger" "packertrigger" {
  name            = "packertrigger"
  project         = var.project_id
  # SA is required for v2 repos
  service_account = var.build_trigger_sa.id
  location        = var.build_region


  # GH push event
  repository_event_config {
    repository = google_cloudbuildv2_repository.packer_repo.id
    push {
      branch = "^main$"
    }
  }

  # Substitute variables
  substitutions = {
    _PROJECT_ID          = var.project_id
    _ZONE                = var.build_zone
    _WEBAPP_GIT_REPO_URL = var.webapp_remote_uri
    _WEBAPP_GIT_SHA      = var.webapp_git_sha
  }

  filename = var.cloudbuild_filename
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
# Creates a Cloud Build trigger for the 'main' branch of the webapp_repo GitHub repository,
# using the specified service account and build configuration file. Executes the packertrigger on push.
resource "google_cloudbuild_trigger" "webapptrigger" {
  name            = "webapptrigger"
  project         = var.project_id
  service_account = var.webapp_trigger_sa.id
  location        = var.build_region

  repository_event_config {
    repository = google_cloudbuildv2_repository.webapp_repo.id
    push {
      branch = "^main$"
    }
  }

  build {
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOT
          gcloud builds triggers run "${google_cloudbuild_trigger.packertrigger.name}" \
            --region=${var.build_region} \
            --project=${var.project_id} \
            --branch=main \
            --substitutions=_PROJECT_ID=${var.project_id},_ZONE=${var.build_zone},_WEBAPP_GIT_REPO_URL=${var.webapp_remote_uri},_WEBAPP_GIT_SHA=$SHORT_SHA
        EOT
      ]
    }
  }
}
