# SF-TRAFFIC-DE

## About The Data
1.	Relationship Between Datasets:
    - Crashes are the central dataset. Each crash is uniquely identified by CRASH_RECORD_ID.
    - Vehicles (Units): A “unit” can be a vehicle, pedestrian, or cyclist. Each unit is represented in the vehicles dataset, and units have a one-to-many relationship with crashes.
	- People: Represents individuals involved in the crash (drivers, passengers, pedestrians). People have a one-to-many relationship with vehicles, except for pedestrians and cyclists, who are treated as units themselves and have a one-to-one relationship with the vehicles dataset.
2.	Linkage:
	- The common key across all datasets is CRASH_RECORD_ID, allowing the crashes, vehicles, and people datasets to be joined together for analysis.
	- The vehicles dataset is linked to both crashes and people, providing a full view of each crash event.
3.	Data Specifics:
	- The vehicles dataset contains motor vehicle and non-motor vehicle modes (e.g., pedestrians, cyclists). Some fields may only apply to specific types of units (e.g., VEHICLE_TYPE for cars but not pedestrians).
	- The people dataset includes injury data reported by police officers and provides information on the individuals involved, which could be drivers, passengers, or pedestrians.
4.	Crash Reporting:
	- Crashes are recorded according to the Illinois Department of Transportation (IDOT) standards, with only certain crashes being “reportable” by law (property damage over $1,500 or involving bodily injury).
	- Chicago Police Department (CPD) records all crashes, even those not officially reportable by IDOT.
5.	Quality of Data:
	- Many of the fields (e.g., weather, road conditions) are subjective and recorded based on the reporting officer’s assessment. These fields might not always perfectly align with actual conditions.
6.	Amendments:
	- Crash reports can be amended after initial submission, meaning data can change over time if new information becomes available.

## Dashboard Ideas

### 1. Crash Overview Statistics:

- **Total Number of Crashes**: Display the total number of crashes over a specific time period.
- **Crashes by Severity**: Breakdown of crashes by injury severity (e.g., fatal, incapacitating, non-incapacitating, no injuries).
- **Crashes by Type**: Breakdown of crash types (e.g., collisions, hit-and-run, dooring incidents).
- **Crashes by Time**: Number of crashes by time of day, day of the week, and month of the year.
- **Crashes in Work Zones**: Number of crashes occurring in construction work zones.

### 2. Geographic Analysis:

- **Crash Locations on Map**: A heat map or pinpoint map of crash locations based on latitude and longitude, showing areas with high crash frequencies.
- **Top 10 Streets/Intersections for Crashes**: Identify streets or intersections with the highest number of crashes.
- **Crashes by Police Beat**: A map breakdown by CPD Beat, showing crash statistics in each area.
- **Road Conditions and Crashes**: Visualize crashes based on road surface conditions, traffic control devices, or street alignment.

### 3. Weather and Lighting Conditions:

- **Crashes by Weather Condition**: Display crashes segmented by weather conditions (e.g., clear, rain, snow, fog).
- **Lighting Conditions at Time of Crash**: Crashes broken down by lighting conditions (e.g., daylight, night, dawn/dusk).

### 4. Vehicle and Unit Information:

- **Vehicle Types Involved in Crashes**: Distribution of vehicle types involved in crashes (e.g., cars, trucks, bicycles, motorcycles, pedestrians).
- **Vehicle Defects**: Display data on vehicles with reported defects at the time of the crash.
- **Vehicle Maneuvers**: Show most common vehicle maneuvers prior to crashes (e.g., turning, merging, going straight).

### 5. Injury and Fatality Analysis:

- **Total Injuries and Fatalities**: Visualize the total number of injuries and fatalities resulting from crashes.
- **Injury Severity Breakdown**: Show breakdowns of injuries by severity classification (e.g., fatal, incapacitating, non-incapacitating).
- **Injuries by Road User Type**: Compare injuries between drivers, passengers, pedestrians, and cyclists.
- **Crash Types Leading to Most Injuries/Fatalities**: Identify crash types that result in the most severe outcomes.

### 6. Driver and Pedestrian Behavior:

- **Driver Actions Leading to Crashes**: Display contributing driver actions leading to crashes (e.g., speeding, distracted driving, failure to yield).
- **Pedestrian and Cyclist Actions**: Analyze pedestrian or cyclist actions at the time of the crash (e.g., crossing mid-block, using crosswalks).

### 7. Traffic Violations and Contributing Causes:

- **Primary and Secondary Causes of Crashes**: Analyze the most common primary and secondary contributory causes (e.g., speeding, DUI, weather conditions).
- **Speeding-Related Crashes**: Show data on crashes where vehicles exceeded the speed limit, including posted speed limits in crash areas.
- **Hit-and-Run Analysis**: Visualize data on hit-and-run incidents, including geographic patterns and injury outcomes.

### 8. Emergency Response and Outcomes:

- **EMS Response Times**: Analyze EMS response times to crash scenes and the hospitals victims were taken to.
- **Airbag Deployment and Safety Equipment Usage**: Display data on airbag deployment, seatbelt usage, and other safety measures.

### 9. Temporal Trends:

- **Trends Over Time**: Show long-term trends in crash numbers, injuries, fatalities, and severity.
- **Monthly or Weekly Crash Reports**: Provide an up-to-date look at crash statistics for a selected time frame (e.g., month, quarter, year).

### 10. Filtering and Customization:

- **Filter by Location**: Allow users to filter crash data by a specific neighborhood, street, or police beat.
- **Filter by Date Range**: Enable selection of specific time frames to view crash data trends over a customized period.
- **Filter by Crash Type**: Filter dashboard views based on crash types (e.g., pedestrian crashes, vehicle collisions).

### 11. Safety Insights and Recommendations:

- **Areas with High Fatalities or Severe Injuries**: Highlight dangerous areas with higher occurrences of severe injuries or fatalities.
- **Recommendations Based on Data**: Suggest potential safety improvements based on data, such as improving lighting, signage, or speed enforcement in high-crash areas.

## Columns to Include:

### Crashes
- **CRASH_RECORD_ID**: (Link key across datasets)
- **CRASH_DATE**: (Time-based analysis, crash trends)
- **FIRST_CRASH_TYPE**: (Breakdown of crash types)
- **CRASH_TYPE**: (General crash classification)
- **POSTED_SPEED_LIMIT**: (Speeding-related crashes)
- **PRIM_CONTRIBUTORY_CAUSE**: (Primary cause analysis)
- **SEC_CONTRIBUTORY_CAUSE**: (Secondary cause analysis)
- **MOST_SEVERE_INJURY**: (Injury and fatality analysis)
- **INJURIES_FATAL**: (Injury severity breakdown)
- **INJURIES_INCAPACITATING**: (Injury severity breakdown)
- **INJURIES_NON_INCAPACITATING**: (Injury severity breakdown)
- **INJURIES_REPORTED_NOT_EVIDENT**: (Injury severity breakdown)
- **INJURIES_TOTAL**: (Total injury counts)
- **WORK_ZONE_I**: (Crashes in work zones)
- **WORKERS_PRESENT_I**: (Crashes in work zones)
- **WEATHER_CONDITION**: (Weather and crash conditions)
- **LIGHTING_CONDITION**: (Lighting and crash conditions)
- **ROADWAY_SURFACE_COND**: (Road conditions and crash analysis)
- **TRAFFIC_CONTROL_DEVICE**: (Control device presence)
- **STREET_NO**: (Geographical location)
- **STREET_NAME**: (Geographical location)
- **STREET_DIRECTION**: (Geographical location)
- **LATITUDE**: (Mapping crash locations)
- **LONGITUDE**: (Mapping crash locations)
- **LOCATION**: (Geographical and mapping analysis)
- **TRAFFICWAY_TYPE**: (Roadway type analysis)
- **INTERSECTION_RELATED_I**: (Intersection-related crashes)
- **HIT_AND_RUN_I**: (Hit-and-run analysis)

---

### People Dataset

- **PERSON_ID**: (Unique identifier for people)
- **CRASH_RECORD_ID**: (Link key across datasets)
- **VEHICLE_ID**: (Link to vehicles dataset)
- **PERSON_TYPE**: (Identify whether a person is a pedestrian, driver, cyclist, etc.)
- **SEX**: (Gender-based analysis)
- **AGE**: (Age-based analysis)
- **INJURY_CLASSIFICATION**: (Injury severity by person)
- **HOSPITAL**: (Emergency response)
- **DRIVER_ACTION**: (Driver behavior analysis)
- **PHYSICAL_CONDITION**: (Physical condition at time of crash)
- **PEDPEDAL_ACTION**: (Actions by pedestrians/cyclists)
- **CELL_PHONE_USE**: (Distracted driving/crash causes)
- **EJECTION**: (Ejection from the vehicle, safety analysis)
- **AIRBAG_DEPLOYED**: (Safety equipment analysis)
- **BAC_RESULT**: (Blood alcohol concentration, DUI-related crashes)

---

### Vehicles Dataset


- **CRASH_UNIT_ID**: (Unique identifier for vehicle/unit)
- **CRASH_RECORD_ID**: (Link key across datasets)
- **VEHICLE_ID**: (Link to people dataset)
- **UNIT_NO**: (Identify different units in the same crash)
- **UNIT_TYPE**: (Determine vehicle, pedestrian, cyclist, etc.)
- **NUM_PASSENGERS**: (Understand the number of people in a vehicle)
- **MAKE**: (Vehicle make for potential vehicle-related trends)
- **MODEL**: (Vehicle model for potential vehicle-related trends)
- **VEHICLE_YEAR**: (Analyze crashes involving older vehicles)
- **VEHICLE_DEFECT**: (Analyze vehicle defects contributing to crashes)
- **VEHICLE_TYPE**: (Type of vehicle, e.g., commercial trucks, bicycles, etc.)
- **VEHICLE_USE**: (Normal use of the vehicle)
- **TRAVEL_DIRECTION**: (Analyze directions of travel in crashes)
- **MANEUVER**: (Vehicle maneuvers before crashes, e.g., turning, merging)
- **TOWED_I**: (Whether a vehicle was towed, indicator of crash severity)
- **EXCEED_SPEED_LIMIT_I**: (Speeding-related crashes)
- **OCCUPANT_CNT**: (Number of people in the vehicle)
