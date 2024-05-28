.timer on

CREATE TEMPORARY TABLE A AS (
	SELECT disease_id
	FROM diagnosis
	WHERE patient_id = 9
);
-- SELECT * FROM A;

CREATE TEMPORARY TABLE B (disease_id VARCHAR UNIQUE);

INSERT INTO B SELECT DISTINCT "d3.disease_id" FROM cypher (
    'MATCH (d1:disease {disease_id:59621000})-[:is_a]->(d2:disease)<-[:is_a]-(d3:disease) RETURN d3.disease_id'
) WHERE NOT EXISTS (
    SELECT 1 FROM B WHERE disease_id = "d3.disease_id"
);
INSERT INTO B SELECT DISTINCT "d3.disease_id" FROM cypher (
    'MATCH (d1:disease {disease_id:42343007})-[:is_a]->(d2:disease)<-[:is_a]-(d3:disease) RETURN d3.disease_id'
) WHERE NOT EXISTS (
    SELECT 1 FROM B WHERE disease_id = "d3.disease_id"
);
INSERT INTO B SELECT DISTINCT "d3.disease_id" FROM cypher (
    'MATCH (d1:disease {disease_id:274100004})-[:is_a]->(d2:disease)<-[:is_a]-(d3:disease) RETURN d3.disease_id'
) WHERE NOT EXISTS (
    SELECT 1 FROM B WHERE disease_id = "d3.disease_id"
);
INSERT INTO B SELECT DISTINCT "d3.disease_id" FROM cypher (
    'MATCH (d1:disease {disease_id:14669001})-[:is_a]->(d2:disease)<-[:is_a]-(d3:disease) RETURN d3.disease_id'
) WHERE NOT EXISTS (
    SELECT 1 FROM B WHERE disease_id = "d3.disease_id"
);
INSERT INTO B SELECT DISTINCT "d3.disease_id" FROM cypher (
    'MATCH (d1:disease {disease_id:816082000})-[:is_a]->(d2:disease)<-[:is_a]-(d3:disease) RETURN d3.disease_id'
) WHERE NOT EXISTS (
    SELECT 1 FROM B WHERE disease_id = "d3.disease_id"
);
-- SELECT * FROM B;

CREATE TEMPORARY TABLE C AS (
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