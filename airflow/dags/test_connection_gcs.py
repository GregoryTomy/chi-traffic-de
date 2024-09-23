import os

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.transfers.local_to_gcs import (
    LocalFilesystemToGCSOperator,
)
from airflow.operators.dummy import DummyOperator

default_args = {
    "owner": "duncanh",
    "start_date": days_ago(1),
    "retries": 1,
}

BUCKET_NAME = "chi-traffic-de-bucket"
print(BUCKET_NAME)
FILE_NAME = "/opt/airflow/dags/test_file.txt"  # Replace with the path to your test file

# Create a simple text file to upload
with open(FILE_NAME, "w") as f:
    f.write("This is a test file for GCS upload.")

with DAG(
    dag_id="gcs_test_dag",
    default_args=default_args,
    schedule_interval=None,  # Set to None for manual trigger
    catchup=False,
) as dag:

    start = DummyOperator(task_id="start")

    # Task to upload the file to GCS
    upload_to_gcs = LocalFilesystemToGCSOperator(
        task_id="upload_file_to_gcs",
        src=FILE_NAME,
        dst="test_file.txt",  # Name of the file once uploaded to GCS
        bucket=BUCKET_NAME,
    )

    start >> upload_to_gcs
