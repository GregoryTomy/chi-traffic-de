import os
import logging
import json
import requests
import datetime as dt
import pyarrow.parquet as pq
import pyarrow.csv as csv
import pyarrow as pa
import pandas as pd

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

TRAFFIC_DATASETS = {
    "crash": "https://data.cityofchicago.org/resource/85ca-t3if.csv?$limit=1000000",
    "vehicle": "https://data.cityofchicago.org/resource/68nd-jvt3.csv?$limit=2000000",
    "people": "https://data.cityofchicago.org/resource/u6pd-qa9d.csv?$limit=2000000",
}


default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}

EXECUTION_DATE = "{{ds_nodash}}"

with DAG(
    "1.0_fetch_and_upload_CHI_data_v7",
    default_args=default_args,
    description="Fetch multiple datasets from Chicago OpenData API, store temporarily, and display row count",
    schedule_interval=None,
    start_date=days_ago(1),
) as dag:

    def fetch_dataset(api_url, tmp_file_name, **kwargs):
        response = requests.get(api_url)
        if response.status_code == 200:
            file_path = f"/tmp/{tmp_file_name}.csv"
            with open(file_path, "wb") as file:
                file.write(response.content)
            return file_path
        else:
            raise Exception(
                f"Failed to fetch data from {api_url}: {response.status_code}"
            )

    def format_csv_to_parquet(csv_file_path):
        try:
            table = csv.read_csv(csv_file_path)
            parquet_file_path = csv_file_path.replace(".csv", ".parquet")
            pq.write_table(table, parquet_file_path)
            print(f"Succesffully converted {csv_file_path} to {parquet_file_path}")
            return parquet_file_path
        except Exception as e:
            print(f"Failed to convert {csv_file_path} to Parquet: {str(e)}")

    trigger_second_dag = TriggerDagRunOperator(
        task_id="trigger_gcs_to_gcp",
        trigger_dag_id="2.0_export_data_from_GCS_to_GCP",
    )

    for dataset_name, api_url in TRAFFIC_DATASETS.items():
        fetch_data = PythonOperator(
            task_id=f"fetch_dataset_{dataset_name}",
            python_callable=fetch_dataset,
            provide_context=True,
            op_kwargs={
                "api_url": api_url,
                "tmp_file_name": f"chi_traffic_{dataset_name}_{EXECUTION_DATE}",
            },
        )

        format_to_parquet = PythonOperator(
            task_id=f"format_to_parquet_{dataset_name}",
            python_callable=format_csv_to_parquet,
            op_kwargs={
                "csv_file_path": "{{ti.xcom_pull(task_ids='fetch_dataset_"
                + dataset_name
                + "')}}"
            },
        )

        upload_parquet = LocalFilesystemToGCSOperator(
            task_id=f"upload_{dataset_name}_parquet_to_gcs",
            src="{{ti.xcom_pull(task_ids='format_to_parquet_" + dataset_name + "')}}",
            dst=f"traffic_data/{dataset_name}/chi_traffic_{dataset_name}_{EXECUTION_DATE}.parquet",
            bucket=BUCKET,
        )

        fetch_data >> format_to_parquet >> upload_parquet

    [upload_parquet for datset_name in TRAFFIC_DATASETS] >> trigger_second_dag
