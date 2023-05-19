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


