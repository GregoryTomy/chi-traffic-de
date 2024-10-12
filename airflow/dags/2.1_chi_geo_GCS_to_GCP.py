import os
import subprocess
import logging
import pathlib
import datetime as dt

from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
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

partition_date = "{{ds_nodash}}"


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
    "2.1_export_geojson_data_from_GCS_to_GCP",
    default_args=default_args,
    description="Fetch geojson data, process it to geojsonl, and load to BigQuery with partitioning on date",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
) as dag:

    wait_for_fetch_dag = DummyOperator(task_id="wait_for_fetch_to_GCS_dag")

    for dataset_name, bq_table in GEOJSON_TABLES.items():
        gcs_file_path = (
            f"geojson/chi_boundaries_{dataset_name}_{partition_date}.geojson"
        )
        local_file_path = f"/tmp/chi_boundaries_{dataset_name}_{partition_date}.geojson"
        local_processed_file_path = (
            f"/tmp/chi_boundaries_{dataset_name}_{partition_date}.geojsonl"
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
            dst=f"geojsonl/chi_boundaries_{dataset_name}_{partition_date}.geojsonl",
            bucket=BUCKET,
        )

        load_geojson_data_to_bq = GCSToBigQueryOperator(
            task_id=f"load_processed_{dataset_name}_geojsonl_to_bq",
            bucket=BUCKET,
            source_objects=[
                f"geojsonl/chi_boundaries_{dataset_name}_{partition_date}.geojsonl"
            ],
            destination_project_dataset_table=f"{BQ_DATASET}.{bq_table}",
            source_format="NEWLINE_DELIMITED_JSON",
            write_disposition="WRITE_TRUNCATE",  # * replaces entire contents of the destination table
            # TODO: Change to append when modifying data ingestion to daily
            autodetect=True,
        )

        add_partition_date_column = BigQueryInsertJobOperator(
            task_id=f"add_partition_date_column_{bq_table}",
            configuration={
                "query": {
                    "query": f"""
                        ALTER TABLE `{BQ_DATASET}.{bq_table}`
                        ADD COLUMN IF NOT EXISTS partition_date DATE;
                    """,
                    "useLegacySql": False,
                }
            },
        )

        update_partition_date = BigQueryInsertJobOperator(
            task_id=f"update_partition_date_{bq_table}",
            configuration={
                "query": {
                    "query": f"""
                        UPDATE `{BQ_DATASET}.{bq_table}`
                        SET partition_date = DATE('{{{{ execution_date }}}}')
                        WHERE partition_date IS NULL;
                        """,
                    "useLegacySql": False,
                }
            },
        )

        (
            wait_for_fetch_dag
            >> download_from_gcs
            >> process_geojson_data
            >> upload_data
            >> load_geojson_data_to_bq
            >> add_partition_date_column
            >> update_partition_date
        )
