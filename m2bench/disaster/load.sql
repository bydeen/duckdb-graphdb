INSTALL spatial;
LOAD spatial;

-- Import table
DROP TABLE IF EXISTS Earthquake;
DROP TABLE IF EXISTS Shelter;
DROP TABLE IF EXISTS Gps;

CREATE TABLE Earthquake (
    earthquake_id INT PRIMARY KEY,
    time TIMESTAMP,
    coordinates GEOMETRY,
    latitude FLOAT,
    longitude FLOAT,
    depth FLOAT,
    magnitude FLOAT
);

CREATE TABLE Shelter (
    shelter_id INT PRIMARY KEY,
    site_id INT,
    capacity FLOAT,
    name  CHAR(100)
);

CREATE TABLE Gps (
    gps_id INT PRIMARY KEY,
    user_id INT,
    coordinates GEOMETRY,
    longitude FLOAT,
    latitude FLOAT,
    time TIMESTAMP
);

COPY Earthquake(earthquake_id, time, latitude, longitude, depth, magnitude) FROM '${DATASET_PATH}/disaster/table/Earthquake.csv' DELIMITER ',' CSV HEADER;
UPDATE Earthquake set coordinates = ST_GeomFromText('POINT(' ||  longitude || ' ' || latitude || ')');
ALTER TABLE Earthquake DROP COlUMN latitude CASCADE;
ALTER TABLE Earthquake DROP COlUMN longitude CASCADE;

COPY Shelter FROM '${DATASET_PATH}/disaster/table/Shelter.csv' DELIMITER '|' CSV HEADER;

COPY Gps(gps_id, user_id, longitude, latitude, time) FROM '${DATASET_PATH}/disaster/table/Gps.csv' DELIMITER ',' CSV HEADER;
UPDATE Gps set coordinates = ST_GeomFromText('POINT(' ||  longitude || ' ' || latitude || ')');
ALTER TABLE Gps DROP COlUMN latitude CASCADE;
ALTER TABLE Gps DROP COlUMN longitude CASCADE;

SELECT * FROM Earthquake LIMIT 5;
SELECT * FROM Shelter LIMIT 5;
SELECT * FROM Gps LIMIT 5;

-- Import json
INSTALL json;
LOAD json;

DROP TABLE IF EXISTS "Site";
DROP TABLE IF EXISTS Site_centroid;

-- CREATE TABLE "Site" (

-- );
-- COPY "Site" FROM '${DATASET_PATH}/disaster/json/Site.json';

CREATE TABLE "Site" AS 
    SELECT * FROM read_json_auto('${DATASET_PATH}/disaster/json/Site.json', format = 'newline_delimited', ignore_errors = true);

SELECT * FROM "Site" LIMIT 5;