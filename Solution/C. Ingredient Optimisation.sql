ALTER TABLE cust_order 
ADD COLUMN record_id SERIAL PRIMARY KEY;

DROP TABLE IF EXISTS extra_break;

CREATE TEMP TABLE extra_break AS(
	SELECT order_id, c.record_id, CAST(TRIM(e.extras) AS INTEGER) AS extra_id
	FROM cust_order AS c
	LEFT JOIN LATERAL UNNEST(string_to_array(c.extras, ',')) AS e(extras) ON TRUE
)
SELECT * FROM extra_break;


DROP TABLE IF EXISTS exclusion_break;

CREATE TEMP TABLE exclusion_break AS(
	SELECT c.order_id, c.record_id, CAST(TRIM(e.exclusions) AS INTEGER) AS exclusions_id
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


/* 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
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


/* 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
from the customer_orders table and add a 2x in front of any relevant ingredients*/

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
