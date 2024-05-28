DROP TABLE IF EXISTS A;

.timer on

CREATE TABLE A AS (
	SELECT Customer.person_id
	FROM "order", Review, Customer
	WHERE Review.product_id = 'B007SYGLZO'
		AND Review.order_id = "order".order_id
		AND "order".order_date <= '2021-06-01'
		AND "order".order_date >= '2020-06-01'
		AND "order".customer_id = Customer.customer_id
		AND Customer.gender = 'F'
);
-- SELECT * FROM A;

SELECT COUNT(*)
FROM cypher (
        'MATCH (p1:person)-[r:follows]->(p2:person) WHERE p1.person_id IN sql(SELECT * FROM A) RETURN p1.person_id'
)
-- WHERE CAST("p1.person_id" AS INTEGER) IN (SELECT person_id FROM A)