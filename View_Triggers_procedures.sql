/*1 View to describe which albums are as order_items in one order*/

CREATE OR REPLACE VIEW ordered_albums_in_order
 AS
SELECT o.order_id,album_name, order_date, tax_amount,ship_date,album_price,
price_discount_percent,(album_price - price_discount_percent) AS final_Price, quantity,
((price_discount_percent- price_discount_percent) * quantity) AS item_total
FROM orders o JOIN order_items oi
ON o.order_id = oi.order_id
JOIN albums a
ON oi.album_id= a.album_id;

SELECT *
FROM ordered_albums_in_order
ORDER BY order_id;

/*2 To give view how much a customer paid in one order*/
CREATE OR REPLACE VIEW order_total
 AS
SELECT o.order_id, order_date,ship_date,SUM(album_price *quantity) AS actual_price,
ROUND(SUM((album_price * (price_discount_percent/100)) *quantity),2) AS discount_price ,
ROUND(SUM((album_price - (album_price *(price_discount_percent/100) )) *quantity),2)AS final_Price 

FROM orders o JOIN order_items oi
ON o.order_id = oi.order_id
JOIN albums a
ON oi.album_id= a.album_id
group by o.order_id ; 


SELECT *
FROM order_total;

/*3 View to describe how many time this particuler album ordered and how many copies sold till now*/
CREATE OR REPLACE VIEW album_order_summary
 AS 
SELECT  album_name, COUNT(order_item_id) AS no_of_order,SUM(quantity) AS total_no_of_copies,
SUM((album_price- price_discount_percent) * quantity)  AS order_total
FROM albums a JOIN order_items oi
ON oi.album_id= a.album_id 
GROUP BY album_name;

SELECT *
FROM album_order_summary
ORDER BY  order_total ;

/*4 view to count no of Previews*/
CREATE OR REPLACE VIEW preview_count
 AS
SELECT email_address, COUNT(song_id)
FROM customers c JOIN preview p
ON c.customer_id = p.customer_id
GROUP BY  email_address;

SELECT *
FROM preview_count;

/*5  View to find the total amount to refund*/
CREATE OR REPLACE VIEW amount_to_refund
 AS 
SELECT email_address,return_id,album_name,album_price,quantity,(album_price * quantity) AS item_price_total, 
ROUND( album_price * price_discount_percent / 100 , 2) * quantity AS discount_amount_total,
((album_price * quantity)-(ROUND( album_price * price_discount_percent / 100 , 2) * quantity)) As amount_to_refund
FROM customers c JOIN  returns r
ON c.customer_id = r.customer_id
JOIN albums a
ON r.album_id = a.album_id;

SELECT *
FROM amount_to_refund;


/*6  View to find the number of time customer return the item and how many copies in total till now*/
CREATE OR REPLACE VIEW number_of_refund
 AS 
SELECT email_address,first_name,COUNT(return_id) AS no_of_returns,SUM(quantity) AS total_no_of_copies,
((album_price * quantity)-(ROUND( album_price * price_discount_percent / 100 , 2) * quantity)) As amount_to_refund
FROM customers c JOIN returns r
ON c.customer_id = r.customer_id 
JOIN albums a
ON r.album_id = a.album_id
GROUP BY album_name;


SELECT *
FROM amount_to_refund;
 

/*7 Grand view of order With customer name and its shipping address*/
CREATE OR REPLACE VIEW complete_order
 AS 
SELECT o.order_id,email_address,line1,line2,city ,state, order_date,ship_date,SUM(album_price *quantity) AS actual_price,
ROUND(SUM((album_price * (price_discount_percent/100)) *quantity),2) AS discount_price ,
ROUND(SUM((album_price - (album_price *(price_discount_percent/100) )) *quantity),2)AS final_Price 

FROM customers c JOIN addresses ad1
ON c.customer_id = ad1.customer_id
JOIN orders o 
ON o.customer_id = c.customer_id AND c.ship_address_id = o.ship_address_id

JOIN order_items oi
ON o.order_id = oi.order_id
JOIN albums a
ON oi.album_id= a.album_id
group by o.order_id ;

SELECT *
FROM complete_order;


/* Triggers and procedures*/

/*1  trigger to update album stock after return*/
SET SQL_SAFE_UPDATES = 0;
DROP TRIGGER IF EXISTS after_return
DELIMITER //
CREATE TRIGGER  after_return
AFTER INSERT ON returns
FOR EACH ROW
BEGIN 
	UPDATE albums
    SET stock= stock + NEW.quantity
    WHERE album_id = album_id;
END//
DELIMITER ;

insert into returns(quantity,customer_id,album_id,order_id)
values(2,001,001,001);

/*2  trigger to update album stock after rder is placed*/

DROP TRIGGER IF EXISTS after_order
DELIMITER //
CREATE TRIGGER  after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN 
	UPDATE albums
    SET stock= stock - NEW.quantity
    WHERE album_id = album_id;
END//
DELIMITER ;

insert into order_items(quantity,order_id,album_id)
values(2,001,001);


/*3 Procedure to not accept discount_percent as negetive when update*/ 
DROP PROCEDURE IF EXISTS update_product_discount;
DELIMITER //
CREATE PROCEDURE update_product_discount(album_id_parm INT,
                                         discount_percent_parm DECIMAL(5.2))
BEGIN
IF discount_percent_parm < 0 THEN
SIGNAL SQLSTATE '22003'
			SET MESSAGE_TEXT = 'THE discount_percent can not be negative.',
			MYSQL_ERRNO = 1264;
            END IF;
            UPDATE albums
            SET price_discount_percent = discount_percent_parm
            WHERE album_id = album_id_parm;
            END//
            DELIMITER ;
            CALL update_product_discount(1, 15.77);
            CALL update_product_discount(2, -1.77);