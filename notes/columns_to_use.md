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
