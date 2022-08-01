resource "google_artifact_registry_repository" "my_repo" {
  provider = google-beta

  location      = "us-central1"
  repository_id = "my-repository"
  description   = "example docker repository"
  format        = "DOCKER"
}
