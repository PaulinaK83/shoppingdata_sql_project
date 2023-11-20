# shoppingdata_sql_project
final intro to data &amp; sql project, analysis of customer shopping data
-- CREATE DATABASE: database customer_shopping_data with 5 tables:
-- customer_data (customer_id, customer_name, customer_surname, gender, age, customer_email)
-- customer_invoices (invoice_no, customer_id, category, quantity, price, payment_method, invoice_date, shopping_mall)
-- customer_loyalty (customer_id, customer_loyalty_card)
-- customer_marketing (customer_id, customer_newsletter, newsletter_sent, last_newsletter_date)
-- shopping_malls (shopping_mall_id, shopping_mall)
-- VIEW: create view with the same data for customers over 25 years
-- QUERY VIEW: all data for S1; total sales by shopping mall id
-- GROUP BY: sum total sales and group by category
-- GROUP BY & HAVING+SUBQUERY: sum total sales for the clothing category for female clients
-- CREATE FUNCTION: if the last newsletter was sent more thatn 5 days ago return yes; if less than 5 days return no 
-- QUERY WITH FUNCTION: using function create mailing list for all clients who should receive a newsletter today
-- TRIGGER: creating trigger updating the modified column on each update to customer_loyalty_card data
-- PROCEDURE: create procedure showing modifications from the last hour
