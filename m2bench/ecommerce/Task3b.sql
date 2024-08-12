SET threads TO 1;
SET memory_limit = '20GB';

DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;

.timer on

CREATE TABLE A AS (
        SELECT person_id
        FROM Customer
        WHERE customer_id = (
                SELECT customer_id
                FROM (
                        SELECT customer_id AS customer_id, SUM(total_price) AS order_price
                        FROM "order"
                        WHERE order_date = '2018-07-07'
                        GROUP BY customer_id
                        ORDER BY order_price DESC
                        LIMIT 1
                ) AS cid
        )
);
-- SELECT * FROM A;

CREATE TABLE B AS (
    SELECT "p1.person_id" AS person_id
    FROM cypher (
        'MATCH (p2:Person)-[:Follows]->(:Person)<-[r:Follows]-(p1:Person) WHERE p2.person_id IN sql(SELECT person_id FROM A) RETURN p1.person_id'
    )
);
SELECT COUNT(*) FROM B;