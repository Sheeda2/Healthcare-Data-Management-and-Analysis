-- PROJECT: Healthcare Data Management and Exploratory Analysis Using PostgreSQL
-- DATABASE: healthcare_analytics
-- TABLE: medications
-- PURPOSE: Import, clean and validate medication data

-- SECTION 1: CREATE MEDICATION STAGING TABLE
CREATE TABLE medications_staging(
start TEXT, stop TEXT, patient TEXT, payer TEXT, encounter TEXT, code TEXT,
description TEXT, base_cost TEXT, payer_coverage TEXT, dispenses TEXT, total_cost
TEXT, reason_code TEXT, reason_description TEXT
);

-- SECTION 2: CREATE FINAL MEDICATIONS TABLE
CREATE TABLE medications(
start_date DATE, stop_date DATE, patient_id UUID, payer_id UUID, encounter_id UUID,
code VARCHAR(50), description TEXT, base_cost NUMERIC(12,2),
payer_coverage NUMERIC(12,2), dispenses NUMERIC(12,2), total_cost NUMERIC(12,2),
reason_code VARCHAR(50), reason_description TEXT
);

-- SECTION 3: INSERT AND TRANSFORM DATA
INSERT INTO medications(
start_date, stop_date, patient_id, payer_id, encounter_id, code, description,
base_cost, payer_coverage, dispenses, total_cost, reason_code, reason_description
)
SELECT
NULLIF(TRIM(start),'')::DATE,
NULLIF(TRIM(stop),'')::DATE,
NULLIF(TRIM(patient),'')::UUID,
NULLIF(TRIM(payer),'')::UUID,
NULLIF(TRIM(encounter),'')::UUID,
NULLIF(TRIM(code),''),
NULLIF(TRIM(description),''),
NULLIF(TRIM(base_cost),'')::NUMERIC(12,2),
NULLIF(TRIM(payer_coverage),'')::NUMERIC(12,2),
NULLIF(TRIM(dispenses),'')::NUMERIC(12,2),
NULLIF(TRIM(total_cost),'')::numeric(12,2),
NULLIF(TRIM(reason_code),''),
NULLIF(TRIM(reason_description),'')
FROM medications_staging;

-- SECTION 4: CHECK FOR DUPLICATE MEDICATION RECORDS
SELECT
start_date, stop_date, patient_id, payer_id, encounter_id, code, description,
base_cost, payer_coverage, dispenses, total_cost, reason_code, reason_description,
COUNT(*)
FROM medications
GROUP BY
start_date, stop_date, patient_id, payer_id, encounter_id, code, description,
base_cost, payer_coverage, dispenses, total_cost, reason_code,reason_description
HAVING COUNT(*) >1;
-- RESULT: 
-- 10 Duplicate groups were identified
-- Each group contains 2 records (20 records involved)
-- Duplicate records were retained pending review

-- SECTION 5: CHECK FOR MISSING VALUES
SELECT 
COUNT(*) FILTER (WHERE start_date IS NULL) AS missing_start,
COUNT(*) FILTER (WHERE stop_date IS NULL) AS missing_stop,
COUNT(*) FILTER (WHERE patient_id IS NULL) AS missing_patient_id,
COUNT(*) FILTER (WHERE payer_id IS NULL) AS missing_payer_id,
COUNT(*) FILTER (WHERE encounter_id IS NULL) AS missing_encounter_id,
COUNT(*) FILTER (WHERE code IS NULL) AS missing_code,
COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
COUNT(*) FILTER (WHERE base_cost IS NULL) AS missing_base_cost,
COUNT(*) FILTER (WHERE payer_coverage IS NULL) AS missing_payer_coverage,
COUNT(*) FILTER (WHERE dispenses IS NULL) AS missing_dispenses,
COUNT(*) FILTER (WHERE total_cost IS NULL) AS missing_total_cost,
COUNT(*) FILTER (WHERE reason_code IS NULL) AS missing_reason_code,
COUNT(*) FILTER (WHERE reason_description IS NULL) AS missing_reason_description
FROM medications;
-- RESULT:
-- Missing stop_date: 241
-- Missing reason_code: 944
-- Missing reason_description: 944
-- All remaining columns: 0 missing values
-- Missing values were retained as NULL

-- SECTION 6: VERIFY FINAL RECORD COUNT
SELECT COUNT(*) AS total_medications
FROM medications;
-- RESULT: 3,216 medication records