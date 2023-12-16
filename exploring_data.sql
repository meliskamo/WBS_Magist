USE magist;
# EXERCISES BUSINESS QUESTIONS ##########################################
#########################################################################
######################## 2. 0 ###########################################
#########################################################################
############################ 1. How many orders are there in the dataset?
SELECT COUNT(*) FROM orders;

############################ 2. Are orders actually delivered?
SELECT COUNT(*), order_status FROM orders GROUP BY order_status;

############################ 3. Is Magist having user growth?
SELECT COUNT(customer_id),
	YEAR(order_purchase_timestamp) AS year_otp, 
    MONTH(order_purchase_timestamp) AS month_otp 
from orders 
GROUP BY year_otp, month_otp
ORDER BY year_otp, month_otp;

############################ 4. How many products are there on the products table?
SELECT COUNT(product_id) from products;

############################ 5. Which are the categories with the most products?
SELECT COUNT(product_id) as c_p_i, 
	product_category_name AS p_cn
FROM products
GROUP BY p_cn
ORDER BY c_p_i DESC;

############################ 6. How many of those products were present in actual transactions?
SELECT 
	count(DISTINCT product_id) AS n_products
FROM
	order_items;	

############################ 7. What’s the price for the most expensive and cheapest products?
SELECT MIN(price), MAX(price)
From order_items;
  
############################   8. What are the highest and lowest payment values? 
SELECT MAX(payment_value), MIN(payment_value) FROM order_payments;

SELECT SUM(payment_value) AS maxpay 
FROM order_payments
GROUP BY order_id
ORDER BY maxpay DESC 
LIMIT 1;

#########################################################################
######################## 3. 0 ###########################################
#########################################################################
################################# What categories of tech products does Magist have?
SELECT DISTINCT product_category_name_english
FROM product_category_name_translation AS pt;

################################# How many products of these tech categories have been sold 
################################# (within the time window of the database snapshot)? What percentage 
################################# does that represent from the overall number of products sold?
SELECT COUNT(o.order_id)
FROM ((order_items AS o 
INNER JOIN products AS p ON o.product_id=p.product_id)
INNER JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name)
WHERE pt.product_category_name_english IN ('electronics',
'computers_accessories','pc_gamer','computers','telephony', 'fixed_telephony', 'audio');
/*electronics
computers_accessories
pc_gamer
computers
telephony
fixed_telephony
audio
return= 15979*/

################################# What’s the average price of the products being sold?
SELECT COUNT(o.order_id) FROM order_items AS o ;
/*return=112650*/
/*1%: 1126.5 , percentage tech-items of total amount: 4.22%*/

SELECT AVG(oi.price), MAX(oi.price), MIN(oi.price)
FROM order_items oi 
INNER JOIN products p ON p.product_id=oi.product_id; /*avg:120 */

################################# Are expensive tech products popular?
SELECT COUNT(product_id)
FROM order_items
WHERE price > 2*(SELECT AVG(price) FROM order_items); # 10306
SELECT COUNT(product_id)
FROM order_items; # 112650
/*9.14 % .... not so popular*/

/* Alternative query using cases:

SELECT order_id, product_id, price,
CASE
	WHEN price > 2*AVG(price) THEN 'expensive'
    WHEN (avg(price)-40)< price <  (avg(price)+40) then 'avg'
    ELSE 'cheap'
END AS price_scale
FROM order_items;*/ /*max: 6735, min:0.85*/

#########################################################################
######################## 3.2. ###########################################
#########################################################################

################################# How many months of data are included in the magist database?
################################# result= 25 months
SELECT
MAX(order_purchase_timestamp),MIN(order_purchase_timestamp)
/*	YEAR(order_purchase_timestamp) AS year_otp, 
    MONTH(order_purchase_timestamp) AS month_otp */
FROM orders 
ORDER BY order_purchase_timestamp;
#geht auch mit timestampdiff -->sortieren nach monaten auch moeglich

################################# How many sellers are there? 
SELECT COUNT(seller_id) FROM sellers; # result : 3095
/*SELECT seller_id FROM sellers;*/

SELECT COUNT( DISTINCT s.seller_id)
FROM sellers as s
INNER JOIN order_items as o ON o.seller_id=s.seller_id; # result: 3095

################################# How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
################################# result 463 -->: ~15%*/
SELECT COUNT(DISTINCT s.seller_id)
FROM (((sellers as s
INNER JOIN order_items as o ON o.seller_id=s.seller_id)
INNER JOIN products AS p ON o.product_id=p.product_id)
INNER JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name)
WHERE pt.product_category_name_english IN ('electronics','computers_accessories','pc_gamer','computers','telephony', 'fixed_telephony', 'audio');

################################# What is the total amount earned by all sellers?
################################# result: 13591643
SELECT SUM(price) FROM order_items; 

################################# What is the total amount earned by all Tech sellers? 
################################# result: 1730649
SELECT SUM(o.price) 
FROM ((order_items as o 
INNER JOIN products AS p ON o.product_id=p.product_id)
INNER JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name)
WHERE pt.product_category_name_english IN ('electronics','computers_accessories','pc_gamer','computers','telephony', 'fixed_telephony', 'audio'); 
# where_order status not in 'unavailable/'canceled' noch hinzufuegen
################################# average monthly income of all sellers
# 2016: ~49786 --> :12 = 4149 p.m.
# 2017: ~6155669 --> :12 = 512972 p.m.
# 2018: ~7386189 --> :12 = 615516 p.m.
SELECT SUM(oi.price),
	YEAR(o.order_purchase_timestamp) AS year_otp /*, 
    MONTH(o.order_purchase_timestamp) AS month_otp*/ 
FROM orders o
INNER JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY year_otp /*, month_otp*/
ORDER BY year_otp /*, month_otp ASC*/ ;
/*
SELECT COUNT(order_id) FROM order_items; #112650
SELECT COUNT(order_id) FROM orders; # 99441
*/

################################# average monthly income of all tech sellers
################################# result: 72110
SELECT SUM(oi.price),
	MAX(o.order_purchase_timestamp),
    MIN(o.order_purchase_timestamp)#AS month_otp
FROM (((orders o
INNER JOIN order_items oi ON o.order_id=oi.order_id)
INNER JOIN products AS p ON oi.product_id=p.product_id)
INNER JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name)
WHERE pt.product_category_name_english IN ('electronics',
'computers_accessories','pc_gamer','computers','telephony', 'fixed_telephony', 'audio');

# SUM(oi.price) = 1730649
# MAX(o.order_purchase_timestamp)-MIN(o.order_purchase_timestamp)= 2018-08-29 / 2016-09-05= 24

/*SELECT oi.price,
	YEAR(o.order_purchase_timestamp) AS year_otp,
	MONTH(o.order_purchase_timestamp) AS month_otp
FROM (((order_items AS oi 
INNER JOIN products AS p ON oi.product_id=p.product_id)
INNER JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name)
INNER JOIN orders o ON o.order_id=oi.order_id)
WHERE pt.product_category_name_english IN ('electronics',
'computers_accessories','pc_gamer','computers','telephony', 'fixed_telephony', 'audio')
ORDER BY year_otp, month_otp ASC;*/

/*SELECT oi.price,
	YEAR(o.order_purchase_timestamp) AS year_otp,
CASE
	WHEN pt.product_category_name_english= 'electronics' THEN 'electronics'
    WHEN pt.product_category_name_english= 'computers_accessories' THEN 'computer accesories'
	WHEN pt.product_category_name_english='pc_gamer' THEN 'pc gamer'
    WHEN pt.product_category_name_english='computers' THEN 'computers'
    WHEN pt.product_category_name_english='telephony' THEN 'telephony'
    WHEN pt.product_category_name_english='fixed_telephony' THEN 'fixed telephony'
    WHEN pt.product_category_name_english='audio' THEN 'audio'
END AS category
FROM (((order_items AS oi 
INNER JOIN products AS p ON oi.product_id=p.product_id)
INNER JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name)
INNER JOIN orders o ON o.order_id=oi.order_id)
ORDER BY year_otp ASC;*/

#########################################################################
######################## 3.3. ###########################################
#########################################################################

################################# What’s the average time between the order being placed and the product being delivered?
################################# result: ca. 9 days
SELECT 
	order_delivered_carrier_date AS placed,
    order_delivered_customer_date AS delivered,
    DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date) # hier purchase und nicht carrier benutzen 
FROM orders; # calculates differences

SELECT 
	AVG(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date))
FROM orders;

################################# How many orders are delivered on time vs orders delivered with a delay?
################################# result: 33404
#define delay as  datediff > 9
SELECT 
    COUNT(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date)) # order_estimated_delivery_date und nict carrier benutzen estimated delivery date
FROM orders
WHERE DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date)>9;


################################# Is there any pattern for delayed orders, e.g. big products being delayed more often?
### ier auc delivered_customer date verwenden und estimated delivery date
/* Delay				big_stuff	% from total
1 week delay			2403		~10
2 weeks delay			792			~10
3 weeks delay			305			~10
one month or more delay	280			~10
==> it does not depend on te size!
but, makes sense: if I choose 5 of ca 59 categories that are  delayed by 1 month if it's evenly distributed it will always be ~10%
*/
#define categories of "big objects"
SELECT
	CASE
    	WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) BETWEEN 10 AND 16 THEN '1 week delay'
		WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) BETWEEN 16 AND 23 THEN '2 weeks delay'
		WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) BETWEEN 23 AND 30 THEN '3 weeks delay'
		WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) > 30 THEN 'one month or more delay'
	END AS Delay,
    COUNT(*) as total,
	COUNT(
		CASE
			WHEN pt.product_category_name_english IN ('furniture_living_room') THEN 'furniture_living_room'
			WHEN pt.product_category_name_english IN ('bed_bat_table') THEN 'bed_bat_table'
			WHEN pt.product_category_name_english IN ('furniture_decor') THEN 'furniture_decor'
			WHEN pt.product_category_name_english IN ('construction_tools_garden') THEN 'construction_tools_garden'
			WHEN pt.product_category_name_english IN ('musical_instruments') THEN 'musical_instruments'
			WHEN pt.product_category_name_english IN ('office_furniture') THEN 'office_furniture'
		END
    ) as big_stuff,
    COUNT(
		CASE	
            WHEN pt.product_category_name_english NOT IN ('furniture_living_room', 'bed_bat_table','furniture_decor','construction_tools_garden','musical_instruments','office_furniture') THEN 'small stuff'
		END
    ) as smaller_stuff
FROM (((orders o
	LEFT JOIN order_items oi ON o.order_id = oi.order_id)
	LEFT JOIN products p ON oi.product_id = p.product_id)
	LEFT JOIN product_category_name_translation pt ON p.product_category_name=pt.product_category_name)
GROUP BY Delay;

SELECT 
	/*MAX(DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)), ## --> 206
    MIN(DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)) ## -->10 */
	#pt.product_category_name_english,
    COUNT(DISTINCT pt.product_category_name_english),
    #DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date),
CASE
	WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) BETWEEN 10 AND 16 THEN '1 week delay'
    WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) BETWEEN 16 AND 23 THEN '2 weeks delay'
    WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) BETWEEN 23 AND 30 THEN '3 weeks delay'
    WHEN DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) > 30 THEN '1 month ore more delay'
END AS Delay
FROM (((orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id)
LEFT JOIN products p ON oi.product_id = p.product_id)
LEFT JOIN product_category_name_translation pt ON p.product_category_name=pt.product_category_name)
GROUP BY Delay
#ORDER BY Delay DESC
;  # query counts product categories in delay-times

/*SELECT 
	pt.product_category_name_english,
    DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)
FROM (((orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id)
LEFT JOIN products p ON oi.product_id = p.product_id)
LEFT JOIN product_category_name_translation pt ON p.product_category_name=pt.product_category_name)
WHERE DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)>9; */
