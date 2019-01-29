USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(UPPER(first_name),' ', UCASE(last_name)) AS 'Actor Name' FROM actor;
/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
What is one query would you use to obtain this information? */
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE '%GEN%';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
as the difference between it and VARCHAR are significant). */
ALTER TABLE actor ADD COLUMN Description BLOB;
SELECT * FROM actor;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN Description;
SELECT * FROM actor;
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Number of Last Names' FROM actor
GROUP BY last_name;
/* 4b. List last names of actors and the number of actors who have that last name,
but only for names that are shared by at least two actors*/
SELECT last_name, COUNT(last_name) AS 'Number of Actors' FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT * FROM actor WHERE last_name = 'WILLIAMS';
/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
SELECT * FROM actor WHERE first_name = 'HARPO';
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';
/* 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html */
SHOW CREATE TABLE address;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address  FROM staff AS s
JOIN address AS a ON s.address_id = a.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS 'Total Amount Rung' FROM staff AS s
JOIN payment AS p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.film_id, f.title, COUNT(fa.actor_id) AS 'Number of Actors' FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
GROUP BY f.film_id, f.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(f.title) AS 'Number of Copies' FROM film AS f
JOIN inventory AS i ON f.film_id = i.film_id
GROUP BY f.title
HAVING f.title = 'Hunchback Impossible';
/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
List the customers alphabetically by last name: */
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total Paid' FROM customer AS c
JOIN payment AS p ON c.customer_id = p.customer_id
GROUP BY c.last_name, c.first_name;
/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. */
SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%'
AND language_id IN
(
SELECT language_id FROM language
WHERE name = 'English'
);
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor WHERE actor_id IN
(
SELECT actor_id FROM film_actor WHERE film_id IN
(
SELECT film_id FROM film WHERE title = 'Alone Trip'
));

/* 7c. You want to run an email marketing campaign in Canada, 
for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information. */
SELECT first_name, last_name, email FROM customer WHERE address_id IN
(
SELECT address_id FROM address WHERE city_id IN
(
SELECT city_id FROM city WHERE country_id IN
(
SELECT country_id FROM country WHERE country = 'Canada'
)));
/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films. */
SELECT * FROM category;
SELECT title FROM film WHERE film_id IN
(
SELECT film_id FROM film_category WHERE category_id IN
(
SELECT category_id FROM category WHERE name = 'Family'
));
-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) AS 'Number of Rented Movies' FROM film AS f
JOIN inventory AS i ON f.film_id = i.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS 'Revenue' FROM payment AS p
JOIN staff AS stf ON p.staff_id = stf.staff_id
JOIN store AS s ON stf.store_id = s.store_id
GROUP BY store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ct.city, cn.country FROM store AS s
JOIN address AS a ON s.address_id = a.address_id
JOIN city AS ct ON a.city_id = ct.city_id
JOIN country AS cn ON ct.country_id = cn.country_id;
/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */
SELECT cat.name, SUM(p.amount) AS 'Gross Revenue' FROM category AS cat
JOIN film_category AS fc ON cat.category_id = fc.category_id
JOIN inventory AS i ON fc.film_id = i.film_id
JOIN rental AS r ON i.inventory_id = r.inventory_id
JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY cat.name ORDER BY SUM(p.amount) desc LIMIT 5;
/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view. */
DROP VIEW IF EXISTS top5_revenue_genre;
CREATE VIEW top5_revenue_genre AS
SELECT cat.name, SUM(p.amount) AS 'Gross Revenue' FROM category AS cat
JOIN film_category AS fc ON cat.category_id = fc.category_id
JOIN inventory AS i ON fc.film_id = i.film_id
JOIN rental AS r ON i.inventory_id = r.inventory_id
JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY cat.name ORDER BY SUM(p.amount) desc LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_revenue_genre;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5_revenue_genre;
