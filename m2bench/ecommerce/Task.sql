.timer on

DROP TABLE IF EXISTS A;
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

CREATE TEMPORARY TABLE btemp AS (
    SELECT *
    FROM cypher (
        'MATCH (p2:Person)<-[:follows]-(p1:Person) WHERE p2.person_id IN sql(SELECT person_id FROM A) RETURN p1.person_id'
    )
);
SELECT * FROM btemp;