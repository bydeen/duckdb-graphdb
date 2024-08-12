SET threads TO 1;
SET memory_limit = '20GB';

DROP TABLE IF EXISTS A;

.timer on

CREATE TABLE A AS (
    SELECT "p1.person_id" AS person_id
    FROM cypher (
        'MATCH (p2:Person)-[r:Follows]->(p1:Person) WHERE p2.person_id IN [26] RETURN p1.person_id'
    )
);
SELECT COUNT(*) FROM A;
