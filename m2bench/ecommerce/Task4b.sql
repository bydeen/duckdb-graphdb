SET threads TO 1;
SET memory_limit = '20GB';

DROP TABLE IF EXISTS C;

.timer on

CREATE TABLE C AS
SELECT DISTINCT "t.tag_id" AS tag_id
FROM cypher (
    'MATCH (p1:Person)-[r:Interested_in]->(t:Hashtag) WHERE p1.person_id IN sql(SELECT * FROM B) RETURN t.tag_id'
);

SELECT COUNT(DISTINCT tag_id) AS tag_id
FROM C;