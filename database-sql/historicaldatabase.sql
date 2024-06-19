--This is the script containing the historical database, made by Leo Långberg, Elias Gaghlasian & Ammar Alzeno

--PLEASE NOTE, since a way to move data between databases has not been created yet,
--to actually test this query then historical_data table should be created in the existing database 
--the ENUMs below should already be in the main database and can therefore be skipped. 
CREATE TYPE lesson_type   AS ENUM('individual', 'grouplesson', 'ensamble');
CREATE TYPE genre         AS ENUM('Classical', 'Jazz', 'Pop', 'Rock');
CREATE TYPE instrumentals AS ENUM('Piano', 'Guitar', 'Bass', 'Drums', 'Violin', 'Saxophone', 'Trumpet', 'Flute');

--database
CREATE TABLE historical_data (
	historical_data_id SERIAL NOT NULL,
	lesson_type lesson_type NOT NULL,
	genres genre,
	instrument instrumentals,
	lesson_price NUMERIC(5,1) NOT NULL,
	student_name VARCHAR(100) NOT NULL,
	student_email VARCHAR(100) NOT NULL,
	PRIMARY KEY(historical_data_id)
);

--Query for inserting historical data
WITH data AS (
	WITH student_data AS (
		SELECT DISTINCT
			person_id,
			person.name,
			person.email,
			student_id AS sibling_discount
		FROM person LEFT JOIN student_sibling ON person.person_id = student_sibling.student_id
	)
	SELECT 
		price.lesson_type AS lesson_type,
		ensamble.genres AS genres,
		instrument.instrument_type_name AS instrument,
		CASE
			WHEN sibling_discount IS NOT NULL THEN (price.lesson_cost * 0.8)
			ELSE price.lesson_cost
		END AS lesson_price,
		student_data.name AS student_name,
		student_data.email AS student_email

	FROM lesson
	LEFT JOIN student_lesson_cross_reference ON lesson.lesson_id = student_lesson_cross_reference.lesson_id
	LEFT JOIN price ON lesson.price_id = price.price_id
	LEFT JOIN student_data ON student_data.person_id = student_lesson_cross_reference.student_id
	LEFT JOIN ensamble ON lesson.lesson_id = ensamble.lesson_id
	LEFT JOIN grouplesson ON lesson.lesson_id = grouplesson.lesson_id
	LEFT JOIN individual ON lesson.lesson_id = individual.lesson_id
	LEFT JOIN instrument ON (grouplesson.instrument_id = instrument.instrument_id AND price.lesson_type = 'grouplesson') 
		 	     OR (individual.instrument_id = instrument.instrument_id AND price.lesson_type = 'individual')
)
INSERT INTO historical_data(lesson_type, genres, instrument, lesson_price, student_name, student_email)
SELECT lesson_type, genres, instrument, lesson_price, student_name, student_email FROM data;


---##############################################################################--
---##Below this line here does not attain to the actual historical database in task 3
---##Code below is for task 4 to keep track fo historical rentals
---##############################################################################--


CREATE TABLE historical_rental (   --references if historical database?
	historical_rental_id SERIAL NOT NULL,
	rental_id INT NOT NULL,
	monthly_cost NUMERIC(5,1) NOT NULL,
	student_id INT NOT NULL,
	time_rented DATE NOT NULL,
	time_returned DATE NOT NULL DEFAULT CURRENT_DATE,
	PRIMARY KEY(historical_rental_id)
);

