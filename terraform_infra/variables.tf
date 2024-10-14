
variable "credentials" {
  description = "GCP credentials"
  default     = "/Users/gregorytomy/chi_traffic/terraform_infra/key/chi-traffic-de-f37c85112530.json"
}

variable "project_name" {
  description = "Project name"
  default     = "sf-traffic-de"
}

variable "gcs_bucket_location" {
  description = "Project location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "BigQuery datset name for chicago traffic crash data"
  default     = "chi_traffic_dataset"
}

variable "gcs_bucket_name" {
  description = "GCS bucket name for chicago traffic data"
  default     = "chi-traffic-de-bucket"
}

variable "metabase_bq_roles" {
    description = "List of roles to assign to metabase service account"
    type = list(string)
    default = [
        "roles/bigquery.dataViewer",
        "roles/bigquery.metadataViewer",
        "roles/bigquery.jobUser" ]
}
