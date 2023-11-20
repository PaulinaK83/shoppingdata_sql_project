-- CREATE DATABASE: database customer_shopping_data with 5 tables:
-- customer_data (customer_id, customer_name, customer_surname, gender, age, customer_email)
-- customer_invoices (invoice_no, customer_id, category, quantity, price, payment_method, invoice_date, shopping_mall)
-- customer_loyalty (customer_id, customer_loyalty_card)
-- customer_marketing (customer_id, customer_newsletter, newsletter_sent, last_newsletter_date)
-- shopping_malls (shopping_mall_id, shopping_mall)
USE customer_shopping_data;
-- SETTING PRIMARY & FOREIGN KEYS: setting customer_id as the PRIMARY KEY for customer_data
ALTER TABLE customer_data MODIFY COLUMN customer_id VARCHAR(50) NOT NULL;
ALTER TABLE customer_data ADD PRIMARY KEY (customer_id);
-- setting customer_id as FOREIGN KEY, and invoice_no as PRIMARY KEY for customer_invoices
ALTER TABLE customer_invoices MODIFY COLUMN customer_id VARCHAR(50) NOT NULL;
ALTER TABLE customer_invoices MODIFY COLUMN invoice_no VARCHAR(50) NOT NULL;
ALTER TABLE customer_invoices ADD FOREIGN KEY (customer_id) REFERENCES customer_data(customer_id);
ALTER TABLE customer_invoices ADD PRIMARY KEY (invoice_no);
-- setting customer_id as FOREIGN KEY for customer_loyalty
ALTER TABLE customer_loyalty MODIFY COLUMN customer_id VARCHAR(50) NOT NULL;
ALTER TABLE customer_loyalty ADD FOREIGN KEY (customer_id) REFERENCES customer_data(customer_id);
-- setting customer_id as FOREIGN KEY for customer_marketing
ALTER TABLE customer_marketing MODIFY COLUMN customer_id VARCHAR(50) NOT NULL;
ALTER TABLE customer_marketing ADD FOREIGN KEY (customer_id) REFERENCES customer_data(customer_id);
-- setting shopping_mall_id as PRIMARY KEY for shopping_malls
ALTER TABLE shopping_malls MODIFY COLUMN shopping_mall_id VARCHAR(20) NOT NULL;
ALTER TABLE shopping_malls ADD PRIMARY KEY (shopping_mall_id);
-- JOIN: joining data customer_id, full name as concatination of name and surname, gender, age, invoice_no, category,
-- invoice total, invoice date, shopping mall id and shopping mall
-- FROM customer_data, customer_invoices, shopping_malls

SELECT dat.customer_id AS customer_id, CONCAT(dat.customer_name,' ',dat.customer_surname) AS full_name, 
dat.gender AS gender, dat.age AS age, inv.invoice_no AS invoice_no, inv.category AS category, 
inv.price AS invoice_total, inv.invoice_date AS invoice_date, shop.shopping_mall_id AS shopping_mall_id, 
inv.shopping_mall AS shopping_mall
FROM customer_data dat
JOIN customer_invoices inv ON dat.customer_id=inv.customer_id
JOIN shopping_malls shop ON inv.shopping_mall=shop.shopping_mall;

-- VIEW: create view with the same data for customers over 25 years

CREATE OR REPLACE VIEW vw_customer_over25 AS SELECT dat.customer_id AS customer_id, CONCAT(dat.customer_name,' ',dat.customer_surname) AS full_name, 
dat.gender AS gender, dat.age AS age, inv.invoice_no AS invoice_no, inv.category AS category, 
inv.price AS invoice_total, inv.invoice_date AS invoice_date, shop.shopping_mall_id AS shopping_mall_id, 
inv.shopping_mall AS shopping_mall
FROM customer_data dat
JOIN customer_invoices inv ON dat.customer_id=inv.customer_id
JOIN shopping_malls shop ON inv.shopping_mall=shop.shopping_mall WHERE dat.age > 25
WITH CHECK OPTION;

SELECT * FROM vw_customer_over25;

-- QUERY VIEW: all data for S1; total sales by shopping mall id

SELECT * FROM vw_customer_over25 
HAVING shopping_mall_id='S1';

SELECT shopping_mall_id, sum(invoice_total) 
FROM vw_customer_over25 
GROUP BY shopping_mall_id 
ORDER BY sum(invoice_total) ASC;

-- GROUP BY: sum total sales and group by category

SELECT inv.category AS category, SUM(inv.price) AS total_sales 
FROM customer_invoices inv 
GROUP BY inv.category
ORDER BY total_sales DESC;

-- GROUP BY & HAVING+SUBQUERY: sum total sales for the clothing category for female clients

SELECT inv.category AS category, SUM(inv.price) AS total_sales 
FROM customer_invoices inv 
WHERE inv.customer_id IN (SELECT dat.customer_id FROM customer_data dat WHERE dat.gender='Female') 
GROUP BY inv.category 
HAVING inv.category='Clothing';

-- CREATE FUNCTION: if the last newsletter was sent more thatn 5 days ago return yes; if less than 5 days return no 

DELIMITER // 
CREATE FUNCTION today_newsletter_list(last_newsletter_date VARCHAR(50)) 
RETURNS VARCHAR(5)
DETERMINISTIC 
BEGIN 
	DECLARE send_newsletter VARCHAR(5);
   
    IF STR_TO_DATE(last_newsletter_date, '%d/%m/%Y') < now() - interval 5 day THEN 
    SET send_newsletter = 'YES'; 
    ELSEIF (STR_TO_DATE(last_newsletter_date, '%d/%m/%Y') >= now() - interval 5 day) THEN 
    SET send_newsletter = 'NO'; 
    END IF;
    RETURN send_newsletter;
END// 
DELIMITER ;

-- QUERY WITH FUNCTION: using function create mailing list for all clients who should receive a newsletter today

SELECT mar.customer_id, today_newsletter_list(last_newsletter_date), dat.customer_email 
FROM customer_marketing mar 
JOIN customer_data dat ON mar.customer_id=dat.customer_id 
WHERE today_newsletter_list(last_newsletter_date)='YES' ;

-- adding a 'modifed' TIMESTAMP to customer_loyalty and defaulting to current timestamp

ALTER TABLE customer_loyalty ADD modified TIMESTAMP;
SELECT * FROM customer_loyalty;
SET SQL_SAFE_UPDATES=0;
UPDATE customer_loyalty SET modified=CURRENT_TIMESTAMP;
SELECT * FROM customer_loyalty;

-- TRIGGER: creating trigger updating the modified column on each update to customer_loyalty_card data

DELIMITER //
CREATE TRIGGER update_trigger
    BEFORE UPDATE ON customer_loyalty
    FOR EACH ROW
BEGIN
	IF NOT OLD.customer_loyalty_card=NEW.customer_loyalty_card 
    THEN SET new.modified=CURRENT_TIMESTAMP;
    END IF;
END //
DELIMITER ;

SELECT * FROM customer_loyalty;

UPDATE customer_loyalty SET customer_loyalty_card='Yes' WHERE customer_id='C493252';

SELECT * FROM customer_loyalty;

-- PROCEDURE: create procedure showing modifications from the last hour

DELIMITER //
CREATE PROCEDURE changes_in_last_hour()
BEGIN
    SELECT * from customer_loyalty WHERE modified > DATE_SUB(NOW(), INTERVAL 1 HOUR);
END //
DELIMITER ;

CALL changes_in_last_hour;