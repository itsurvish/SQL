/*1   (To check which albums have same price)*/

SELECT  a1.album_name
FROM albums a1 JOIN albums a2
ON a1.album_id <> a2.album_id
AND a1.album_price = a2.album_price
ORDER BY a1.album_name;

/*2 (To check in which genere we donot have albums)*/
SELECT genre_name, album_id
FROM genre g LEFT JOIN albums a
ON g.genre_id = a.genre_id
WHERE album_id IS NULL;

/*3   (Find the actual price to pay after discount)*/
SELECT album_name , album_price , price_discount_percent, ROUND( album_price * price_discount_percent / 100 , 2) AS discount_amount,
ROUND(album_price - (album_price * price_discount_percent / 100) ,2 ) AS Price_after_discount 
FROM albums
ORDER BY price_discount_percent DESC;

 /*4   (Ease in finding album_name between p and z)*/
SELECT album_name
FROM albums
WHERE album_name BETWEEN 'P' AND 'Z' 
ORDER BY album_name ASC;

/*5  (To check whether order is shipped or not)*/
SELECT 'SHIPPED' AS ship_status, order_id, order_date,ship_date
FROM orders
WHERE ship_date < NOW()
UNION 
SELECT 'NOT SHIPPED' AS shipship_status, order_id, order_date,ship_date
FROM orders
WHERE ship_date  >=NOW()
ORDER BY order_date;

/*6 ( to find one customer how many albums he has purchased till now, sum of albums price and how much discount he got for all items )*/

SELECT email_address,COUNT(order_item_id) AS No_of_albums,SUM(album_price * quantity) AS item_price_total, 
SUM(ROUND( album_price * price_discount_percent / 100 , 2) * quantity) AS discount_amount_total
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN albums a
ON oi.album_id = a.album_id
GROUP BY email_address
ORDER BY item_price_total DESC;

/*7 (to find out when the first time a customer ordered using our website*/
SELECT email_address, order_id, order_date
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
WHERE order_date=(
SELECT MIN(order_date)
FROm orders
WHERE customer_id = o.customer_id)
ORDER BY email_address;
