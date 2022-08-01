terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.72.0"
    }
  }
}

provider "google" {
  credentials = file("./angular-cosmos-280512-933e1631fb78.json")

  project = "angular-cosmos-280512"
  region  = "us-central1"
  zone    = "us-central1-a"
}

provider "google-beta" {
  credentials = file("./angular-cosmos-280512-933e1631fb78.json")

  project = "angular-cosmos-280512"
  region  = "us-central1"
  zone    = "us-central1-a"
}
