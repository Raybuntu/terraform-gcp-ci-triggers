# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project
# Get information about the out GCP project.
data "google_project" "project" {
  project_id = var.project_id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# create a SA for packer builds
resource "google_service_account" "packer_vm" {
  account_id   = "packer-vm-sa"
  display_name = "Packer VM Build Service Account"
  project      = var.project_id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
# Assigns minimum roles to the packer-vm-sa
resource "google_project_iam_member" "packer_vm_roles" {
  for_each = toset([
    "roles/compute.instanceAdmin.v1", # Allows creating, deleting, and managing VM instances
    "roles/compute.imageUser",        # Allows using public base images (like Ubuntu)
    "roles/compute.viewer",           # Grants read-only access to compute metadata (e.g. zones, machine types)
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.packer_vm.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# cloudbuild service account
resource "google_service_account" "build_trigger" {
  project = var.project_id
  account_id   = "build-trigger"
  display_name = "Cloud Build Trigger Service Account"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
# Assigns roles to the build_trigger service account
resource "google_project_iam_member" "build_trigger_roles" {
  for_each = toset([
    "roles/cloudbuild.builds.builder",    # Allows running and managing builds
    "roles/compute.imageUser",            # Allows reading and using images
    "roles/compute.viewer",               # Allows read/list access to zones and all Compute resources (needed for Packer builds)
    "roles/compute.instanceAdmin.v1",     # Allows creating, deleting, and managing VM instances (required by Packer)
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.build_trigger.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
# Grants the Cloud Build Service Agent access to read GH secret
resource "google_secret_manager_secret_iam_member" "cloudbuild_serviceagent_secret_accessor" {
  project   = var.project_id
  secret_id = var.gh_connect_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
# Allows the build trigger service account to act as packer_vm SA (for packer builds)
resource "google_service_account_iam_member" "build_trigger_impersonate_packer_vm" {
  service_account_id = google_service_account.packer_vm.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.build_trigger.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# Service account that triggers the Packer build when a push happens in the WebApp repo
resource "google_service_account" "webapp_trigger" {
  project      = var.project_id
  account_id   = "webapp-trigger"
  display_name = "WebApp Trigger Service Account"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
# Grants the webapp trigger SA permission to build using Cloud Build
resource "google_project_iam_member" "webapp_trigger_roles" {
  for_each = toset([
    "roles/cloudbuild.builds.builder", # Allows running and managing builds
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.webapp_trigger.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
# Allows the webapp trigger SA to impersonate the packer trigger SA (needed for gcloud builds triggers run)
resource "google_service_account_iam_member" "webapp_trigger_impersonate_build_trigger" {
  service_account_id = google_service_account.build_trigger.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.webapp_trigger.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
# Allows the webapp trigger SA to "act as" the packer trigger SA (required for SA impersonation)
resource "google_service_account_iam_member" "webapp_trigger_act_as_build_trigger" {
  service_account_id = google_service_account.build_trigger.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.webapp_trigger.email}"
}
