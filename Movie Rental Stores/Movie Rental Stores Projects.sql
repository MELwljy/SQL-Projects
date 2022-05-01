# Project 1.1
-- 1. Before doing any exercise, you should explore the data first. For Exercise 1, we will focus on the product, 
-- which is the film (DVD) in this project. Please explore the product-related tables (actor, film_actor, film, language,
-- film_category, category) by using ‘SELECT *’ – do not forget to limit the number of records.
SELECT * FROM actor LIMIT 100;
SELECT * FROM film_actor LIMIT 100;
SELECT * FROM film LIMIT 100;
SELECT * FROM language LIMIT 100;
SELECT * FROM film_category LIMIT 100;
SELECT * FROM category LIMIT 100;

-- Use table FILM to solve questions as below:
-- 2. What is the largest rental_rate for each rating?
SELECT rating, MAX(rental_rate) FROM film
GROUP BY 1;

-- 3. How many films in each rating category?
SELECT rating, COUNT(DISTINCT film_id) FROM film
GROUP BY rating
ORDER BY COUNT(DISTINCT film_id);

-- 4. Create a new column film_length to segment different films by length:
-- length < 60 THEN ‘short’; length < 120 THEN ‘starndard’; lengh >=120 THEN ‘long’
-- , THEN count the number of files in each segment.
SELECT CASE WHEN length>0 AND length <60 THEN 'short'
WHEN length>=60 AND length<120 THEN 'standard'
WHEN length >=120 THEN 'long'
ELSE 'invalid' 
END AS film_length,
COUNT(film_id) FROM film
GROUP BY film_length
ORDER BY 2;

SELECT CASE WHEN length > 0 AND length < 60 THEN 'short'			
		    WHEN length >= 60 AND length < 120 THEN 'standard'            
		    WHEN length >=120  THEN 'long'           
                         ELSE 'others'            
                         END AS film_length, 
                         COUNT(film_id) FROM film            
                         GROUP BY 1
                         ORDER BY 2;
                         
-- Use table ACTOR to solve questions as below:                     
-- 5. Which actors have the last name ‘Johansson’
SELECT *
FROM actor
WHERE last_name = 'Johansson';

-- 6. How many distinct actors’ last names are there?
SELECT COUNT(DISTINCT last_name) FROM actor;

-- 7. Which last names are not repeated? Hint: use COUNT() and GROUP BY and HAVING
SELECT last_name, 
COUNT(*) AS num FROM actor GROUP BY last_name 
HAVING COUNT(*) = 1;

-- 8. Which last names appear more than once?
SELECT last_name, 
COUNT(*) AS num FROM actor GROUP BY last_name 
HAVING COUNT(*) > 1;

-- Use table FILM_ACTOR to solve questions as below:
-- 9. Count the number of actors in each film, order the result by the number of actors with descending order
SELECT film_id, 
COUNT(DISTINCT actor_id) AS num_of_actor 
FROM film_actor GROUP BY film_id ORDER BY num_of_actor DESC;

-- 10. How many films each actor played in?
SELECT actor_id, 
COUNT(DISTINCT film_id) AS num_of_film
FROM film_actor GROUP BY actor_id ORDER BY num_of_film DESC;


# Project 1.2 
SELECT * FROM actor LIMIT 100;
SELECT * FROM film_actor LIMIT 100;
SELECT * FROM film LIMIT 100;
SELECT * FROM language LIMIT 100;
SELECT * FROM film_category LIMIT 100;
SELECT * FROM category LIMIT 100;

-- Find language name for each film by using table Film and Language;
SELECT film.title, language.name FROM film
LEFT JOIN language ON film.language_id = language.language_id;

-- In table Film_actor, there are actor_id and film_id columns. I want to know the actor name for each actor_id, 
-- and film title for each film_id. Hint: Use multiple table Inner Join
SELECT film_actor.film_id, actor.first_name,actor.last_name,film.title
FROM actor
INNER JOIN film_actor ON film_actor.actor_id=actor.actor_id
INNER JOIN film ON film_actor.film_id=film.film_id;

SELECT fa.*, a.first_name,a.last_name, f.title  FROM 
film_actor AS fa,
actor AS a,
film AS f
WHERE fa.actor_id = a.actor_id
AND fa.film_id=f.film_id;

-- In table Film, there are no category information. I want to know which category each film belongs to.
-- Hint: use table film_category to find the category id for each film and then use table category to get category name
SELECT f.*, c.name AS category_name 
FROM film AS f
LEFT JOIN film_category AS fc
ON f.film_id=fc.film_id
LEFT JOIN category AS c
ON fc.category_id=c.category_id;

-- Select films with rental_rate > 2 and then combine the results with films with rating G, PG-13 or PG
SELECT * FROM film WHERE rating IN ('G','PG-13','PG')
UNION
SELECT * FROM film WHERE rental_rate > 2;


# Project 1.3
-- Sales
SELECT * FROM film LIMIT 100;
SELECT * FROM store;
SELECT * FROM inventory LIMIT 100;
SELECT COUNT(*) FROM rental;
SELECT * FROM rental LIMIT 100;
SELECT * FROM category LIMIT 100;
SELECT * FROM payment LIMIT 100;
SELECT * FROM film_category LIMIT 100;
SELECT * FROM film;

-- 1. How many rentals (basically, the sales volume) happened from 2005-05 to 2005-08? Hint: use date between '2005-05-01' and '2005-08-31';
SELECT count(rental_id) as volume from rental
WHERE payment_date between '2005-05-01' and '2005-08-31';

-- 2. I want to see the rental volume by month. Hint: you need to use substring function to create a month column, e.g.
SELECT COUNT(rental_id) AS volume,
SUBSTRING(rental_date,1,7) AS rental_month FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-31'
GROUP BY 2;

-- 3. Rank the staff by total rental volumes for all time period. I need the staff’s names, so you have to join with staff table
SELECT s.first_name,s.last_name, COUNT(r.rental_id) AS volume FROM rental AS r
LEFT JOIN staff AS s ON s.staff_id=r.staff_id
GROUP BY 1,2
ORDER BY volume DESC;

-- How about inventory?
Select * from inventory;
-- 4. Create the current inventory level report for each film in each store?
-- The inventory table has the inventory information for each film at each store
-- inventory_id - A surrogate primary key used to uniquely identify each item in inventory, so each inventory id means
-- each available film.
SELECT film_id,store_id, COUNT(inventory_id) FROM inventory
GROUP BY 1,2;

-- When you show the inventory level to your manager, you manager definitely wants to know the film name. 
-- Please add film name for the inventory report.
-- • Tile column in film table is the film name
-- • Should you use left join or inner join? – this depends on how you want to present your result to your manager, so there is no right or wrong answer
-- • Which table should be your base table if you want to use left join?
SELECT * FROM film;

SELECT film.title,i.film_id,i.store_id, COUNT(i.inventory_id) FROM inventory AS i
LEFT JOIN film ON film.film_id=i.film_id
GROUP BY 1,2,3;

-- 3.5
SELECT f.title AS film_name, i.film_id, i.store_id, COUNT(*)
FROM
inventory AS i
LEFT JOIN
film AS f ON i.film_id=f.film_id
GROUP BY 1,2,3;

SELECT COUNT(*) FROM inventory;
SELECT COUNT(inventory_id) FROM inventory; -- no diff

-- After you show the inventory level again to your manager, you manager still wants to know the category for each film. 
-- Please add the category for the inventory report.
-- • Name column in category table is the category name
-- • You need to join film, category, inventory, and film_category

SELECT f.title AS film_name, 
f.film_id,  -- be careful about which film_id you are using. if you select film_id from inventory table, you will get NULL value
c.name AS category, 
i.store_id, 
COUNT(i.film_id) AS num_of_stock -- be careful which column you want to count to get the inventory number. if you count(*), NULL will be counted as 1
FROM
film AS f 
LEFT JOIN inventory AS i
ON i.film_id=f.film_id
LEFT JOIN
film_category AS fc ON f.film_id=fc.film_id
LEFT JOIN
category AS c ON fc.category_id=c.category_id
GROUP BY 1,2,3,4;

-- 7. Your manager is happy now, but you need to save the query result to a table, just in case your manager wants to check again, and you may need the table to do some analysis in the future
-- • Use CREATE statement to create a table called as inventory_rep
DROP TABLE IF EXISTS inventory_rep;
CREATE TABLE inventory_rep1 AS
SELECT f.title AS film_name, 
f.film_id,  -- be careful about which film_id you are using. if you select film_id from inventory table, you will get NULL value
c.name AS category, 
i.store_id, 
COUNT(i.film_id) AS num_of_stock -- be careful which column you want to count to get the inventory number. if you count(*), NULL will be counted as 1
FROM
film AS f 
LEFT JOIN inventory AS i
ON i.film_id=f.film_id
LEFT JOIN
film_category AS fc ON f.film_id=fc.film_id
LEFT JOIN
category AS c ON fc.category_id=c.category_id
GROUP BY 1,2,3,4;

-- 8. Use your report to identify the film which is not available in any store, and the next step will be to notice the supply chain team to add the film into the store
SELECT * FROM film WHERE film_id IN
(
SELECT film_id FROM inventory_rep1 
WHERE num_of_stock = 0);
-- 还想知道别的信息 所以在film 里面选
-- 这里不是derive table


-- Let’s look at Revenue:
-- • The payment table records each payment made by a customer, with information such as the amount and the rental being paid for. Let us consider the payment amount as revenue and ignore the receivable revenue part
-- • rental_id: The rental that the payment is being applied to. This is optional because some payments are for outstanding fees and may not be directly related to a rental – which means it can be null;

-- 9. How many revenues made from 2005-05 to 2005-08 by month?
Select sum(amount), substring(payment_date,1,7) as payment_month from payment as p
where payment_date between '2005-05-01' and '2005-08-31'
group by 2;

-- describe table
describe payment;

select * from staff;
-- 10. How many revenues made from 2005-05 to 2005-08 by each store?

Select sum(p.amount), store.store_id from payment as p
join store on store.manager_staff_id=p.staff_id
where payment_date between '2005-05-01' and '2005-08-31'
group by 2;

-- 3.10
-- 如果金额找不到对应门店，没有用
select store_id, sum(amount) as revenue from 
payment p
join
staff s
on p.staff_id=s.staff_id
where payment_date 
between '2005-05-01' and '2005-05-31' group by 1;

-- 11. Say the movie rental store wants to offer unpopular movies for sale to free up shelf space for newer ones. 
-- Help the store to identify unpopular movies by counting the number of rental times for each film. 
-- Provide the film id, film name, category name so the store can also know which categories are not popular. 
-- Hint: count how many times each film was checked out and rank the result by ascending order.
-- 找到underperform的产品

select 
f.film_id, 
f.title, 
c.name as category, 
count(distinct rental_id) as times_rented 
from 
rental as r
left join inventory as i on
i.inventory_id=r.inventory_id
left join film as f on
i.film_id=f.film_id
left join film_category as fc on
fc.film_id=f.film_id
left join category as c on
c.category_id = fc.category_id
group by 1,2,3
order by 4 desc;





