#output "build_trigger_sa" {
#  description = "Build Trigger Service Account"
#  value       = google_service_account.build_trigger
#}

#output "webapp_trigger_sa" {
#  description = "Webapp Build Trigger Service Account"
#  value       = google_service_account.webapp_trigger
#}

output "build_trigger_sa" {
  description = "Packer Image Build Trigger Service Account"
  value = {
    name = google_service_account.build_trigger.name
    id   = google_service_account.build_trigger.id
  }
}

output "webapp_trigger_sa" {
  description = "Webapp Build Trigger Service Account"
  value = {
    name = google_service_account.webapp_trigger.name
    id   = google_service_account.webapp_trigger.id
  }
}

output "packer_vm_sa" {
  description = "Packer VM Service Account for the builds"
  value = {
    name  = google_service_account.packer_vm.name
    id    = google_service_account.packer_vm.id
    email = google_service_account.packer_vm.email
  }
}

output "cloudbuild_secret_accessor_binding" {
  description = "IAM binding that grants the Cloud Build Service Agent access to the GitHub OAuth secret."
  value       = google_secret_manager_secret_iam_member.cloudbuild_serviceagent_secret_accessor
}
