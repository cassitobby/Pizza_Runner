SELECT * FROM customer_orders;
SELECT * FROM runner_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes LIMIT 5;
SELECT * FROM pizza_toppings LIMIT 5;
SELECT * FROM runner_orders;
SELECT * FROM runners LIMIT 5;

CREATE TEMP TABLE cust_order AS( 
	SELECT order_id, customer_id, pizza_id,
	CASE
		WHEN exclusions = '' OR exclusions = 'null' THEN null
		ELSE exclusions
		END AS exclusions,
	CASE
		WHEN extras = '' or extras = 'null' THEN null
		ELSE extras
		END AS extras,
	order_time
	FROM customer_orders
)

SELECT * FROM cust_order;

CREATE TEMP TABLE runner_order AS (
	SELECT order_id, runner_id,
	CASE
		WHEN pickup_time = 'null' THEN null
		ELSE pickup_time
		END AS pickup_time,
	CASE 
		WHEN distance = 'null' THEN null
		WHEN distance like '%km' THEN TRIM('km' FROM distance)
		ELSE distance
		END AS distance,
	CASE
		WHEN duration = 'null' THEN null
		WHEN duration LIKE '%min%' THEN TRIM('minutes' FROM duration)
		ELSE duration
		END AS duration,
	CASE 
		WHEN cancellation = '' OR cancellation = 'null' THEN null
		ELSE cancellation
		END AS cancellation	
	FROM runner_orders
)	
SELECT * FROM runner_order;

ALTER TABLE runner_order
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::timestamp,
ALTER COLUMN distance TYPE float USING distance::float, 
ALTER COLUMN duration TYPE INTEGER USING duration::integer;