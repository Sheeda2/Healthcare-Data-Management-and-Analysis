-- PROJECT: Healthcare Data Management and Exploratory Analysis Using PostgreSQL
-- DATABASE: healthcare_analytics
-- TABLE: observations
-- PURPOSE: Import, Clean, and validate observation data

-- SECTION 1: CREATE OBSERVATIONS STAGING TABLE
CREATE TABLE observation_staging(
date TEXT, patient TEXT, encounter TEXT, category TEXT, code TEXT, description TEXT,
value TEXT, unit TEXT, type TEXT
);

-- SECTION 2: CREATE FINAL OBSERVATION TABLE
CREATE TABLE observations(
observation_date DATE, patient_id UUID, encounter_id UUID, category VARCHAR(100),
code VARCHAR(50), description TEXT, value TEXT, unit VARCHAR(50), type VARCHAR(50)
);

-- SECTION 3: INSERT AND TRANSFORM OBSERVATION DATA
INSERT INTO observations(
observation_date, patient_id, encounter_id, category, code, description, value,
unit, type
)
SELECT
NULLIF(TRIM(date),'')::DATE,
NULLIF(TRIM(patient),'')::UUID,
NULLIF(TRIM(encounter),'')::UUID,
NULLIF(TRIM(category),''),
NULLIF(TRIM(code),''),
NULLIF(TRIM(description),''),
NULLIF(TRIM(value),''),
NULLIF(TRIM(unit),''),
NULLIF(TRIM(type),'')
FROM observation_staging;

-- SECTION 4: CHECK FOR DUPLICATES
SELECT 
observation_date, patient_id, encounter_id, category, code, description, value, unit, type,
COUNT(*) AS record_count
FROM observations
GROUP BY 
observation_date, patient_id, encounter_id, category, code, description, value,
unit, type 	
HAVING COUNT(*) >1;
-- RESULT:
-- 69 duplicates were found
-- Each group contains 2 records (138 records involved)
-- duplicate records were retained pending review.

-- SECTION 5: CHECK FOR MISSING VALUES
SELECT 
COUNT(*) FILTER (WHERE observation_date IS NULL) AS missing_date,
COUNT(*) FILTER (WHERE patient_id IS NULL) AS missing_patient_id,
COUNT(*) FILTER (WHERE encounter_id IS NULL) AS missing_encounter_id,
COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
COUNT(*) FILTER (WHERE code IS NULL) AS missing_code,
COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
COUNT(*) FILTER (WHERE value IS NULL) AS missing_value,
COUNT(*) FILTER (WHERE unit IS NULL) AS missing_unit,
COUNT(*) FILTER (WHERE type IS NULL) AS missing_type
FROM observations;
-- RESULT:
-- Missing encounter_id: 3,060
-- Missing category: 3,060
-- Missing unit: 16,513
-- All remaining columns: 0 missing values
-- Missing values were retained as NULL

-- SECTION 6: VERIFY FINAL RECORD COUNT
SELECT COUNT(*) AS total_observation_records FROM observations;
-- RESULT: 53,961 observation records.