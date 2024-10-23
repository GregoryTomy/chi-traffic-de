import os

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.operators.docker_operator import DockerOperator
from docker.types import Mount

default_args = {"owner": "duncnh", "depends_on_past": False, "retries": 0}

with DAG(
    "3.0_dbt_transformations",
    default_args=default_args,
    description="Run dbt transformations to build BigQuery tables",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
) as dag:

    print_date = BashOperator(task_id="print_current_date", bash_command="date")

    run_dbt_docker = DockerOperator(
        task_id="run_dbt_docker",
        image="dbt_docker",
        container_name="dbt_docker_run",
        api_version="auto",
        auto_remove=True,
        command="build",
        docker_url="tcp://docker-proxy:2375",
        network_mode="bridge",
        mounts=[
            Mount(
                source=os.getenv("DBT_PROJ_DIR"),
                target="/usr/app",
                type="bind",
            ),
            Mount(
                source=os.getenv("DBT_CONFIG_PATH"), target="/root/.dbt", type="bind"
            ),
            Mount(
                source=os.getenv("DBT_GCP_KEY"),
                target="/root/.google/credentials/dbt_gcp_sa_key.json",
                type="bind",
            ),
        ],
        mount_tmp_dir=False,
    )

    print_end_task = BashOperator(
        task_id="echo_end_task",
        bash_command='echo "DBT runs finished successfully"',
    )

    print_date >> run_dbt_docker >> print_end_task
