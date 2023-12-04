--This is the script containing all the requested queries (saved as views), made by Leo Långberg, Elias Gaghlasian & Ammar Alzeno

--show the number of lessons given per month during a specified year
CREATE VIEW lessons_per_month AS (
		SELECT
			CASE EXTRACT(MONTH FROM lesson_time)
				WHEN 01 THEN 'January'
				WHEN 02 THEN 'February'
				WHEN 03 THEN 'March'
				WHEN 04 THEN 'April'
				WHEN 05 THEN 'May'
				WHEN 06 THEN 'June'
				WHEN 07 THEN 'July'
				WHEN 08 THEN 'August'
				WHEN 09 THEN 'September'
				WHEN 10 THEN 'October'
				WHEN 11 THEN 'November'
				WHEN 12 THEN 'December'
			 END AS Month, 	
			COUNT(lesson) AS total, 
			COUNT(individual) AS individual, 
			COUNT(grouplesson) AS group,
			COUNT(ensamble) AS ensamble 
		FROM lesson 
		LEFT JOIN individual ON lesson.lesson_id = individual.lesson_id
		LEFT JOIN grouplesson ON lesson.lesson_id = grouplesson.lesson_id
		LEFT JOIN ensamble ON lesson.lesson_id = ensamble.lesson_id
		WHERE EXTRACT(YEAR FROM lesson_time) = 2023
		GROUP BY EXTRACT(MONTH FROM lesson_time)
		ORDER BY EXTRACT(MONTH FROM lesson_time)
);



--Show how many students there are with no sibling, with one sibling, with two siblings
CREATE VIEW number_of_siblings AS (
	WITH numbered_series AS (
		SELECT 
			generate_series(0,2) AS number_of_siblings
	)
	SELECT
		number_of_siblings,
		CASE 
			WHEN number_of_siblings = 0 THEN (SELECT COUNT(student) FROM student WHERE student_id NOT IN (SELECT student_id FROM student_sibling))
			WHEN number_of_siblings = 1 THEN (SELECT COUNT(sibling_id) FROM (SELECT sibling_id FROM student_sibling GROUP BY sibling_id HAVING COUNT(sibling_id) = 1))
			WHEN number_of_siblings = 2 THEN (SELECT COUNT(sibling_id) FROM (SELECT sibling_id FROM student_sibling GROUP BY sibling_id HAVING COUNT(sibling_id) = 2))
		END AS number_of_students
	FROM numbered_series	
);



--List ids and names of all instructors who has given more than a specific number of lessons during the current month
CREATE VIEW lessons_per_instructor AS (
	WITH lessons_per_instructor_subquery AS (
		SELECT instructor_id,
			   COUNT(lesson) AS number_of_lessons,
			   EXTRACT(MON FROM lesson_time) AS month 
		FROM lesson 
		GROUP BY instructor_id, month
	)
	SELECT instructor_id,
		   SPLIT_PART(person.name, ' ', 1) AS first_name,
		   SPLIT_PART(person.name, ' ', 2) AS last_name,
		   number_of_lessons
	FROM lessons_per_instructor_subquery
	LEFT JOIN person ON lessons_per_instructor_subquery.instructor_id = person.person_id
	WHERE month = EXTRACT(MON FROM CURRENT_DATE) 
);



--List all ensembles held during the next week
CREATE VIEW weekly_ensambles AS (
  WITH all_ensambles AS (
    SELECT
      EXTRACT(DOW FROM lesson_time) AS day_of_week,
      genres,
      (lesson.max_students - lesson.student_count) AS free_slots,
      lesson.lesson_time  
    FROM
      lesson
      JOIN ensamble ON lesson.lesson_id = ensamble.lesson_id
    WHERE
      lesson.lesson_time >= CURRENT_DATE
      AND lesson.lesson_time < CURRENT_DATE + INTERVAL '1 week'
  )
  SELECT
    CASE
      WHEN day_of_week = 0 THEN 'Monday'
      WHEN day_of_week = 1 THEN 'Tuesday'
      WHEN day_of_week = 2 THEN 'Wednesday'
      WHEN day_of_week = 3 THEN 'Thursday'
      WHEN day_of_week = 4 THEN 'Friday'
      WHEN day_of_week = 5 THEN 'Saturday'
      WHEN day_of_week = 6 THEN 'Sunday'
    END AS day,
    genres,
    CASE
    	WHEN free_slots = 0 THEN 'No Seats'
    	WHEN free_slots BETWEEN 1 AND 2 THEN '1 or 2 Seats'
    	ELSE 'Many Seats'
    END AS number_of_free_seats
  FROM
    all_ensambles
  ORDER BY lesson_time, genres ASC
);

