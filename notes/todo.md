
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
