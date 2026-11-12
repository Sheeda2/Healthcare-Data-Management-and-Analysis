-- PROJECT: Healthcare Data Management and Exploratory Analysis Using PostgreSQL
-- DATABASE: healthcare_analytics
-- TABLE: procedures
-- PURPOSE: Import, clean, and validate procedure data

-- SECTION 1: CREATE PROCEDURES STAGING TABLE
CREATE TABLE procedures_staging(
start TEXT, stop TEXT, patient TEXT, encounter TEXT, system TEXT, code TEXT, 
description TEXT, base_cost TEXT, reason_code TEXT, reason_description TEXT
);

-- SECTION 2: CREATE FINAL PROCEDURES TABLE
CREATE TABLE procedures(
start_date DATE, stop_date DATE, patient_id UUID, encounter_id UUID, system VARCHAR(100),
code VARCHAR(50), description TEXT, base_cost NUMERIC(12,2), reason_code VARCHAR(50),
reason_description TEXT
);

-- SECTION 3: INSERT AND TRANSFORM PROCEDURE DATA
INSERT INTO procedures(
start_date, stop_date, patient_id, encounter_id, system, code, description, base_cost,
reason_code, reason_description
)
SELECT
NULLIF(TRIM(start),'')::DATE,
NULLIF(TRIM(stop),''):: DATE,
NULLIF(TRIM(patient),'')::UUID,
NULLIF(TRIM(encounter),'')::UUID,
NULLIF(TRIM(system),''),
NULLIF(TRIM(code),''),
NULLIF(TRIM(description),''),
NULLIF(TRIM(base_cost),'')::NUMERIC(12,2),
NULLIF(TRIM(reason_code),''),
NULLIF(TRIM(reason_description),'')
FROM procedures_staging;

-- SECTION 4: CHECK FOR DUPLICATE PROCEDURE RECORDS
SELECT
start_date, stop_date, patient_id, encounter_id, system, code, description,
base_cost, reason_code, reason_description, COUNT(*) AS record_count
FROM procedures
GROUP BY 
start_date, stop_date, patient_id, encounter_id, system, code, description,
base_cost, reason_code, reason_description
HAVING COUNT(*) > 1;
-- RESULT: 
-- 627 duplicate groups were identified
-- Each group contains 2 records (1,254 records involved)
-- Duplicate records were retained pending review

-- SECTION 5: CHECK FOR MISSING VALUES
SELECT 
COUNT(*) FILTER (WHERE start_date IS NULL) AS missing_start_date,
COUNT(*) FILTER (WHERE stop_date IS NULL) AS missing_stop_date,
COUNT(*) FILTER (WHERE patient_id IS NULL) AS missing_patient_id,
COUNT(*) FILTER (WHERE encounter_id IS NULL) AS missing_encounter_id,
COUNT(*) FILTER (WHERE system IS NULL) AS missing_system,
COUNT(*) FILTER (WHERE code IS NULL) AS missing_code,
COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
COUNT(*) FILTER (WHERE base_cost IS NULL) AS missing_base_cost,
COUNT(*) FILTER (WHERE reason_code IS NULL) AS missing_reason_code,
COUNT(*) FILTER (WHERE reason_description IS NULL) AS missing_reason_description
FROM procedures;
-- RESULT: 
-- Missing reason_code: 7,111
-- Missing reason_description: 7,111
-- All remaining columns: 0 missing values
-- Missing values were retained as NULL

--  SECTION 6: VERIFY FINAL RECORD COUNT
SELECT COUNT(*) AS total_procedures_records
FROM procedures;
-- RESULT: 13,641 procedure records.