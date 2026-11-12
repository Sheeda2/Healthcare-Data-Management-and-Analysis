-- PROJECT: Healthcare Data Management and Exploratory Analysis Using PostgreSQL
-- DATABASE: healthcare_analytics
-- TABLE: Patients
-- DATASET: Synthea Synthetic Patient Records

-- SECTION 1: Creating the staging table
CREATE TABLE patients_staging( id TEXT, birthdate TEXT,
deathdate TEXT, ssn TEXT, drivers TEXT, passport TEXT,
prefix TEXT, first TEXT, middle TEXT,last TEXT,
suffix TEXT, maiden TEXT, marital TEXT, race TEXT, ethnicity
TEXT, gender TEXT, birthplace TEXT, address TEXT, city TEXT,
state TEXT, county TEXT, fips TEXT, zip TEXT, lat TEXT, lon TEXT,
healthcare_expenses TEXT, healthcare_coverage TEXT, income TEXT);

-- SECTION 2: Creating the final patients table
CREATE TABLE patients(
id UUID PRIMARY KEY, birthdate DATE, deathdate DATE,
marital VARCHAR(20), race VARCHAR(50),ethnicity VARCHAR(50),
gender VARCHAR(20), birthplace VARCHAR(150), city VARCHAR(100),
state VARCHAR(100), county VARCHAR(100), healthcare_expenses NUMERIC(12,2),
healthcare_coverage NUMERIC(12,2), income INTEGER);

-- SECTION 3: Transfer data into the final patients table
INSERT INTO patients (id,birthdate,deathdate,marital,race,ethnicity,
gender, birthplace,city, state,county,healthcare_expenses,healthcare_coverage,
income)
SELECT
NULLIF(TRIM(id),'')::UUID,
NULLIF(TRIM(birthdate), '')::DATE,
NULLIF(TRIM(deathdate),'')::DATE,
NULLIF(TRIM(marital), ''),
NULLIF(TRIM(race),''),
NULLIF(TRIM(ethnicity),''),
NULLIF(TRIM(gender), ''),
NULLIF(TRIM(birthplace),''),
NULLIF(TRIM(city),''),
NULLIF(TRIM(state),''),
NULLIF(TRIM(county),''),
NULLIF(TRIM(healthcare_expenses),'')::NUMERIC(12,2),
NULLIF(TRIM(healthcare_coverage),'')::NUMERIC(12,2),
NULLIF(TRIM(income),'')::INTEGER
FROM patients_staging;

-- SECTION 4: Check for duplicate patient records
SELECT id, COUNT(*)
FROM patients
GROUP BY id
HAVING COUNT(*)>1;
-- RESULT: 0 Duplicate Patient IDs

-- SECTION 5: Check for missing values
SELECT
COUNT(*) FILTER (WHERE id IS NULL) AS missing_id,
COUNT(*) FILTER (WHERE birthdate IS NULL) AS missing_birthdate,
COUNT(*) FILTER (WHERE deathdate IS NULL) AS missing_deathdate,
COUNT(*) FILTER (WHERE marital IS NULL) AS missing_marital,
COUNT(*) FILTER (WHERE race IS NULL ) AS missing_race,
COUNT(*) FILTER (WHERE ethnicity IS NULL) AS missing_ethnicity,
COUNT(*) FILTER (WHERE gender IS NULL) AS missing_gender,
COUNT(*) FILTER (WHERE birthplace IS NULL) AS missing_birthplace,
COUNT(*) FILTER (WHERE city IS NULL) AS missing_city,
COUNT(*) FILTER (WHERE state IS NULL) AS missing_state,
COUNT(*) FILTER (WHERE county IS NULL) AS missing_county,
COUNT(*) FILTER (WHERE healthcare_expenses IS NULL) AS missing_expenses,
COUNT(*) FILTER (WHERE healthcare_coverage IS NULL) AS missing_coverage,
COUNT(*) FILTER (WHERE income IS NULL) AS missing_income
FROM patients;
-- RESULT: 
-- Missing deathdate:99
-- Missing marital: 44
-- All remaining columns: 0 missing values
-- Missing values were retained as NULL

-- SECTION 6: Verify final patient record count
SELECT COUNT(*) AS total_patients
FROM patients;
-- RESULT: 111 patient records