SET threads TO 1;
SET memory_limit = '20GB';

DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;

.timer on

CREATE TABLE A AS (
    SELECT person_id
    FROM Customer, (
        SELECT temp.customer_id AS customer_id, SUM((temp.price)::FLOAT) AS total_spent
        FROM Product, Brand, (
            SELECT customer_id AS customer_id,
                UNNEST(order_line).product_id AS product_id,
                UNNEST(order_line).price AS price
            FROM "order"
        ) AS temp
        WHERE Brand.industry = 'Leisure'
            AND Product.brand_id = Brand.brand_id
            AND temp.product_id = Product.product_id
        GROUP BY customer_id
        HAVING SUM((temp.price)::FLOAT) > 10000
    ) AS atemp
    WHERE atemp.customer_id = Customer.customer_id
);
-- SELECT * FROM A LIMIT 5;

CREATE TABLE B AS 
SELECT "p2.person_id" AS person_id, COUNT(*) AS cnt
FROM cypher (
        'MATCH (p2:Person)<-[r:Follows]-(p1:Person) WHERE p2.person_id IN sql(SELECT person_id FROM A) RETURN p2.person_id'
)
GROUP BY person_id
ORDER BY cnt DESC
LIMIT 10;
-- SELECT * FROM B;