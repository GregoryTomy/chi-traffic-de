# Chicago Traffic Crash Insights Dashboard

Data Engineering project that orchestrates weekly ETL pipelines with Airflow to process and transform over 4.6M rows of Chicago crash and geospatial data. Data is modeled in BigQuery using a star schema with dbt, featuring data validation and testing to support KPIs and dashboards. The project includes an interactive Tableau dashboard to visualize crash trends and geographic distribution, with scalable infrastructure automated in Google Cloud Platform using Terraform.

[View Tableau Dashboard](https://public.tableau.com/shared/5BNTZ4Q3G?:display_count=n&:origin=viz_share_link)

## Key components:
- **Data orchestration**: Apache Airflow pipelines for data ingestion and transformation.
- **Infrastructure**: Provisioned cloud resources using Terraform for reproducibility and scalability.
- **Analytics**: Transformations using dbt in BigQuery for streamlined reporting.
- **Visualization**: Dashboard with Tableau to explore key crash metrics.

## Architecture
![](images/architecture.drawio.png)

## Data Model
![](images/datamodel.png)
