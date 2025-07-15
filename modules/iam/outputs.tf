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
