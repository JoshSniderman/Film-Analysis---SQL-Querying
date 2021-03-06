use sakila;


# Example 1

#  Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor
;


# Example 2

#  Display the first and last name of each actor in a single column in upper case letters. Name the column "Actor Name."
SELECT CONCAT(UPPER(IFNULL(first_name, '')), ' ', UPPER(IFNULL(last_name, ''))) as "Actor Name"
FROM actor
;

#  You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe"
;

#  Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name REGEXP 'GEN'
;

#  Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id,first_name, last_name
FROM actor
WHERE last_name REGEXP 'LI'
ORDER BY last_name, first_name
;

#  Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China')
;


# Example 3

#  You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description blob
;

#  Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description
;


# Example 4

#  List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
;

#  List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name) > 1
;

#  The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS"
;

#  Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS"
;


# Example 5

#  You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address
;

SHOW CREATE TABLE address
;
 
CREATE TABLE IF NOT EXISTS 
address (address_id smallint(5) unsigned NOT NULL AUTO_INCREMENT, 
		address varchar(50) NOT NULL, 
		address2 varchar(50) DEFAULT NULL, 
        district varchar(20) NOT NULL, 
        city_id smallint(5) unsigned NOT NULL, 
        postal_code varchar(10) DEFAULT NULL, 
        phone varchar(20) NOT NULL, 
        location geometry NOT NULL, 
        last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
        PRIMARY KEY (address_id), KEY idx_fk_city_id (city_id), 
        SPATIAL KEY idx_location (location), 
		CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON UPDATE CASCADE ) 
        ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
;


# Example 6

#  Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name,a.address
FROM staff s
JOIN address a
	ON s.address_id=a.address_id
;

#  Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, sum(p.amount) as Amount
FROM staff s
JOIN payment p
	ON s.staff_id=p.staff_id
WHERE MONTH(p.payment_date) = 08 AND YEAR(p.payment_date) = 2005
GROUP BY s.first_name,s.last_name
;

#  List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, count(fa.actor_id) as Actors
FROM film f
JOIN film_actor fa
	ON f.film_id = fa.film_id
GROUP BY f.film_id
;

#  How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, count(i.film_id) as films_in_inventory
FROM film f
JOIN inventory i
	ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible"
;

#  Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name,sum(p.amount) as total_paid
FROM customer c
JOIN payment p
	ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name
;


# Example 7

#  The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE title REGEXP '^K|^Q'
AND language_id in
	(SELECT language_id FROM language
    WHERE name = "English")
;

#  Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
		)
	)
;

#  You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name,c.last_name,c.email
FROM customer c
JOIN address a
	ON c.address_id = a.address_id
JOIN city
	ON a.city_id = city.city_id 
JOIN country
	ON city.country_id = country.country_id
WHERE country.country = "Canada"
;

#  Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title
FROM film f
JOIN film_category fc
	ON f.film_id = fc.film_id
JOIN category c
	ON fc.category_id = c.category_id
WHERE c.name = "Family"
;

#  Display the most frequently rented movies in descending order.
SELECT f.title, count(r.inventory_id) as num_rentals
FROM film f
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY num_rentals desc
;

#  Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id,SUM(p.amount) as Revenue
FROM store s
JOIN inventory i 
	ON s.store_id = i.store_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN payment p 
	ON p.rental_id = r.rental_id
GROUP BY s.store_id
;

#  Write a query to display for each store its store ID, city, and country.
SELECT s.store_id,city.city,country.country
FROM store s
JOIN address a
	ON s.address_id = a.address_id
JOIN city
	ON a.city_id = city.city_id
JOIN country
	ON city.country_id = country.country_id
GROUP BY s.store_id
;

#  List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name as Genre, SUM(p.amount) as Revenue
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN inventory i
	ON fc.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN payment p
	ON p.rental_id = r.rental_id
GROUP BY Genre
ORDER BY Revenue DESC
LIMIT 5
;

#  In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT c.name as Genre,SUM(p.amount) as Revenue
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN inventory i
	ON fc.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN payment p
	ON p.rental_id = r.rental_id
GROUP BY Genre
ORDER BY Revenue DESC
LIMIT 5
;

#  How would you display the view that you created in 8a?
SELECT * FROM top_five_genres
;

#  You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres
;