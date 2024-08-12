SET threads TO 1;
SET memory_limit = '20GB';

DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;

.timer on

CREATE TABLE A AS (
	SELECT Customer.person_id
	FROM "order", Review, Customer
	WHERE Review.product_id = 'B007SYGLZO0'
		AND Review.order_id = "order".order_id
		AND "order".order_date <= '2021-06-01'
		AND "order".order_date >= '2020-06-01'
		AND "order".customer_id = Customer.customer_id
		AND Customer.gender = 'F'
);
-- SELECT * FROM A;

CREATE TABLE B AS (
	SELECT "p1.person_id" AS p1, "t.tag_id" AS t
	FROM cypher (
        'MATCH (p1:Person)-[:Follows]->(:Person)-[:Interested_in]->(t:Hashtag) WHERE p1.person_id IN sql(SELECT * FROM A) RETURN p1.person_id, t.tag_id'
	)
);
SELECT COUNT(*) FROM B;
