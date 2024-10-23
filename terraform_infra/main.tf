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

provider "local" {

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

####################################################################################
# Google Cloud Composer
####################################################################################
# Create a Google Cloud service account
resource "google_service_account" "composer_service_account" {
    account_id="composer-service-account"
    display_name = "Google Cloud Composer service account"
}

# Assign IAM role to the service account
resource "google_project_iam_member" "composer_sa_roles" {
    project = var.project_name
    member = "serviceAccount:${google_service_account.composer_service_account.email}"
    role = "roles/composer.worker"
}

# Assign role to the cloud composer service agennt
resource "google_service_account_iam_member" "composer_sa_roles" {
    service_account_id = google_service_account.composer_service_account.name
    role = "roles/composer.ServiceAgentV2Ext"
    member = "serviceAccount:service-${var.project_number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

# Provision a Cloud Composer environement
resource "google_composer_environment" "composer_environment" {
    name = "chi-composer-environment"
    config {
      software_config {
        image_version = "composer-2.9.7-airflow-2.9.3"
      }
      node_config {
        service_account = google_service_account.composer_service_account.email
      }
    }
}

####################################################################################
# Google service accounts
####################################################################################

## Tableau
resource "google_service_account" "tableau_service_account" {
    account_id = "tableau-service-account"
    display_name = "Tableau service account"
}

resource "google_project_iam_member" "tableau_sa_roles" {
    for_each = toset(var.tableau_bq_roles)
    project = var.project_name
    role = each.value
    member = "serviceAccount:${google_service_account.tableau_service_account.email}"
}

resource "google_service_account_key" "tableau_sa_key" {
    service_account_id = google_service_account.tableau_service_account.name
}

resource "local_sensitive_file" "tableau_sa_key_json" {
    filename = "../tableau/secrets/tableau-sa-key.json"
    content = google_service_account_key.tableau_sa_key.private_key
}

output "tableau_sa_key_path" {
    value = local_sensitive_file.tableau_sa_key_json.filename
}
