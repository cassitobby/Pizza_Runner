							-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

SELECT COUNT(order_id) AS number_of_orders
FROM cust_order

-- 2. How many unique customer orders were made?

SELECT COUNT( DISTINCT order_id) AS unique_orders
FROM cust_order

-- 3. How many successful orders were delivered by each runner?
SELECT COUNT(*) AS successful_delivery
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

SELECT TO_CHAR(order_time, 'DAY') AS Day_of_week,
		COUNT(*) AS daily_order_quantity
FROM cust_order
GROUP BY Day_of_week