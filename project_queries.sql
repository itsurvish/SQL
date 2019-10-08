/*1*/
SELECT COUNT(*)
FROM customers;

/*2*/
/* maximum nuber of copies sold of album*/
SELECT  album_name, COUNT(order_item_id) AS no_of_order,SUM(quantity) AS total_no_of_copies,
SUM((album_price- price_discount_percent) * quantity)  AS order_total
FROM albums a JOIN order_items oi
ON oi.album_id= a.album_id 
GROUP BY album_name
order by order_total DESC;

/* minimum nuber of copies sold of album*/
SELECT  album_name, COUNT(order_item_id) AS no_of_order,SUM(quantity) AS total_no_of_copies,
SUM((album_price- price_discount_percent) * quantity)  AS order_total
FROM albums a JOIN order_items oi
ON oi.album_id= a.album_id 
GROUP BY album_name
order by order_total ASC;
/*3*/
SELECT genre_name,COUNT(*) AS album_count,  ROUND(AVG(album_price),2) AS avg_price
FROM genre g JOIN albums a
ON g.genre_id = a.genre_id
GROUP BY genre_name
order by album_count DESC ;

/*4*/
SELECT email_address,first_name,last_name,city,state
From customers c JOIN addresses a
ON c.customer_id = a.customer_id AND c.ship_address_id = a.address_id;

/*5*/
SELECT email_address,order_id,Count(o.customer_id)
FROM customers c JOIN orders o
ON c.customer_id=o.customer_id 
WHERE   o.order_date > '2018-11-01' AND o.order_date < '2018-11-29'
HAVING Count(o.customer_id)>1 ;

select * from orders;



/*6*/
SELECT  DISTINCT album_name,CONCAT(artist_first_name,'',artist_last_name) AS artist_name
FROM albums a JOIN artists ar
ON a.artist_id= ar.artist_id;

/*7*/
SELECT  DISTINCT album_name,CONCAT(artist_first_name,'',artist_last_name) AS artist_name,stock
FROM albums a JOIN artists ar
ON a.artist_id= ar.artist_id;


