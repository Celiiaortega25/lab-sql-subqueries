USE sakila;
-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) AS num_copies FROM inventory as i
JOIN film as f 
ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';
-- List all films whose length is longer than the average of all the films.
SELECT title, avg(length) FROM film
WHERE length > (SELECT AVG(length) FROM film)
GROUP BY title;
-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN (
  SELECT actor_id
  FROM film_actor
  WHERE film_id = (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
  )
);
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film
WHERE film_id IN (
  SELECT film_id FROM film_category
  WHERE category_id = (
    SELECT category_id
    FROM category
    WHERE name = 'Family'
  )
);
-- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
-- using subqueries
SELECT first_name, last_name, email FROM customer
WHERE address_id IN (
  SELECT address_id FROM address
  WHERE city_id IN (
    SELECT city_id FROM city
    WHERE country_id = (
      SELECT country_id FROM country
      WHERE country = 'Canada'
    )
  )
);
-- using joins
SELECT first_name, last_name, email FROM customer as c
JOIN address as a ON c.address_id = a.address_id
JOIN city as ci ON a.city_id = ci.city_id
JOIN country as co ON ci.country_id = co.country_id
WHERE country = 'Canada';
-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred
SELECT title FROM film
WHERE film_id IN (
  SELECT film_id FROM film_actor
  WHERE actor_id = (
    SELECT actor_id FROM (
      SELECT actor_id, COUNT(*) AS film_count FROM film_actor
      GROUP BY actor_id
      ORDER BY film_count DESC
      LIMIT 1
    ) AS most_prolific_actor
  )
);
-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT title
FROM film
WHERE film_id IN (
  SELECT film_id FROM rental as r
  JOIN payment as p ON r.rental_id = p.rental_id
  WHERE p.customer_id = (
    SELECT customer_id FROM (
      SELECT customer_id, SUM(amount) AS total_payments
      FROM payment
      GROUP BY customer_id
      ORDER BY total_payments DESC
      LIMIT 1
    ) AS most_profitable_customer
  )
);
-- Customers who spent more than the average payments
SELECT first_name, last_name, SUM(amount) AS total_payments FROM customer as c
JOIN payment as p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING SUM(amount) > (
  SELECT AVG(total_payments)
  FROM (
    SELECT customer_id, SUM(amount) AS total_payments
    FROM payment
    GROUP BY customer_id
  ) AS customer_payments
)
ORDER BY total_payments DESC;
