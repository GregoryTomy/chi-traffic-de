import os
import logging
import json
import requests
import datetime as dt

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.transfers.local_to_gcs import (
    LocalFilesystemToGCSOperator,
)
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from google.cloud import storage

# GCS Variables
BUCKET = "chi-traffic-de-bucket"

GEOJSON_DATASETS = {
    "neighborhood": "https://data.cityofchicago.org/resource/y6yq-dbs2.geojson",
    "ward": "https://data.cityofchicago.org/resource/p293-wvbd.geojson",
}

PARTITION_DATE = "{{ds_nodash}}"

default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}

with DAG(
    "1.1_fetch_and_upload_geojson_data_to_gcs",
    default_args=default_args,
    description="Fetch geography datasets from Chicago OpenData API,and upload to GCS",
    schedule_interval=None,
    start_date=days_ago(1),
) as dag:

    def fetch_geojson_dataset(api_url, tmp_file_name, **kwargs):
        response = requests.get(api_url)
        if response.status_code == 200:
            file_path = f"/tmp/{tmp_file_name}.geojson"
            with open(file_path, "wb") as file:
                file.write(response.content)
            return file_path
        else:
            raise Exception(
                f"Failed to fetch data from {api_url}: {response.status_code}"
            )

    trigger_second_dag = TriggerDagRunOperator(
        task_id="trigger_geo_gcs_to_gcp",
        trigger_dag_id="2.1_export_geojson_data_from_GCS_to_GCP",
    )

    for dataset_name, api_url in GEOJSON_DATASETS.items():
        fetch_data = PythonOperator(
            task_id=f"fetch_geojson_{dataset_name}",
            python_callable=fetch_geojson_dataset,
            provide_context=True,
            op_kwargs={
                "api_url": api_url,
                "tmp_file_name": f"chi_boundaries_{dataset_name}_{PARTITION_DATE}",
            },
        )

        upload_data = LocalFilesystemToGCSOperator(
            task_id=f"upload_{dataset_name}_geojson_to_gcs",
            src="{{ti.xcom_pull(task_ids='fetch_geojson_" + dataset_name + "')}}",
            dst=f"geojson/chi_boundaries_{dataset_name}_{PARTITION_DATE}.geojson",
            bucket=BUCKET,
        )

        fetch_data >> upload_data

    [upload_data for dataset_name in GEOJSON_DATASETS] >> trigger_second_dag
