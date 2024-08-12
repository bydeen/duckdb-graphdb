SET threads TO 1;
SET memory_limit = '20GB';

DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;

.timer on

CREATE TABLE A AS (
	SELECT disease_id
	FROM diagnosis
	WHERE patient_id = 9
);
-- SELECT * FROM A;

CREATE TABLE B AS (
	SELECT DISTINCT("d3.disease_id")::TEXT::BIGINT AS disease_id
	FROM cypher(
		'MATCH (d1:disease)-[:is_a]->(d2:disease)<-[:is_a]-(d3:disease)-[:is_a]->(d4:disease) WHERE d1.disease_id IN sql(SELECT disease_id FROM A)
		RETURN d3.disease_id'
	) 
);

CREATE TABLE C AS (
	SELECT DISTINCT(patient_id) AS patient_id
	FROM diagnosis, B
	WHERE diagnosis.disease_id = B.disease_id
		AND diagnosis.patient_id != 9
		AND CAST(B.disease_id AS BIGINT) NOT IN (SELECT * FROM A)
);

SELECT gender, COUNT(gender)
FROM patient, C
WHERE patient.patient_id = C.patient_id
GROUP BY gender;