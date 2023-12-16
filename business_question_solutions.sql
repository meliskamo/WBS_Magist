USE magist;

-- How many tech products for each seller per tech product category?
SELECT s.seller_id as sellerID, COUNT(p.product_id) as amountProducts, p.product_category_name as PCategoryName
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_category_name IN ('electronicos', 'informatica_acessorios','pcs', 'telefonia','audio', 'tablets_impressao_imagem', 'pc_gamer')
GROUP BY s.seller_id, p.product_category_name;

SELECT s.seller_id as sellerID, COUNT(p.product_id) as amountProducts, p.product_category_name as PCategoryNameNotTech
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_category_name NOT IN ('electronicos', 'informatica_acessorios','pcs', 'telefonia','audio', 'tablets_impressao_imagem', 'pc_gamer')
GROUP BY s.seller_id, p.product_category_name;
/*
SELECT DISTINCT p.product_category_name
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY s.seller_id, p.product_category_name;/*
/*****
In relation to the products:
*****/

-- What categories of tech products does Magist have?
-- "audio", 
-- "electronics", 
-- "computers_accessories", 
-- "pc_gamer", 
-- "computers", 
-- "tablets_printing_image", 
-- "telephony";


-- How many products of these tech categories have been sold (within the time window of the database snapshot)? 
SELECT COUNT(DISTINCT(oi.product_id)) AS tech_products_sold
FROM order_items oi
LEFT JOIN products p 
	USING (product_id)
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE product_category_name_english = "audio"
OR product_category_name_english =  "electronics"
OR product_category_name_english =  "computers_accessories"
OR product_category_name_english =  "pc_gamer"
OR product_category_name_english =  "computers"
OR product_category_name_english =  "tablets_printing_image"
OR product_category_name_english =  "telephony";
	-- 3390
    -- order_id vs prod_id?

SELECT COUNT(DISTINCT(oi.product_id)) AS tech_products_sold, product_category_name_english, 
		ROUND(AVG(price), 2) as average_price
FROM order_items oi
LEFT JOIN products p 
	USING (product_id)
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE product_category_name_english = "audio"
OR product_category_name_english =  "electronics"
OR product_category_name_english =  "computers_accessories"
OR product_category_name_english =  "pc_gamer"
OR product_category_name_english =  "computers"
OR product_category_name_english =  "tablets_printing_image"
OR product_category_name_english =  "telephony"
GROUP BY product_category_name_english
ORDER BY tech_products_sold DESC;


-- What percentage does that represent from the overall number of products sold?
SELECT COUNT(DISTINCT(product_id)) AS products_sold
FROM order_items;
	-- 32951
    
SELECT (3390 / 32951)*100; -- This step can also be done on a calculator
	-- 0.1029, therefore 10%
    
    
-- What’s the average price of the products being sold?
SELECT ROUND(AVG(price), 2)
FROM order_items;
	-- 120.65

-- Are expensive tech products popular? *
-- * TIP: Look at the function CASE WHEN to accomplish this task.
SELECT COUNT(oi.product_id), 
	CASE 
		WHEN price > 1000 THEN "Expensive"
		WHEN price > 100 THEN "Mid-range"
		ELSE "Cheap"
	END AS "price_range"
FROM order_items oi
LEFT JOIN products p
	ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE pt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY price_range
ORDER BY 1 DESC;
	-- 11361 cheap
    -- 4263 mid-range
    -- 174 expensive
    
/*****
In relation to the sellers:
*****/

-- How many months of data are included in the magist database?
SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
FROM
    orders;
	-- 25 months
    
    
-- How many sellers are there?
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers;
	-- 3095
    
-- How many Tech sellers are there? 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN (
		'audio' , 
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
	-- 454

-- What percentage of overall sellers are Tech sellers?
SELECT (454 / 3095) * 100;
	-- 14.67%
    
 -- What is the total amount earned by all sellers?
	-- we use price from order_items and not payment_value from order_payments 
    -- as an order may contain tech and non tech product. 
    -- With payment_value we can't distinguish between items in an order
    
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');
    -- 13494400.74
    
-- the average monthly income of all sellers?
SELECT 13494400.74/ 3095 / 25;
	-- 174.40

-- What is the total amount earned by all Tech sellers?
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
        AND pt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
	-- 1666211.28
    
-- the average monthly income of Tech sellers?
SELECT 1666211.28 / 454 / 25;
	-- 146.80

/*****
In relation to the delivery time:
*****/

-- What’s the average time between the order being placed and the product being delivered?
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))
FROM orders;
	-- 12.5035
    

-- How many orders are delivered on time vs orders delivered with a delay?
-- based on order_id
SELECT 
	CASE 
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 0 THEN 'Delayed' 
		ELSE 'On time'
    END AS delivery_status, 
COUNT(a.order_id) AS orders_count
FROM orders a
LEFT JOIN order_items b
	ON a.order_id = b.order_id
WHERE order_status = 'delivered'
AND order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;
	-- 101414 'Delayed' 
    -- 8775 'On time'

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT
	CASE 
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 100 THEN "> 100 day Delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 8 AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 100 THEN "1 week to 100 day delay"
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 3 AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 8 THEN "4-7 day delay"
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 1  AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) <= 3 THEN "1-3 day delay"
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 0  AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 1 THEN "less than 1 day delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) <= 0 THEN 'On time' 
	END AS "delay_range", 
AVG(product_weight_g) AS weight_avg,
MAX(product_weight_g) AS max_weight,
MIN(product_weight_g) AS min_weight,
SUM(product_weight_g) AS sum_weight,
COUNT(a.order_id) AS orders_count
FROM orders a
LEFT JOIN order_items b
	ON a.order_id = b.order_id
LEFT JOIN products c
	ON b.product_id = c.product_id
WHERE order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'
GROUP BY delay_range
ORDER BY weight_avg DESC;






-- In MySQL, the GROUP BY clause is used to group rows that have the same values in specified columns into summary rows. 
-- It's typically used in conjunction with aggregate functions like SUM, COUNT, AVG, etc. 
-- Here are situations where you might use GROUP BY:

-- Aggregating Data:
--  If you have a sales table and you want to find the total sales amount for each product category.
SELECT category, SUM(amount) AS total_sales
FROM sales
GROUP BY category;

-- Summary Statistics:
-- If you have a table of student scores and you want to find the average score for each subject.
SELECT subject, AVG(score) AS average_score
FROM student_scores
GROUP BY subject;

-- Identifying Duplicates:
-- If you want to find duplicate values in a column.
SELECT column_name, COUNT(*)
FROM your_table
GROUP BY column_name
HAVING COUNT(*) > 1;

-- use GROUP BY when you need to aggregate or summarize data based on certain criteria, 
-- and avoid using it when you simply want to retrieve all rows without aggregation 

-- SAT
-- using AVG with joins
-- or when you're applying conditions before aggregation.



