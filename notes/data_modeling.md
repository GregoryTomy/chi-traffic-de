# Fact and Dimension Table Design

> Using a full snapshot approach. Update docs.

# Notes: 10/02/2024
- using a full snapshot approach with one master dimension table being appened with each run.
- paritionining in BigQuery using parition date column.
- [CHECK] does providing merge incremental strategy with no condition mimic append behavior?

## 1. Fact Table

The fact table will contain quantifiable data related to each crash event (e.g., injuries, fatalities, crash counts). This is where most of your numerical analysis will occur.

- **Fact Table**: `FactCrashes`
  - **Primary Key**: `CRASH_RECORD_ID` (links to dimension tables)
  - **Attributes**:
    - `CRASH_DATE`: Date and time of the crash
    - `CRASH_TYPE`: General crash classification
    - `FIRST_CRASH_TYPE`: Type of first collision
    - `POSTED_SPEED_LIMIT`: Speed limit at crash location
    - `MOST_SEVERE_INJURY`: Most severe injury in the crash
    - `INJURIES_FATAL`: Total fatal injuries
    - `INJURIES_INCAPACITATING`: Total incapacitating injuries
    - `INJURIES_NON_INCAPACITATING`: Total non-incapacitating injuries
    - `INJURIES_REPORTED_NOT_EVIDENT`: Total reported, but not evident injuries
    - `INJURIES_TOTAL`: Total injuries
    - `WEATHER_CONDITION`: Weather at the time of the crash
    - `LIGHTING_CONDITION`: Lighting condition at crash time
    - `ROADWAY_SURFACE_COND`: Road condition at crash time
    - `HIT_AND_RUN_I`: Indicator of hit-and-run
  - **Foreign Keys**:
    - `VEHICLE_ID`: Link to `DimVehicles`
    - `PERSON_ID`: Link to `DimPeople`
    - `WORK_ZONE_I`: Link to `DimWorkZone`

This table will provide the foundation for aggregating crash-related statistics.

---

## 2. Dimension Tables

The dimension tables will provide descriptive context for the fact data. These will store non-quantifiable attributes like vehicle details, people information, locations, etc.

### Dimension Table: `DimVehicles`

- **Primary Key**: `VEHICLE_ID`
- **Attributes**:
  - `UNIT_TYPE`: Type of vehicle/unit (e.g., car, pedestrian, cyclist)
  - `MAKE`: Vehicle make
  - `MODEL`: Vehicle model
  - `VEHICLE_YEAR`: Year of the vehicle
  - `NUM_PASSENGERS`: Number of passengers
  - `TRAVEL_DIRECTION`: Direction the vehicle was traveling
  - `MANEUVER`: Action or maneuver taken by the vehicle before the crash
  - `TOWED_I`: Whether the vehicle was towed
  - `EXCEED_SPEED_LIMIT_I`: Whether the vehicle was speeding
  - `OCCUPANT_CNT`: Number of people in the vehicle

This table gives detailed information about the vehicles or other units involved in the crash.

---

### Dimension Table: `DimPeople`

- **Primary Key**: `PERSON_ID`
- **Attributes**:
  - `PERSON_TYPE`: Type of person (e.g., driver, passenger, pedestrian)
  - `AGE`: Age of the person
  - `SEX`: Gender of the person
  - `INJURY_CLASSIFICATION`: Severity of injuries sustained
  - `DRIVER_ACTION`: Driver actions contributing to the crash
  - `PHYSICAL_CONDITION`: Driver’s physical condition at the time of the crash
  - `PEDPEDAL_ACTION`: Pedestrian or cyclist action at the time of the crash
  - `CELL_PHONE_USE`: Whether the person was using a cell phone
  - `AIRBAG_DEPLOYED`: Whether airbags were deployed
  - `EJECTION`: Whether the person was ejected from the vehicle

This table helps analyze the demographics and behaviors of the people involved in the crash.

---

### Dimension Table: `DimLocation`

- **Primary Key**: `LOCATION_ID`
- **Attributes**:
  - `STREET_NO`: Street number of crash location
  - `STREET_NAME`: Street name of crash location
  - `STREET_DIRECTION`: Street direction
  - `LATITUDE`: Latitude for mapping
  - `LONGITUDE`: Longitude for mapping
  - `TRAFFICWAY_TYPE`: Type of roadway where the crash occurred
  - `TRAFFIC_CONTROL_DEVICE`: Traffic control devices present
  - `INTERSECTION_RELATED_I`: Whether the crash was related to an intersection

This table is essential for geographic analysis, helping you map crashes and identify patterns based on location data.

---

### Dimension Table: `DimWorkZone`

- **Primary Key**: `WORK_ZONE_ID`
- **Attributes**:
  - `WORK_ZONE_I`: Whether the crash occurred in a work zone
  - `WORKERS_PRESENT_I`: Whether workers were present at the crash site

This table helps focus on crashes that occurred in work zones, along with the presence of workers.

---

## Bridge Tables

Bridge tables can help manage many-to-many relationships. For instance, a crash can involve multiple vehicles, and a vehicle can involve multiple people.

### Bridge Table: `BridgeCrashVehicle`

- **Primary Key**: Composite key (`CRASH_RECORD_ID`, `VEHICLE_ID`)
- **Attributes**:
  - `CRASH_RECORD_ID`: Links to `FactCrashes`
  - `VEHICLE_ID`: Links to `DimVehicles`

---

### Bridge Table: `BridgeVehiclePerson`

- **Primary Key**: Composite key (`VEHICLE_ID`, `PERSON_ID`)
- **Attributes**:
  - `VEHICLE_ID`: Links to `DimVehicles`
  - `PERSON_ID`: Links to `DimPeople`

These bridge tables allow the flexibility to manage multiple vehicles and people involved in a single crash without duplicating data.

---

## Final Schema Overview:

- **Fact Table**: `FactCrashes`
- **Dimension Tables**:
  - `DimVehicles`
  - `DimPeople`
  - `DimLocation`
  - `DimWorkZone`
- **Bridge Tables**:
  - `BridgeCrashVehicle`
  - `BridgeVehiclePerson`
