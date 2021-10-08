--CREATE a Stored Function
--*********Create a function to count the number of actors that have names starting with a specific letter
CREATE FUNCTION count_actors_with_letter_name(letter VARCHAR(1))
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
	DECLARE actor_count int;
BEGIN
	SELECT COUNT(*) INTO actor_count
	FROM actor
	WHERE last_name LIKE CONCAT(letter, '%');
	
	RETURN actor_count;
END;
$$

SELECT count_actors_with_letter_name('B');


--*************Create a function to show which employee has the most transactions
CREATE OR REPLACE FUNCTION employee_with_most_transactions() 
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
	DECLARE employee VARCHAR;
BEGIN
	SELECT CONCAT(first_name, ' ', last_name) 
	INTO employee
	FROM staff
	WHERE staff_id = (
		SELECT staff_id
		FROM payment
		GROUP BY staff_id
		ORDER BY count(*) DESC
		LIMIT 1
	);
	
	RETURN employee;
END;
$$


SELECT employee_with_most_transactions();


--**********Create a function to show all customers in a given country
CREATE OR REPLACE FUNCTION customers_in_country(country_name VARCHAR)
RETURNS TABLE(
	id_of_customer INT,
	name_first VARCHAR,
	name_last VARCHAR,
	email_address VARCHAR
)

LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT customer_id, first_name, last_name, email
	FROM customer
	WHERE address_id IN(
		SELECT address_id
		FROM address
		WHERE city_id IN(
			SELECT city_id
			FROM city
			WHERE country_id IN(
			SELECT country_id
				FROM country
				WHERE country = country_name
			)
		)
	);
END;
$$

SELECT * FROM customers_in_country('Italy');

-------------------------------------------------------------------------------
---------------------------STORED PROCEDURES-----------------------------------
-------------------------------------------------------------------------------

select *
from customer

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC;

--------Create a stored procedure to update the company loyalty program
CREATE OR REPLACE PROCEDURE update_loyalty_status()
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE customer
	SET loyalty_member = true
	WHERE customer_id IN (
		SELECT customer_id
		FROM payment
		GROUP BY customer_id
		HAVING SUM(amount) > 100
		);
END;
$$

--updating loyalty status
CALL update_loyalty_status();

--confirm the procedure worked
SELECT customer.customer_id, SUM(amount), loyalty_member
FROM payment
JOIN customer
ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY SUM(amount) DESC;

--updating loyalty status so everyone is set to falst
UPDATE customer
SET loyalty_member = false;

--------------------------------------------------------------------------------
-----------create a procedure that will add actors to the actor table

SELECT * FROM actor
WHERE last_name = 'Campanile';

--insert data into actor table
INSERT INTO actor(
	first_name,
	last_name,
	last_update
) VALUES (
	'Dominick',
	'Campanile',
	NOW()
);
--this would be tedious and alot of work if I needed to add alot of actors to the list

--PROCEDURE so I dont have to type above every time I want to add an actor
CREATE OR REPLACE PROCEDURE add_actor(
	_first_name VARCHAR(45),
	_last_name VARCHAR(45)
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO actor(first_name, last_name, last_update)
	VALUES(_first_name, _last_name, NOW());
END;
$$;

--Execute the procedure      
CALL add_actor('Dave', 'Campanile');

SELECT *
FROM actor
WHERE first_name = 'Dave';----IT WORKS!







