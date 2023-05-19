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
GROUP BY registration_week;


						
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
GROUP BY pizza_quantity;

-- 4. What was the average distance travelled for each customer?

SELECT c.customer_id, AVG(r.distance) AS avg_distance-km
FROM cust_order AS c
INNER JOIN runner_order AS r
USING(order_id)
GROUP BY c.customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration) - MIN(duration)
FROM runner_order

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, CEIL(AVG(distance / (duration::FLOAT / 60))) AS avg_speed
FROM runner_order
GROUP BY runner_id
ORDER BY runner_id

WITH time_cte AS (
	SELECT runner_id, distance, duration::float / 60 AS time_minute
	FROM runner_order)
SELECT runner_id, AVG(distance/ time_minute) AS avg_speed
FROM time_cte
GROUP BY runner_id
ORDER BY runner_id


-- 7. What is the successful delivery percentage for each runner?

SELECT runner_id,
	COUNT(CASE WHEN cancellation IS NULL THEN 1 END) * 100 / COUNT(*) AS successful_delivery_percentage
FROM runner_order
GROUP BY runner_id;