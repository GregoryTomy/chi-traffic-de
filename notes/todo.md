# 10/20/2024
- trigger dbt runs with airflow.
- trigger tableau extract and dashboard update.
- deploy in the cloud and test daily/weekly runs.

# 10/15/2024
- Switching to Looker for BI. Easier integration with BigQuery and deployment in the cloud.

# 10/14/2024
- Trying out Metabase as the BI tool.
## Terraform
- Testing getting service accounts for metabase in terraform.
    - TODO: Use Terraform to get all infrastructure related resources.
- NOTE: Creating service account key through terraform does not provide full JSON structure
    - using manual service accoune key generation

# 10/12/2024
- check transaction numbers when running load dags tommorrow
- bringing in the latest partition to staging layer and onwards. Raw layer will hold the appending table with all partitions.
    - staging has the latest partition.
- THOUGHT: Currently not using time dimension. Create hours of the day for hourly breakdown?
    - updated datetime dim to include hour column and is_rush_hour column.
- updated location dimension to only geopoint (long, lat)


# 10/07/2024
- removing street information in location data and keeping to geography point information.
- connect airflow and dbt
    - change partition date on dbt models to reflect source data
- OR better approach, create date column during loading into BQ from airflow.

# 10/06/2024
- Will need to update source names to not be date dependent OR dynamically assign dates

# 10/05/2024
- Fetched, processed, and loaded geojson data to BQ
- used custom python script to process geojson to ndjson
- changed date to date of run "{{ ds_nodash}}"
- TODO:
    - transform neighborhood and ward to GEOGRAPHY
    - Create dimensions

# 10/02/2024
- build airflow pipeline to bring in geography data
- load and parse geojson data in bigquery.

## General
- move variables to env file
    - had issues with airflow recognizing it, fix later
- break down DAGs to separate files / use Airflows `TaskGroup`
- remove code duplication

## Terraform
- add dataset creations to main.tf

## chi_openData_to_gcs.py
- ~~update file naming to be consistent~~

## chi_GCS_to_GCP.py
- change write disposition

## DBT
- add surrogate keys after splitting data into FACT and DIMENSION tables.

### Staging
- update crash staging with new macros
- [IMPORTANT] vehicle id description in the person dataset says that vehicle_id corresponds to crash_record_id in the vehicles dataset. However, it looks lke it corresponds to the vehicle_id column in the vehicle dataset instead.
