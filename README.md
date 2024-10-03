# [IN PROGRESS - see todo.md for working updates] Chicago Traffic Crash Insights Dashboard
I am currently working on a Data Engineering project that aims to build an interactive insights dashboard for traffic crash data in Chicago. The project leverages Google Cloud Platform (GCP) to house the data warehouse infrastructure, with orchestration managed by Apache Airflow and analytics engineering handled through dbt.

## Key components:
- **Data orchestration**: Apache Airflow pipelines for data ingestion and transformation.
- **Infrastructure**: Provisioned using Terraform for reproducibility and scalability.
- **Analytics**: Transformations using dbt in BigQuery for streamlined reporting.
- **Visualization**: Building a dashboard with Tableau/Looker to explore key crash metrics.

This project focuses on providing insights into crash severity, contributing factors, and geographic distribution of incidents to aid city planners and stakeholders.

## About The Data

1. **Relationship Between Datasets:**
    - **Crashes** are the central dataset. Each crash is uniquely identified by `CRASH_RECORD_ID`.
    - **Vehicles (Units):** A "unit" can be a vehicle, pedestrian, or cyclist. Each unit is represented in the vehicles dataset, and units have a one-to-many relationship with crashes.
    - **People:** Represents individuals involved in the crash (drivers, passengers, pedestrians). People have a one-to-many relationship with vehicles, except for pedestrians and cyclists, who are treated as units themselves and have a one-to-one relationship with the vehicles dataset.

2. **Linkage:**
    - The common key across all datasets is `CRASH_RECORD_ID`, allowing the crashes, vehicles, and people datasets to be joined together for analysis.
    - The vehicles dataset is linked to both crashes and people, providing a full view of each crash event.

3. **Data Specifics:**
    - The vehicles dataset contains motor vehicle and non-motor vehicle modes (e.g., pedestrians, cyclists). Some fields may only apply to specific types of units (e.g., `VEHICLE_TYPE` for cars but not pedestrians).
    - The people dataset includes injury data reported by police officers and provides information on the individuals involved, which could be drivers, passengers, or pedestrians.

4. **Crash Reporting:**
    - Crashes are recorded according to the Illinois Department of Transportation (IDOT) standards, with only certain crashes being "reportable" by law (property damage over $1,500 or involving bodily injury).
    - Chicago Police Department (CPD) records all crashes, even those not officially reportable by IDOT.

5. **Quality of Data:**
    - Many of the fields (e.g., weather, road conditions) are subjective and recorded based on the reporting officer’s assessment. These fields might not always perfectly align with actual conditions.

6. **Amendments:**
    - Crash reports can be amended after initial submission, meaning data can change over time if new information becomes available.
