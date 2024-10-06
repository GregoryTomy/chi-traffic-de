import os
import subprocess
import logging
import pathlib
import datetime as dt

from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import (
    GCSToBigQueryOperator,
)
from airflow.providers.google.cloud.transfers.gcs_to_local import (
    GCSToLocalFilesystemOperator,
)
from airflow.providers.google.cloud.transfers.local_to_gcs import (
    LocalFilesystemToGCSOperator,
)
from airflow.operators.dummy import DummyOperator

from google.cloud import storage

# GCS Variables
BUCKET = "chi-traffic-de-bucket"

# BigQuery Variables
BQ_DATASET = "raw_data"

PROCESS_SCRIPT_PATH = "/opt/airflow/scripts/json_to_ndjson.py"

GEOJSON_TABLES = {"neighborhood": "neighborhood", "ward": "ward"}

default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}

date_today = "{{ds_nodash}}"


def process_geojson(local_file_path, **kwargs):
    input_path = pathlib.Path(local_file_path)
    output_path = input_path.with_suffix(".geojsonl")

    with open(output_path, "w") as outfile:
        subprocess.run(
            ["jq", "-c", ".features[]", str(input_path)],
            stdout=outfile,
            check=True,
        )


with DAG(
    "export_geojson_data_from_GCS_to_GCP",
    default_args=default_args,
    description="Fetch geojson data, process it to geojsonl, and load to BigQuery with partitioning on date",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
) as dag:

    wait_for_fetch_dag = DummyOperator(task_id="wait_for_fetch_to_GCS_dag")

    for dataset_name, bq_table in GEOJSON_TABLES.items():
        gcs_file_path = f"geojson/chi_boundaries_{dataset_name}_{date_today}.geojson"
        local_file_path = f"/tmp/chi_boundaries_{dataset_name}_{date_today}.geojson"
        local_processed_file_path = (
            f"/tmp/chi_boundaries_{dataset_name}_{date_today}.geojsonl"
        )

        download_from_gcs = GCSToLocalFilesystemOperator(
            task_id=f"download_{dataset_name}_from_gcs",
            object_name=gcs_file_path,
            bucket=BUCKET,
            filename=local_file_path,
        )

        process_geojson_data = BashOperator(
            task_id=f"process_{dataset_name}",
            bash_command=f"python {PROCESS_SCRIPT_PATH} {local_file_path} {local_processed_file_path}",
        )

        upload_data = LocalFilesystemToGCSOperator(
            task_id=f"upload_processed_{dataset_name}_geojsonl_to_gcs",
            src=local_processed_file_path,
            dst=f"geojsonl/chi_boundaries_{dataset_name}_{dt.datetime.today().strftime('%Y%m%d')}.geojsonl",
            bucket=BUCKET,
        )

        load_geojson_data_to_bq = GCSToBigQueryOperator(
            task_id=f"load_processed_{dataset_name}_geojsonl_to_bq",
            bucket=BUCKET,
            source_objects=[
                f"geojsonl/chi_boundaries_{dataset_name}_{date_today}.geojsonl"
            ],
            destination_project_dataset_table=f"{BQ_DATASET}.{bq_table}_{date_today}",
            source_format="NEWLINE_DELIMITED_JSON",
            write_disposition="WRITE_TRUNCATE",  # * replaces entire contents of the destination table
            # TODO: Change to append when modifying data ingestion to daily
            autodetect=True,
        )

        (
            wait_for_fetch_dag
            >> download_from_gcs
            >> process_geojson_data
            >> upload_data
            >> load_geojson_data_to_bq
        )
