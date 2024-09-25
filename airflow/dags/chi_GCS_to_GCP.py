import os
import logging
import datetime as dt

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.operators.dummy import DummyOperator

from google.cloud import storage

# GCS Variables
BUCKET = "chi-traffic-de-bucket"

default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}
# BigQuery Variables
BQ_DATASET = 'chi_traffic_dataset'
BQ_TABLE_CRASH = "crash_table"
BQ_TABLE_PEOPLE = "people_table"
BQ_TABLE_VEHICLE = "vehicle_table"

default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}

with DAG(
    "export_date_from_GCS_to_GCP",
    default_args=default_args,
    description="Load data from GCS to BigQuery with partitioning on date",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
) as dag:

    wait_for_fetch_dag = DummyOperator(
        task_id="wait_for_fetch_to_GCS_dag"
    )

    load_crash_data_to_bq = GCSToBigQueryOperator(
        task_id = "load_crash_data_to_bq",
        bucket=BUCKET,
        source_objects=[f"traffic_data/crash/chi_traffic_crash_{dt.datetime.today().strftime('%Y%m%d')}.parquet"],
        destination_project_dataset_table =  f"{BQ_DATASET}.{BQ_TABLE_CRASH}",
        source_format="PARQUET",
        write_disposition="WRITE_TRUNCATE", #* replaces entire contents of the destination table
        #TODO: Change to append when modifying data ingestion to daily
        autodetect=True,
    )

    load_people_data_to_bq = GCSToBigQueryOperator(
        task_id = "load_people_data_to_bq",
        bucket=BUCKET,
        source_objects=[f"traffic_data/people/chi_traffic_people_{dt.datetime.today().strftime('%Y%m%d')}.parquet"],
        destination_project_dataset_table =  f"{BQ_DATASET}.{BQ_TABLE_PEOPLE}",
        source_format="PARQUET",
        write_disposition="WRITE_TRUNCATE", #* replaces entire contents of the destination table
        #TODO: Change to append when modifying data ingestion to daily
        #! Had an issue with an unknown column :@computed_region_qgnn_b9vv.
        ignore_unknown_values=True,
        autodetect=True,
    )

    load_vehicle_data_to_bq = GCSToBigQueryOperator(
        task_id = "load_vehicle_data_to_bq",
        bucket=BUCKET,
        source_objects=[f"traffic_data/vehicle/chi_traffic_vehicle_{dt.datetime.today().strftime('%Y%m%d')}.parquet"],
        destination_project_dataset_table =  f"{BQ_DATASET}.{BQ_TABLE_VEHICLE}",
        source_format="PARQUET",
        write_disposition="WRITE_TRUNCATE", #* replaces entire contents of the destination table
        #TODO: Change to append when modifying data ingestion to daily
        autodetect=True,
    )

    wait_for_fetch_dag >> load_crash_data_to_bq
    wait_for_fetch_dag >> load_people_data_to_bq
    wait_for_fetch_dag >> load_vehicle_data_to_bq
