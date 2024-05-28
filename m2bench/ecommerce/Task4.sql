DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;

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

CREATE TABLE B AS 
SELECT "p2.person_id" AS person_id, COUNT(*) AS cnt
FROM cypher (
        'MATCH (p2:person)<-[r:follows]-(p1:person) WHERE p2.person_id IN sql(SELECT person_id FROM A) RETURN p2.person_id'
)
GROUP BY person_id
ORDER BY cnt DESC
LIMIT 10;
-- SELECT * FROM B;

CREATE TEMPORARY TABLE ctemp AS
SELECT "t.tag_id" AS tag_id
FROM cypher (
    'MATCH (p1:person)-[r:Interested_in]->(t:hashtag) WHERE p1.person_id IN sql(SELECT * FROM B) RETURN t.tag_id'
);

SELECT COUNT(*) AS tag_id
FROM ctemp;