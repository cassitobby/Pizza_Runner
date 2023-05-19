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

							-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

SELECT COUNT(order_id) AS number_of_orders
FROM cust_order

-- 2. How many unique customer orders were made?

SELECT COUNT( DISTINCT order_id) AS unique_orders
FROM cust_order

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*) AS successful_delivery
FROM runner_order
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(*) quantity_ordered
FROM cust_order AS c
INNER JOIN pizza_names AS p
USING (pizza_id)
INNER JOIN runner_order AS r 
USING(order_id)
WHERE cancellation IS NULL
GROUP BY pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT c.customer_id,  p.pizza_name, COUNT(*) AS quantity_purchased
FROM cust_order AS c
LEFT JOIN pizza_names AS p
USING(pizza_id)
GROUP BY c.customer_id, p.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
WITH pizza_count AS (
	SELECT order_id, COUNT(*) AS quantity_order
	FROM cust_order AS c
	LEFT JOIN runner_order AS r
	USING(order_id)
	WHERE cancellation IS NULL
	GROUP BY order_id
	ORDER BY quantity_order DESC
)
SELECT MAX(quantity_order) 
FROM pizza_count;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id,
	   COUNT(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL 
			 THEN 1 END) AS pizza_with_changes,
	   COUNT(CASE WHEN exclusions IS NULL AND extras IS NULL 
			THEN 1 END) AS pizza_without_changes
FROM cust_order AS c
JOIN runner_order AS r
USING(order_id)
WHERE r.cancellation IS NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*)
FROM cust_order AS c
LEFT JOIN runner_order AS r 
USING(order_id)
WHERE exclusions IS NOT NULL 
AND extras IS NOT NULL
AND cancellation IS NULL;


-- 9 What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT('HOUR' FROM order_time) AS hour_of_day, COUNT(*) AS pizza_quantity
FROM cust_order
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 10. What was the volume of orders for each day of the week?

 

						-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
	CASE
		WHEN registration_date BETWEEN '2021-01-01' AND '2021-01-07' THEN 'Week One'
		WHEN registration_date BETWEEN '2021-01-08' AND '2021-01-14' THEN 'Week Two'
		WHEN registration_date BETWEEN '2021-01-15' AND '2021-01-21' THEN 'Week Three'
		ELSE 'Other_weeks'
		END AS registration_week,
	 COUNT(*) AS registration_count
FROM runners
GROUP BY registration_week
ORDER BY registration_count DESC;


						
-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id, AVG(delivery_time) AS avg_delivery_time
FROM
	(SELECT r.runner_id, (r.pickup_time - c.order_time) AS delivery_time
	FROM runner_order AS r
	INNER JOIN cust_order AS c
	USING(order_id)) AS arrival_time
GROUP BY runner_id;

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH time_taken AS
	(SELECT COUNT(*) AS pizza_quantity, (r.pickup_time - c.order_time) AS delivery_time
	FROM runner_order AS r
	INNER JOIN cust_order AS c
	USING(order_id)
	WHERE r.pickup_time IS NOT NULL
	GROUP BY delivery_time)
SELECT pizza_quantity, AVG(delivery_time) AS avg_delivery_time
FROM time_taken
GROUP BY pizza_quantity
ORDER BY avg_delivery_time;

-- 4. What was the average distance travelled for each customer?

SELECT c.customer_id, AVG(r.distance) AS avg_distance_km
FROM cust_order AS c
INNER JOIN runner_order AS r
USING(order_id)
GROUP BY c.customer_id
ORDER BY avg_distance_km DESC;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration) - MIN(duration)
FROM runner_order

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, CEIL(AVG(distance / (duration::FLOAT / 60))) AS avg_speed
FROM runner_order
GROUP BY runner_id
ORDER BY runner_id



-- 7. What is the successful delivery percentage for each runner?

SELECT runner_id,
	COUNT(CASE WHEN cancellation IS NULL THEN 1 END) * 100 / COUNT(*) AS successful_delivery_percentage
FROM runner_order
GROUP BY runner_id;


								-- C. Ingredient Optimisation
ALTER TABLE cust_order 
ADD COLUMN record_id SERIAL PRIMARY KEY;

DROP TABLE IF EXISTS extra_break;

CREATE TEMP TABLE extra_break AS(
	SELECT order_id, record_id, CAST(TRIM(e.extras) AS INTEGER) AS extra_id
	FROM cust_order AS c
	LEFT JOIN LATERAL UNNEST(string_to_array(c.extras, ',')) AS e(extras) ON TRUE
)
SELECT * FROM extra_break;


DROP TABLE IF EXISTS exclusion_break;

CREATE TEMP TABLE exclusion_break AS(
	SELECT c.order_id, record_id, CAST(TRIM(e.exclusions) AS INTEGER) AS exclusions_id
	FROM cust_order AS c
	LEFT JOIN LATERAL UNNEST(string_to_array(c.exclusions, ',')) AS e(exclusions) ON TRUE
)

SELECT * FROM exclusion_break;


DROP TABLE IF EXISTS toppings_break;


CREATE TEMP TABLE toppings_break AS (
	SELECT pizza_id, CAST(TRIM (p.toppings) AS INTEGER) AS toppings_id
	FROM pizza_recipes AS pr
	CROSS JOIN LATERAL UNNEST(string_to_array (pr.toppings, ',')) AS p(toppings)
	)

SELECT * FROM toppings_break;

								
--1. What are the standard ingredients for each pizza?

WITH CTE AS(
	SELECT pn.pizza_name, pn.pizza_id, pt.topping_name
	FROM pizza_names AS pn
	INNER JOIN toppings_break AS tb
	USING(pizza_id)
	INNER JOIN pizza_toppings AS pt
	ON pt.topping_id = tb.toppings_id
)
SELECT pizza_name, string_agg(topping_name, ', ') AS toppings
FROM CTE
GROUP BY pizza_name;


-- 2. What was the most commonly added extra?
WITH CTE_extras AS (
	SELECT eb.order_id, eb.extra_id, pt.topping_name
	FROM extra_break AS eb
	INNER JOIN pizza_toppings AS pt
	ON eb.extra_id = pt.topping_id)

SELECT COUNT(extra_id), topping_name
FROM CTE_extras
GROUP BY topping_name
ORDER BY COUNT(extra_id) desc
LIMIT 1;

--3. What was the most common exclusion?

WITH CTE_exclusions AS (
	SELECT eb.order_id, eb.exclusions_id, pt.topping_name
	FROM exclusion_break AS eb
	INNER JOIN pizza_toppings AS pt
	ON eb.exclusions_id = pt.topping_id)

SELECT COUNT(exclusions_id), topping_name
FROM CTE_exclusions
GROUP BY topping_name
ORDER BY COUNT(exclusions_id) desc
LIMIT 1;

/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/

WITH ExtraCte AS (
	SELECT e.record_id, 
	   'Extra ' || STRING_AGG(tp.topping_name, ', ') AS record_option
	FROM extra_break AS e
	INNER JOIN pizza_toppings AS tp
	ON e.extra_id = tp.topping_id
	GROUP BY e.record_id
),
ExclusionsCte AS(
	SELECT ex.record_id,
			'Exclude ' || STRING_AGG(tp.topping_name, ', ') AS record_option
	FROM exclusion_break AS ex
	INNER JOIN pizza_toppings AS tp
	ON ex.exclusions_id = tp.topping_id
	GROUP BY ex.record_id
),
UnionCte AS(
	SELECT *
	FROM ExtraCte
	UNION 
	SELECT *
	FROM ExclusionsCte)
	
SELECT
c.record_id,
c.order_id,
c.customer_id,
c.pizza_id,
c.order_time,
concat_ws(' - ', pn.pizza_name, STRING_AGG(u.record_option, ' - ')) AS pizza_spec
FROM cust_order AS c
LEFT JOIN UnionCte AS u
USING(record_id)
LEFT JOIN pizza_names AS pn
USING(pizza_id)
GROUP BY
c.record_id,
c.order_id,
c.customer_id,
c.pizza_id,
c.order_time,
pn.pizza_name


-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

WITH Ingredient AS (
	SELECT 
		c.record_id, 
		c.order_id, 
		c.customer_id, 
		c.pizza_id, 
		pn.pizza_name,
		CASE WHEN tb.toppings_id IN(
		SELECT e.extra_id
		FROM extra_break AS e
		WHERE e.record_id = c.record_id) THEN '2x ' || pt.topping_name
		  ELSE pt.topping_name
			 END AS topping
	FROM cust_order AS c
	INNER JOIN toppings_break AS tb
	USING(pizza_id)
	INNER JOIN pizza_names AS pn
	USING(pizza_id)
	INNER JOIN pizza_toppings AS pt
	ON tb.toppings_id = pt.topping_id
	WHERE 
	  NOT EXISTS 
	  (SELECT 1 
		FROM exclusion_break eb 
		 WHERE c.record_id = eb.record_id 
		 AND pt.topping_id = eb.exclusions_id))
		 
SELECT record_id, order_id, customer_id, pizza_id,
CONCAT(pizza_name, ': ', STRING_AGG(topping, ' , ')) AS ingredient_list
FROM ingredient
GROUP BY 
	order_id,
	customer_id, 
	pizza_id, 
	pizza_name, 
	record_id
ORDER BY order_id;


-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH used_times AS(
SELECT
	pt.topping_name,
	CASE 
		WHEN tb.toppings_id IN(
			SELECT extra_id
			FROM extra_break AS e
			WHERE e.record_id = c.record_id) 
		THEN 2
		WHEN tb.toppings_id IN(
			SELECT exclusions_id
			FROM exclusion_break AS eb
			WHERE eb.record_id = c.record_id)
		THEN 0
		ELSE 1 END AS times_used
FROM cust_order AS c
INNER JOIN toppings_break AS tb
USING(pizza_id)
INNER JOIN pizza_names AS pn
USING(pizza_id)
INNER JOIN pizza_toppings AS pt
ON pt.topping_id = tb.toppings_id 
)
SELECT topping_name, SUM(times_used) AS ingredient_qty
FROM used_times
GROUP BY topping_name
ORDER BY ingredient_qty
	
 
										 -- D. Pricing and Ratings
/* 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
- how much money has Pizza Runner made so far if there are no delivery fees? */

WITH CtePrice AS (
SELECT runner_id, pizza_name,
		CASE
			WHEN pizza_name = 'Meatlovers' THEN 12
			ELSE 10 END AS price
FROM cust_order AS c
RIGHT JOIN runner_order AS r
USING(order_id)
INNER JOIN pizza_names AS p
USING(pizza_id)
WHERE r.cancellation IS NULL
)
SELECT SUM(price)
FROM CtePrice 

-- 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra


WITH Price1 AS (
	SELECT SUM(price) AS money_made
	FROM(
		SELECT runner_id, pizza_name,
			CASE
				WHEN pizza_name = 'Meatlovers' THEN 12
				ELSE 10 END AS price
	FROM cust_order AS c
	RIGHT JOIN runner_order AS r
	USING(order_id)
	INNER JOIN pizza_names AS p
	USING(pizza_id)
	WHERE r.cancellation IS NULL
	) AS prices
),
price2 AS(
	SELECT SUM(charges) AS extra_charges
	FROM(SELECT extra_id,
		CASE WHEN extra_id = 4 THEN 2 ELSE 1
		END AS charges
		FROM extra_break AS eb
		INNER JOIN runner_order AS r
		USING(order_id)
		WHERE r.cancellation IS NULL
		AND eb.extra_id IS NOT NULL
	) AS extra_fee
)
SELECT price1.money_made + price2.extra_charges AS PricePlusCharges
FROM price1, price2;

/* 4. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - insert your own data for ratings for each 
successful customer order between 1 to 5.*/

CREATE TABLE rating(
order_id int,
rating int)

INSERT INTO rating(order_id, rating) 
VALUES
(1, 5),
(2, 4),
(3, 1),
(4, 3),
(5, 1),
(6, 2),
(7, 3),
(8, 5),
(9, 1),
(10, 4)

SELECT * FROM rating

/*Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas */

SELECT 
	c.customer_id, 
	c.order_id,
	ro.runner_id,
	r.rating,
	c.order_time,
	ro.pickup_time,
	ro.pickup_time - c.order_time AS time_taken,
	ro.duration,
	ro.distance / (duration::float /60) AS speed,
	COUNT(*) AS pizza_count
FROM cust_order AS c
INNER JOIN runner_order AS ro
USING(order_id)
INNER JOIN rating AS r
USING(order_id)
GROUP BY 
	c.customer_id, 
	c.order_id,
	ro.runner_id,
	r.rating,
	c.order_time,
	ro.duration,
	ro.pickup_time,
	speed
ORDER BY pizza_count DESC

/* If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid 
$0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?*/

WITH priceCte AS(
	SELECT SUM(price) AS price
	FROM
		(SELECT
			p.pizza_name,
			CASE 
				WHEN pizza_name = 'Meatlovers' THEN 12 ELSE 10 END AS price
		FROM runner_order AS r
		INNER JOIN cust_order AS c
		USING(order_id)
		INNER JOIN pizza_names AS p
		ON c.pizza_id = p.pizza_id
		WHERE r.cancellation IS NULL
		) AS prices
),
runners_commision AS(
	SELECT 
		sum(runner_pay) AS runner_payment
	FROM
		(SELECT 
			distance * 0.3 AS runner_pay
			FROM runner_order
			WHERE distance IS NOT NULL) AS fee
	)
SELECT priceCte.price - runners_commision.runner_payment AS net_pay
FROM priceCte, runners_commision;



