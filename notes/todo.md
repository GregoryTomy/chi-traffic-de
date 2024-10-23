# 10/20/2024
- trigger dbt runs with airflow.
- trigger tableau extract and dashboard update.
- deploy in the cloud and test daily/weekly runs.

# 10/15/2024
- switching to looker for bi. easier integration with bigquery and deployment in the cloud.

# 10/14/2024
- trying out metabase as the bi tool.
## terraform
- testing getting service accounts for metabase in terraform.
    - todo: use terraform to get all infrastructure related resources.
- note: creating service account key through terraform does not provide full json structure
    - using manual service accoune key generation

# 10/12/2024
- check transaction numbers when running load dags tommorrow
- bringing in the latest partition to staging layer and onwards. raw layer will hold the appending table with all partitions.
    - staging has the latest partition.
- thought: currently not using time dimension. create hours of the day for hourly breakdown?
    - updated datetime dim to include hour column and is_rush_hour column.
- updated location dimension to only geopoint (long, lat)


# 10/07/2024
- removing street information in location data and keeping to geography point information.
- connect airflow and dbt
    - change partition date on dbt models to reflect source data
- or better approach, create date column during loading into bq from airflow.

# 10/06/2024
- will need to update source names to not be date dependent or dynamically assign dates

# 10/05/2024
- fetched, processed, and loaded geojson data to bq
- used custom python script to process geojson to ndjson
- changed date to date of run "{{ ds_nodash}}"
- todo:
    - transform neighborhood and ward to geography
    - create dimensions

# 10/02/2024
- build airflow pipeline to bring in geography data
- load and parse geojson data in bigquery.

## general
- move variables to env file
    - had issues with airflow recognizing it, fix later
- break down dags to separate files / use airflows `taskgroup`
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
