import os
import logging
import datetime as dt

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import (
    GCSToBigQueryOperator,
)
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.operators.dummy import DummyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator


from google.cloud import storage

# GCS Variables
BUCKET = "chi-traffic-de-bucket"

default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}
# BigQuery Variables
BQ_DATASET = "raw_data"
TABLES = {
    "crash": "traffic_data/crash/chi_traffic_crash_{{ds_nodash}}.parquet",
    "people": "traffic_data/people/chi_traffic_people_{{ds_nodash}}.parquet",
    "vehicle": "traffic_data/vehicle/chi_traffic_vehicle_{{ds_nodash}}.parquet",
}

default_args = {"owner": "duncanh", "depends_on_past": False, "retries": 1}

with DAG(
    "2.0_export_data_from_GCS_to_GCP",
    default_args=default_args,
    description="Load data from GCS to BigQuery with partitioning on date",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
) as dag:

    wait_for_fetch_dag = DummyOperator(task_id="wait_for_fetch_to_GCS_dag")

    for table_name, gcs_path in TABLES.items():
        load_data_to_bq = GCSToBigQueryOperator(
            task_id=f"load_{table_name}_to_bigquery",
            bucket=BUCKET,
            source_objects=[gcs_path],
            destination_project_dataset_table=f"{BQ_DATASET}.{table_name}",
            source_format="PARQUET",
            write_disposition="WRITE_APPEND",
            autodetect=True,
        )

        add_partition_date_column = BigQueryInsertJobOperator(
            task_id=f"add_partition_date_column_{table_name}",
            configuration={
                "query": {
                    "query": f"""
                        ALTER TABLE `{BQ_DATASET}.{table_name}`
                        ADD COLUMN IF NOT EXISTS partition_date DATE;
                    """,
                    "useLegacySql": False,
                }
            },
        )

        update_partition_date = BigQueryInsertJobOperator(
            task_id=f"update_partition_date_{table_name}",
            configuration={
                "query": {
                    "query": f"""
                        UPDATE `{BQ_DATASET}.{table_name}`
                        SET partition_date = DATE('{{{{ execution_date }}}}')
                        WHERE partition_date IS NULL;
                        """,
                    "useLegacySql": False,
                }
            },
        )

        (
            wait_for_fetch_dag
            >> load_data_to_bq
            >> add_partition_date_column
            >> update_partition_date
        )

    trigger_dbt_dag = TriggerDagRunOperator(
        task_id="trigger_dbt_docker",
        trigger_dag_id="3.0_dbt_transformations",
    )

    [update_partition_date for datset_name in TABLES] >> trigger_dbt_dag
