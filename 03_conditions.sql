-- PROJECT: Healthcare Data Management and Exploratory Analysis Using PostgreSQL
-- DATABASE: healthcare_analytics
-- TABLE: conditions
-- PURPOSE: Import, clean and validate condition data

-- SECTION 1: CREATE CONDITIONS STAGING TABLE
CREATE TABLE conditions_staging(
start TEXT, stop TEXT, patient TEXT, encounter TEXT, system TEXT, code TEXT,description TEXT
);

-- SECTION 2: CREATE FINAL CONDITIONS TABLE
CREATE TABLE conditions(
start_date DATE, stop_date DATE, patient_id UUID, encounter_id UUID, system VARCHAR(100),
code VARCHAR(50), description TEXT
);

-- SECTION 3: TRANSFORM AND INSERT DATA
INSERT INTO conditions(
start_date, stop_date, patient_id, encounter_id, system, code, description
)
SELECT 
NULLIF(TRIM(start),'')::DATE,
NULLIF(TRIM(stop),'')::DATE,
NULLIF(TRIM(patient),'')::UUID,
NULLIF(TRIM(encounter),'')::UUID,
NULLIF(TRIM(system),''),
NULLIF(TRIM(code),''),
NULLIF(TRIM(description),'')
FROM conditions_staging;

-- SECTION 4: CHECK FOR DUPLICATE CONDITION RECORDS
SELECT 
start_date, stop_date, patient_id, encounter_id, system, code, description,
COUNT(*)
FROM conditions 
GROUP BY 
start_date, stop_date, patient_id, encounter_id, system, code, description
HAVING COUNT(*) > 1;
-- RESULT: 0 Duplicate condition records

-- SECTION 5: CHECK FOR MISSING VALUES
SELECT 
COUNT(*) FILTER (WHERE start_date IS NULL) AS missing_start,
COUNT(*) FILTER (WHERE stop_date IS NULL) AS missing_stop,
COUNT(*) FILTER (WHERE patient_id IS NULL) AS missing_patient_id,
COUNT(*) FILTER (WHERE encounter_id IS NULL) AS missing_encounter_id,
COUNT(*) FILTER (WHERE system IS NULL) AS missing_system,
COUNT(*) FILTER (WHERE code IS NULL) AS missing_code,
COUNT(*) FILTER (WHERE description IS NULL) AS missing_description
FROM conditions;
-- RESULT: 
-- Missing start_date: 909
-- All remaining columns: 0 missing values
-- Missing values were retained as NULL

-- SECTION 6: VERIFY TOTAL CONDITIONS RECORDS
SELECT COUNT(*) AS total_conditions
FROM conditions;
-- RESULT: 3,387 condition records
