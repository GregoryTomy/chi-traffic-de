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
from google.cloud import storage

# GCS Variables
BUCKET = "chi-traffic-de-bucket"

TRAFFIC_INJURY_CRASHES_URL = (
    "https://data.cityofchicago.org/resource/85ca-t3if.csv?$limit=1000000"
)
TRAFFIC_INJURY_VEHICLE_URL = (
    "https://data.cityofchicago.org/resource/68nd-jvt3.csv?$limit=2000000"
)
TRAFFIC_INJURY_PERSON_URL = (
    "https://data.cityofchicago.org/resource/u6pd-qa9d.csv?$limit=2000000"
)


default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}

execution_date = "{{ds_nodash}}"

with DAG(
    "1.0_fetch_and_upload_CHI_data_v6",
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

    fetch_data_1 = PythonOperator(
        task_id="fetch_dataset_crash",
        python_callable=fetch_dataset,
        provide_context=True,
        op_kwargs={
            "api_url": TRAFFIC_INJURY_CRASHES_URL,
            "tmp_file_name": f"chi_traffic_crashes_{execution_date}",
        },
    )

    fetch_data_2 = PythonOperator(
        task_id="fetch_dataset_people",
        python_callable=fetch_dataset,
        provide_context=True,
        op_kwargs={
            "api_url": TRAFFIC_INJURY_PERSON_URL,
            "tmp_file_name": f"chi_traffic_people_{execution_date}",
        },
    )

    fetch_data_3 = PythonOperator(
        task_id="fetch_dataset_vehicle",
        python_callable=fetch_dataset,
        provide_context=True,
        op_kwargs={
            "api_url": TRAFFIC_INJURY_VEHICLE_URL,
            "tmp_file_name": f"chi_traffic_vehicle_{execution_date}",
        },
    )

    format_to_parquet_1 = PythonOperator(
        task_id="format_to_parquet_crash",
        python_callable=format_csv_to_parquet,
        op_kwargs={"csv_file_path": "{{ti.xcom_pull(task_ids='fetch_dataset_crash')}}"},
    )

    format_to_parquet_2 = PythonOperator(
        task_id="format_to_parquet_people",
        python_callable=format_csv_to_parquet,
        op_kwargs={
            "csv_file_path": "{{ti.xcom_pull(task_ids='fetch_dataset_people')}}"
        },
    )

    format_to_parquet_3 = PythonOperator(
        task_id="format_to_parquet_vehicle",
        python_callable=format_csv_to_parquet,
        op_kwargs={
            "csv_file_path": "{{ti.xcom_pull(task_ids='fetch_dataset_vehicle')}}"
        },
    )

    upload_parquet_crash = LocalFilesystemToGCSOperator(
        task_id="upload_crash_parquet_to_gcs",
        src="{{ti.xcom_pull(task_ids='format_to_parquet_crash')}}",
        dst=f"traffic_data/crash/chi_traffic_crash_{execution_date}.parquet",
        bucket=BUCKET,
    )

    upload_parquet_people = LocalFilesystemToGCSOperator(
        task_id="upload_people_parquet_to_gcs",
        src="{{ti.xcom_pull(task_ids='format_to_parquet_people')}}",
        dst=f"traffic_data/people/chi_traffic_people_{execution_date}.parquet",
        bucket=BUCKET,
    )

    upload_parquet_vehicle = LocalFilesystemToGCSOperator(
        task_id="upload_vehicle_parquet_to_gcs",
        src="{{ti.xcom_pull(task_ids='format_to_parquet_vehicle')}}",
        dst=f"traffic_data/vehicle/chi_traffic_vehicle_{execution_date}.parquet",
        bucket=BUCKET,
    )

    (fetch_data_1 >> format_to_parquet_1 >> upload_parquet_crash)
    (fetch_data_2 >> format_to_parquet_2 >> upload_parquet_people)
    (fetch_data_3 >> format_to_parquet_3 >> upload_parquet_vehicle)
