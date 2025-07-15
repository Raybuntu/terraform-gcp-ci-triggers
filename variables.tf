variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "connection_name" {
  type        = string
  description = "Name of Repo connection (GitHub)"
}

variable "packer_remote_uri" {
  type        = string
  description = "Full uri of the packer git repo"
}

variable "webapp_remote_uri" {
  type        = string
  description = "Full uri of the webapp git repo"
}

variable "webapp_git_sha" {
  type        = string
  description = "Git sha of the webapp"
}

variable "build_region" {
  type        = string
  default     = "europe-west1"
  description = "Region to build in with cloud build"
}

variable "build_zone" {
  type        = string
  default     = "europe-west1-a"
  description = "Zone to build in with cloud build"
}

variable "cloudbuild_filename" {
  type        = string
  default     = "cloudbuild.yaml"
  description = "Path to the Cloud Build configuration file"
}

variable "github_app_installation_id" {
  type        = string
  description = "GitHub App Installation ID for Cloud Build"
}

variable "gh_connect_secret_id" {
  type        = string
  description = "ID of GitHub OAUTH secret"
}

variable "gh_connect_secret_name" {
  type        = string
  description = "Name of GitHub OAUTH secret"
}
