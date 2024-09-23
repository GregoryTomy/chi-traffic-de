terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.3.0"
    }
  }
}

provider "google" {
  # Configuration options
  credentials = file(var.credentials)
  project = var.project_name
  region  = "us-central1"
}

# Google Cloud Storage bucket
resource "google_storage_bucket" "chi-traffic-bucket" {
  name          = var.gcs_bucket_name
  location      = var.gcs_bucket_location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

# Google Big Query Dataset
resource "google_bigquery_dataset" "chi-traffic-dataset" {
  dataset_id                 = var.bq_dataset_name
  delete_contents_on_destroy = true
}
