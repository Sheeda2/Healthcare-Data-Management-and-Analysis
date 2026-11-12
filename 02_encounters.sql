-- PROJECT: Healthcare Data Management and Exploratory Analysis Using PostgreSQL
-- DATABASE: healthcare_analytics
-- TABLE: encounters
-- PURPOSE: Import, clean and validate encounter data

-- SECTION 1: CREATE ENCOUNTERS STAGING TABLE
CREATE TABLE encounters_staging_import(
id TEXT, start TEXT, stop TEXT, patient TEXT, organization TEXT,
provider TEXT, payer TEXT, encounter_class TEXT, code TEXT, description
TEXT, base_encounter_cost TEXT, total_claim_cost TEXT, payer_coverage TEXT,
reason_code TEXT, reason_description TEXT
);

-- SECTION 2: CREATE FINAL ENCOUNTERS TABLE
CREATE TABLE encounters(
id UUID PRIMARY KEY,
encounter_start TIMESTAMP,
encounter_stop TIMESTAMP,
patient_id UUID,
organization_id UUID,
provider_id UUID,
payer_id UUID, 
encounter_class VARCHAR(50),
code VARCHAR(50),
description TEXT,
base_encounter_cost NUMERIC(12,2),
total_claim_cost NUMERIC(12,2),
payer_coverage NUMERIC(12,2),
reason_code VARCHAR(50),
reason_description TEXT
);

-- SECTION 3: TRANSFORM AND INSERT DATA
INSERT INTO encounters(
id, encounter_start, encounter_stop, patient_id, organization_id, provider_id,
encounter_class, code, description, base_encounter_cost, total_claim_cost,
payer_coverage, reason_code, reason_description, payer_id
)
SELECT
NULLIF(TRIM(id),'')::UUID,
NULLIF(TRIM(start),'')::TIMESTAMP,
NULLIF(TRIM(stop),'')::TIMESTAMP,
NULLIF(TRIM(patient),'')::UUID,
NULLIF(TRIM(organization),'')::UUID,
NULLIF(TRIM(provider),'')::UUID,
NULLIF(TRIM(encounter_class),''),
NULLIF(TRIM(code),''),
NULLIF(TRIM(description),''),
NULLIF(TRIM(base_encounter_cost),'')::NUMERIC(12,2),
NULLIF(TRIM(total_claim_cost),'')::NUMERIC(12,2),
NULLIF(TRIM(payer_coverage),'')::NUMERIC(12,2),
NULLIF(TRIM(reason_code),''),
NULLIF(TRIM(reason_description),''),
NULLIF(TRIM(payer),'')::UUID
FROM encounters_staging_import;

-- SECTION 4: CHECK FOR DUPLICATE ENCOUNTER IDs
SELECT id, COUNT(*)
FROM encounters
GROUP BY id
HAVING COUNT(*)>1;
-- RESULT: 0 Duplicate encounter IDs

-- SECTION 5: CHECK FOR MISSING VALUES
SELECT
COUNT(*) FILTER (WHERE id IS NULL) AS missing_id,
COUNT(*) FILTER (WHERE encounter_start IS NULL) AS missing_start,
COUNT(*) FILTER (WHERE encounter_stop IS NULL) AS missing_stop,
COUNT(*) FILTER (WHERE patient_id IS NULL) AS missing_patient_id,
COUNT(*) FILTER (WHERE organization_id IS NULL) AS missing_organization_id,
COUNT(*) FILTER (WHERE provider_id IS NULL) AS missing_provider_id,
COUNT(*) FILTER (WHERE payer_id IS NULL) AS missing_payer_id,
COUNT(*) FILTER (WHERE encounter_class IS NULL) AS missing_encounter_class,
COUNT(*) FILTER (WHERE code IS NULL) AS missing_code,
COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
COUNT(*) FILTER (WHERE base_encounter_cost IS NULL) AS missing_base_encounter_cost,
COUNT(*) FILTER (WHERE total_claim_cost IS NULL) AS missing_total_claim_cost,
COUNT(*) FILTER (WHERE payer_coverage IS NULL) AS missing_payer_coverage,
COUNT(*) FILTER (WHERE reason_code IS NULL) AS missing_reason_code,
COUNT(*) FILTER (WHERE reason_description IS NULL) AS missing_reason_description
FROM encounters;
-- RESULT: 
-- Missing reason_code: 1,827
-- Missing reason_description:1,827
-- All other columns: 0 missing values
-- Missing reason information was retained as NULL

-- SECTION 6: VERIFY TOTAL ENCOUNTER RECORDS
SELECT COUNT(*) AS total_encounters
FROM encounters;
-- RESULT: 5,059 encounter records