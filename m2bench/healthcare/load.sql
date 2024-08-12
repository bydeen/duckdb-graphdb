DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Diagnosis;
DROP TABLE IF EXISTS Prescription;

CREATE TABLE Patient (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50),
    gender CHAR(1),
    date_of_birth DATE,
    date_of_death DATE
);

CREATE TABLE Diagnosis (
    patient_id INT,
    disease_id BIGINT
);

CREATE TABLE Prescription (
    patient_id INT,
    drug_id INT,
    startdate DATE,
    enddate DATE
);

COPY Patient FROM '/home/dbs/Desktop/m2bench/Datasets/healthcare/table/Patient.csv' DELIMITER ',' CSV HEADER;
COPY Diagnosis FROM '/home/dbs/Desktop/m2bench/Datasets/healthcare/table/Diagnosis.csv' DELIMITER ',' CSV HEADER;
COPY Prescription FROM '/home/dbs/Desktop/m2bench/Datasets/healthcare/table/Prescription.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM Patient LIMIT 5;
SELECT * FROM Diagnosis LIMIT 5;
SELECT * FROM Prescription LIMIT 5;

-- Import json
INSTALL json;
LOAD json;

DROP TABLE IF EXISTS Drug;

CREATE TABLE Drug AS
    SELECT * FROM read_json_auto('/home/dbs/Desktop/m2bench/Datasets/healthcare/json/drug.json', format = 'newline_delimited');

SELECT * FROM Drug LIMIT 5;