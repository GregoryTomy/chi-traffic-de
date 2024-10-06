FROM apache/airflow:2.10.2

COPY requirements.txt /requirements.txt

RUN command pip install --no-cache-dir  -r /requirements.txt

USER root

RUN apt-get update && apt-get install -y jq

USER airflow
