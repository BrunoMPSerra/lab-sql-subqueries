USE sakila

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT * FROM inventory;
SELECT * FROM film;

SELECT 
    film.title,
    COUNT(inventory.inventory_id) AS number_of_copies
FROM
    film
        JOIN
    inventory ON film.film_id = inventory.film_id
WHERE
    film.title = 'Hunchback Impossible'
GROUP BY film.title;

-- List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT 
    film.title, 
    film.length
FROM 
    film
WHERE 
    film.length > (SELECT AVG(length) FROM film)
ORDER BY 
    film.length DESC;

-- Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT * FROM actor;
SELECT * FROM film_actor;
SELECT * FROM film;

SELECT 
    actor.first_name, actor.last_name
FROM
    actor
WHERE
    actor.actor_id IN (SELECT 
            film_actor.actor_id
        FROM
            film_actor
                JOIN
            film ON film_actor.film_id = film.film_id
        WHERE
            film.title = 'Alone Trip');

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

SELECT * FROM category;
SELECT * FROM film;
SELECT * FROM film_category;

SELECT 
    category.name, film.title
FROM
    film
        JOIN
    film_category ON film.film_id = film_category.film_id
        JOIN
    category ON film_category.category_id = category.category_id
WHERE
    category.name = 'Family';

-- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT 
    customer.first_name, customer.last_name, customer.email
FROM
    customer
WHERE
    customer.address_id IN (SELECT 
            address.address_id
        FROM
            address
        WHERE
            address.city_id IN (SELECT 
                    city.city_id
                FROM
                    city
                WHERE
                    city.country_id = (SELECT 
                            country.country_id
                        FROM
                            country
                        WHERE
                            country.country = 'Canada')));

-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT * FROM actor;
SELECT * FROM film_actor;
SELECT * FROM film;

SELECT 
    actor.actor_id,
    actor.first_name,
    actor.last_name,
    COUNT(film_actor.film_id) AS film_count
FROM
    actor
        JOIN
    film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id , actor.first_name , actor.last_name
ORDER BY film_count DESC
LIMIT 1;

SELECT 
    film.title
FROM
    film
        JOIN
    film_actor ON film.film_id = film_actor.film_id
WHERE
    film_actor.actor_id = (SELECT 
            actor.actor_id
        FROM
            actor
                JOIN
            film_actor ON actor.actor_id = film_actor.actor_id
        GROUP BY actor.actor_id
        ORDER BY COUNT(film_actor.film_id) DESC
        LIMIT 1);

-- Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    SUM(payment.amount) AS total_payments
FROM
    customer
        JOIN
    payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id , customer.first_name , customer.last_name
ORDER BY total_payments DESC
LIMIT 1;

SELECT DISTINCT
    film.title
FROM
    rental
        JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
        JOIN
    film ON inventory.film_id = film.film_id
WHERE
    rental.customer_id = (SELECT 
            customer.customer_id
        FROM
            customer
                JOIN
            payment ON customer.customer_id = payment.customer_id
        GROUP BY customer.customer_id
        ORDER BY SUM(payment.amount) DESC
        LIMIT 1);

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.

SELECT 
    customer.customer_id AS client_id,
    SUM(payment.amount) AS total_amount_spent
FROM
    customer
        JOIN
    payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
HAVING SUM(payment.amount) > (SELECT 
        AVG(total_amount)
    FROM
        (SELECT 
            SUM(payment.amount) AS total_amount
        FROM
            payment
        GROUP BY payment.customer_id) AS client_totals);