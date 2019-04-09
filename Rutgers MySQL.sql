USE sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name 
FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT (first_name, " ", last_name))
FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%LI%'
  ORDER BY last_name, first_name; 

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
  ADD description BLOB;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
  DROP description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(first_name) as count_of_last_name
FROM actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(first_name) as count_of_last_name
FROM actor
GROUP BY last_name
HAVING count_of_last_name >=2;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
SET SQL_SAFE_UPDATES = 1;

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";
SET SQL_SAFE_UPDATES = 1;

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT a.first_name, a.last_name, b.address
FROM staff as a
INNER JOIN address as b ON a.address_id = b.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT a.first_name, a.last_name, SUM(b.amount) as total_amount
FROM staff as a
JOIN payment as b ON a.staff_id = b.staff_id
WHERE b.payment_date LIKE "2005-08%"
GROUP BY a.first_name, a.last_name;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT a.title, count(b.actor_id) as count_of_actors
FROM film as a
INNER JOIN film_actor as b ON a.film_id = b.film_id
GROUP BY a.title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id IN(
  SELECT film_id
  FROM film
  WHERE title = "Hunchback Impossible"
);

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT a.first_name, a.last_name, SUM(b.amount) as total_amount
FROM customer as a
JOIN payment as b ON a.customer_id = b.customer_id
GROUP BY a.first_name, a.last_name
ORDER BY a.last_name ASC;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE (title LIKE "Q%" OR title LIKE "K%") AND language_id IN(
  SELECT language_id
  FROM language
  WHERE name = "ENGLISH"
); 
-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN(
    SELECT film_id
    FROM film
    WHERE title = "Alone Trip"
)); 

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT a.first_name, a.last_name, a.email, d.country
FROM customer as a
JOIN address as b
ON a.address_id = b.address_id 
JOIN city as c
ON b.city_id = c.city_id
JOIN country as d
ON c.country_id = d.country_id
WHERE d.country = "Canada";

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN(
  SELECT film_id
  FROM film_category
  WHERE category_id IN(
    SELECT category_id
    FROM category
    WHERE name = "Family"
));

-- * 7e. Display the most frequently rented movies in descending order.
SELECT a.title, COUNT(c.rental_id) as rental_count
FROM film as a
JOIN inventory as b
ON a.film_id = b.film_id
JOIN rental as c
ON b.inventory_id = c.inventory_id
GROUP BY a.title
ORDER BY rental_count DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT a.store_id, SUM(b.amount) as total_business
FROM staff as a
JOIN PAYMENT as b
ON a.staff_id = b.staff_id
GROUP BY a.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT a.store_id, c.city, d.country
FROM store as a
JOIN address as b
ON a.address_id = b.address_id
JOIN city as c
ON b.city_id = c.city_id
JOIN country as d
ON c.country_id = d.country_id;

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT a.name, SUM(e.amount) as gross_revenue
FROM category as a
JOIN film_category as b
ON a.category_id = b.category_id
JOIN inventory as c
ON b.film_id = c.film_id
JOIN rental as d
ON c.inventory_id = d.inventory_id
JOIN payment as e
ON d.rental_id = e.rental_id
GROUP BY a.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT a.name, SUM(e.amount) as gross_revenue
FROM category as a
JOIN film_category as b
ON a.category_id = b.category_id
JOIN inventory as c
ON b.film_id = c.film_id
JOIN rental as d
ON c.inventory_id = d.inventory_id
JOIN payment as e
ON d.rental_id = e.rental_id
GROUP BY a.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;