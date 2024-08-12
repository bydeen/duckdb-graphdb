-- Import table
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Brand;

-- CREATE TABLE Customer AS
--     SELECT * FROM read_csv('/home/dbs/Desktop/m2bench/Datasets/ecommerce/table/Customer.csv');

-- CREATE TABLE Product AS
--     SELECT * FROM read_csv('/home/dbs/Desktop/m2bench/Datasets/ecommerce/table/Product.csv');

-- CREATE TABLE Brand AS
--     SELECT * FROM read_csv('/home/dbs/Desktop/m2bench/Datasets/ecommerce/table/Brand.csv');

CREATE TABLE Customer (
    customer_id VARCHAR(20) PRIMARY KEY,
    person_id INT,
    gender CHAR(1),
    date_of_birth DATE,
    zipcode VARCHAR(10),
    city VARCHAR(30),
    county VARCHAR(30),
    state VARCHAR(15)
);

CREATE TABLE Product (
    product_id CHAR(10) PRIMARY KEY,
    title VARCHAR(1000),
    price REAL,
    brand_id INT
);

CREATE TABLE Brand (
    brand_id INT,
    name VARCHAR(40),
    country VARCHAR(20),
    industry VARCHAR(20)
);

COPY Customer FROM '/home/dbs/Desktop/m2bench/Datasets/ecommerce/table/Customer_SF10.csv' DELIMITER '|' CSV HEADER;
COPY Product FROM '/home/dbs/Desktop/m2bench/Datasets/ecommerce/table/Product_SF10.csv' DELIMITER ',' CSV HEADER;
COPY Brand FROM '/home/dbs/Desktop/m2bench/Datasets/ecommerce/table/Brand.csv' DELIMITER ',' CSV HEADER; 

-- CREATE INDEX customer_ci_idx on Customer(customer_id);
-- CREATE INDEX product_pi_idx on Product(product_id);

SELECT * FROM Customer LIMIT 5;
SELECT * FROM Product LIMIT 5;
SELECT * FROM Brand LIMIT 5;

-- Import json
INSTALL json;
LOAD json;

DROP TABLE IF EXISTS "Order";
DROP TABLE IF EXISTS Review;

-- CREATE TABLE "Order" (
--     order_id UUID PRIMARY KEY,
--     customer_id VARCHAR(20),
--     order_date DATE,
--     total_price REAL,
--     order_line STRUCT(
--         product_id CHAR(10),
--         title VARCHAR(1000),
--         price REAL
--     )[],
-- );
-- COPY "Order" FROM '/home/dbs/Desktop/m2bench/Datasets/ecommerce/json/order.json';

-- CREATE TABLE Review (
--     order_id UUID,
--     product_id CHAR(10),
--     rating INT,
--     feedback VARCHAR(1000)
-- );
-- COPY Review FROM '/home/dbs/Desktop/m2bench/Datasets/ecommerce/json/Review.json';

CREATE TABLE "Order" AS 
    SELECT * FROM read_json_auto('/home/dbs/Desktop/m2bench/Datasets/ecommerce/json/order_SF10.json', format = 'newline_delimited');

CREATE TABLE Review AS
    SELECT * FROM read_json_auto('/home/dbs/Desktop/m2bench/Datasets/ecommerce/json/review_SF10.json', format = 'newline_delimited');

SELECT * FROM "Order" LIMIT 5;
SELECT * FROM Review LIMIT 5;