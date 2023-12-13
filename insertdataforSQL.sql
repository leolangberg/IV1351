--This is the script to insert data into the database, made by Leo Långberg, Elias Gaghlasian & Ammar Alzeno

--To answer the comment made on the previous assignment regarding the use of views in the insertionscript
--the views are just used as temporary tools but as nicely pointed out the views should therefore of course be deleted at the end. 

--Begin insertion
--random generated people
INSERT INTO person (name, contact_details_tlf, personal_number, address, email) 
VALUES
  ('Emma Eriksson', '076-589-32-14', 19870421, 'Södermalmvägen 75', 'emma.eriksson@gmail.com'),
  ('Oscar Olsson', '073-124-56-78', 19930514, 'Storgatan 42', 'oscar.olsson@hotmail.com'),
  ('Mia Mårtensson', '079-987-65-43', 19881207, 'Vasagatan 103', 'mia.martensson@gmail.com'),
  ('Lucas Lundgren', '072-333-44-55', 19961102, 'Haga Parkvägen 21', 'lucas.lundgren@hotmail.com'),
  ('Isabella Ivarsson', '071-876-54-32', 19900415, 'Norra Esplanaden 89', 'isabella.ivarsson@gmail.com'),
  ('Alexander Andersson', '078-111-22-33', 19850630, 'Drottninggatan 56', 'alexander.andersson@hotmail.com'),
  ('Sofia Söderberg', '074-555-66-77', 19971218, 'Linnégatan 29', 'sofia.soderberg@gmail.com'),
  ('Elias Ekström', '075-987-65-43', 19921012, 'Västra Ågatan 5', 'elias.ekstrom@hotmail.com'),
  ('Olivia Olofsson', '070-444-33-22', 19830125, 'Östra Kyrkogatan 12', 'olivia.olofsson@gmail.com'),
  ('Victor Viktorsson', '076-654-32-10', 19980403, 'Gamla Stan 18', 'victor.viktorsson@hotmail.com'),
  ('Alice Almqvist', '072-987-65-43', 19950908, 'Sveavägen 81', 'alice.almqvist@gmail.com'),
  ('Gustav Gustafsson', '073-111-22-33', 19871014, 'Djurgårdsvägen 37', 'gustav.gustafsson@hotmail.com'),
  ('Emma Engström', '079-333-22-11', 19911027, 'Kungsgatan 62', 'emma.engstrom@gmail.com'),
  ('William Wåhlin', '077-876-54-32', 19890404, 'Hornsgatan 3', 'william.wahlin@hotmail.com'),
  ('Ella Edström', '078-222-33-44', 19980415, 'Österlånggatan 9', 'ella.edstrom@gmail.com'),
  ('Oliver Ohlsson', '074-987-65-43', 19921220, 'Birger Jarlsgatan 28', 'oliver.ohlsson@hotmail.com'),
  ('Alva Andersson', '071-444-33-22', 19951119, 'Kungsholmsgatan 15', 'alva.andersson@gmail.com'),
  ('Liam Ljungqvist', '072-555-66-77', 19860302, 'Söder Mälarstrand 8', 'liam.ljungqvist@hotmail.com'),
  ('Maja Månsson', '075-876-54-32', 19900208, 'Götgatan 73', 'maja.mansson@gmail.com'),
  ('Noah Nordström', '076-111-22-33', 19970816, 'Katarinavägen 24', 'noah.nordstrom@hotmail.com');


CREATE VIEW stud5 AS( SELECT person_id FROM person);
INSERT INTO student(student_id) 
SELECT person_id FROM stud5;

--Pairing random students to be siblings
WITH triple_siblings AS (
    SELECT student_id FROM student ORDER BY RANDOM()
)
INSERT INTO student_sibling (student_id, sibling_id)
SELECT
    a.student_id, b.student_id AS sibling_id
FROM triple_siblings a JOIN triple_siblings b ON a.student_id <> b.student_id LIMIT 2;

WITH double_siblings AS (
  SELECT student_id FROM student 
  WHERE student_id NOT IN (SELECT DISTINCT student_id FROM student_sibling) ORDER BY RANDOM()
)
INSERT INTO student_sibling( student_id, sibling_id)
SELECT
  a.student_id, b.student_id AS sibling_id
FROM double_siblings a JOIN double_siblings b ON a.student_id <> b.student_id LIMIT 1;


INSERT INTO person (name, contact_details_tlf, personal_number, address, email) 
VALUES
  ('Noah Nyström', '076-321-45-67', 19950312, 'Sveavägen 45', 'noah.nystrom@gmail.com'),
  ('Stella Sjöberg', '073-654-32-10', 19981203, 'Norrlandsgatan 27', 'stella.sjoberg@hotmail.com'),
  ('Liam Larsson', '070-987-65-43', 19921118, 'Vasaplatsen 14', 'liam.larsson@gmail.com'),
  ('Elin Ekdahl', '078-333-22-11', 19870625, 'Östergatan 56', 'elin.ekdahl@hotmail.com'),
  ('Alexander Ahlström', '071-444-55-66', 19940709, 'Kungsgatan 87', 'alexander.ahlstrom@gmail.com');


CREATE VIEW instruc3 AS( SELECT person.person_id 
      FROM person 
      LEFT JOIN student ON person.person_id = student.student_id
      WHERE student.student_id IS NULL);

INSERT INTO instructor(instructor_id)
SELECT person_id FROM instruc3;
 --instructor_time_available
WITH random_times AS ( 
  SELECT generate_series(
              '2023-01-01 08:00:00'::TIMESTAMP,
              '2023-12-31 16:00:00'::TIMESTAMP,
              '7 day'::interval
                            ) AS time_available
  )

INSERT INTO instructor_time_available( instructor_id, time_available)
SELECT i.person_id, rt.time_available
FROM random_times rt
CROSS JOIN instruc3 i;


--instruments
INSERT INTO instrument(instrument_type_name)
VALUES
  ('Piano'),( 'Guitar'), ('Bass'), ('Drums'), ('Violin'), ('Saxophone'), ('Trumpet'), ('Flute');

INSERT INTO in_stock (instrument_id, brand, cost)
VALUES
  -- Piano
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Piano'), 'Steinway', 50),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Piano'), 'Fender', 35),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Piano'), 'Gibson', 40),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Piano'), 'Ibanez', 30),
  -- Guitar
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Guitar'), 'Fender', 35),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Guitar'), 'Music Man', 45),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Guitar'), 'Yamaha', 30),
  -- Bass
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Bass'), 'Fender', 40),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Bass'), 'Music Man', 50),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Bass'), 'Gibson', 45),
  -- Drums
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Drums'), 'Pearl', 40),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Drums'), 'Yamaha', 35),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Drums'), 'Mapex', 30),
  -- Violin
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Violin'), 'Stradivarius', 50),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Violin'), 'Yamaha', 35),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Violin'), 'Stentor', 30),
  -- Saxophone
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Saxophone'), 'Yamaha', 40),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Saxophone'), 'Selmer', 50),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Saxophone'), 'Jupiter', 35),
  -- Trumpet
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Trumpet'), 'Bach', 45),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Trumpet'), 'Yamaha', 40),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Trumpet'), 'Conn', 30),
  -- Flute
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Flute'), 'Yamaha', 35),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Flute'), 'Pearl', 40),
  ((SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Flute'), 'Armstrong', 30);

--instrumentrentals??

--######---
--standard prices
INSERT INTO price(lesson_type, level, lesson_cost, valid_from)
VALUES
  ('individual'  , 'Beginner'    , 30, '2023-01-01'),
  ('individual'  , 'Intermediate', 31, '2023-01-01'),
  ('individual'  , 'Advanced'    , 32, '2023-01-01'),
  ('grouplesson' , 'Beginner'    , 40, '2023-01-01'),
  ('grouplesson' , 'Intermediate', 41, '2023-01-01'),
  ('grouplesson' , 'Advanced'    , 42, '2023-01-01'),
  ('ensamble'    , NULL          , 50, '2023-01-01');




INSERT INTO lesson(min_students, max_students, lesson_time, instructor_id)
VALUES
  (3, 5, '2023-01-15 10:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-02-20 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-03-05 09:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-04-10 13:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-05-25 10:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-06-15 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-07-20 11:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-08-30 14:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-09-10 09:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-10-05 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-11-15 12:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-12-20 14:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-12-02 09:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-12-02 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-12-03 10:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-12-03 14:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-12-04 09:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-12-04 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-12-06 15:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-12-05 15:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-01-25 11:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-02-15 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-03-10 10:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-04-20 12:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-05-05 11:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-06-25 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-07-30 10:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-08-10 14:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-09-15 09:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-10-10 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-11-20 12:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-12-25 13:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-01-05 11:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-02-25 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-03-20 10:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-04-30 12:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-05-15 11:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-06-05 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 8, '2023-07-10 10:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-08-20 14:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-10-01 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 6, '2023-10-02 09:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (2, 4, '2023-10-03 10:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (6, 8, '2023-10-04 11:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (1, 3, '2023-02-05 12:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-07-06 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (2, 4, '2023-06-07 09:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-07-08 10:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-04-09 14:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 6, '2023-07-10 15:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-02-11 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (2, 4, '2023-09-12 09:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-03-13 11:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-04-14 13:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 6, '2023-04-15 15:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (1, 3, '2023-02-16 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-07-17 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (2, 4, '2023-03-18 12:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-07-19 13:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (3, 5, '2023-01-20 15:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (4, 6, '2023-07-21 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (1, 3, '2023-07-22 09:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, '2023-07-23 08:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (2, 4, '2023-07-24 13:30:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (5, 7, '2023-06-25 15:00:00', (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1)),
  (NULL, NULL, (SELECT time_available FROM instructor_time_available LIMIT 1), (SELECT person_id FROM instruc3 ORDER BY random() LIMIT 1));




CREATE VIEW individl AS (SELECT lesson_id, ROW_NUMBER() OVER () AS row_number FROM lesson WHERE min_students IS NULL);
CREATE VIEW ensambl  AS( SELECT lesson_id, ROW_NUMBER() OVER () AS row_number FROM lesson WHERE EXTRACT(MINUTE FROM lesson_time) = 30);
CREATE VIEW groupl   AS( SELECT lesson_id, ROW_NUMBER() OVER () AS row_number FROM lesson WHERE (EXTRACT(MINUTE FROM lesson_time) = 0) AND min_students IS NOT NULL);


--random levels
CREATE VIEW random_difficulty_levels AS
WITH numbered_series AS (
  SELECT
    generate_series(1, (SELECT COUNT(*) FROM lesson)) AS row_number
)
SELECT
  row_number,
  CASE mod(row_number, 3)
    WHEN 0 THEN 'Beginner'::difficulty
    WHEN 1 THEN 'Intermediate'::difficulty
    WHEN 2 THEN 'Advanced'::difficulty
  END AS level
FROM numbered_series;

--random instruments
CREATE VIEW random_instruments AS 
WITH numbered_series AS (
    SELECT
      generate_series(1, (SELECT COUNT(*) FROM lesson)) AS row_number
)
SELECT
  row_number,
  CASE mod(row_number, 8)
    WHEN 0 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Piano')
    WHEN 1 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Guitar')
    WHEN 2 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Bass')
    WHEN 3 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Drums')
    WHEN 4 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Violin')
    WHEN 5 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Saxophone')
    WHEN 6 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Trumpet')
    WHEN 7 THEN (SELECT instrument_id FROM instrument WHERE instrument_type_name = 'Flute')
  END AS instrument_id
FROM numbered_series;

--random genres
CREATE VIEW random_genres AS 
WITH numbered_series AS (
    SELECT
      generate_series(1, (SELECT COUNT(*) FROM lesson)) AS row_number
)
SELECT
  row_number,
  CASE mod(row_number, 4)
    WHEN 0 THEN 'Classical'::genre
    WHEN 1 THEN 'Jazz'::genre
    WHEN 2 THEN 'Pop'::genre
    WHEN 3 THEN 'Rock'::genre
  END AS genres
FROM numbered_series;


-- Common Table Expression to combine data
WITH groupl_combined AS (
  SELECT
    groupl.lesson_id,
    random_difficulty_levels.level::difficulty,
    random_instruments.instrument_id
  FROM
    groupl
  JOIN
    random_difficulty_levels ON groupl.row_number = random_difficulty_levels.row_number
  JOIN
    random_instruments ON groupl.row_number = random_instruments.row_number
)
-- Insert into grouplesson
INSERT INTO grouplesson(lesson_id, level, instrument_id)
SELECT lesson_id, level, instrument_id
FROM groupl_combined;


WITH individl_combined AS (      
  SELECT
    individl.lesson_id,
    random_difficulty_levels.level::difficulty,
    random_instruments.instrument_id
  FROM
    individl
  JOIN
    random_difficulty_levels ON individl.row_number = random_difficulty_levels.row_number
  JOIN
    random_instruments ON individl.row_number = random_instruments.row_number
)
--Insert into individual
INSERT INTO individual(lesson_id, level, instrument_id)
SELECT lesson_id, level, instrument_id
FROM individl_combined;


--Insert into ensamble
WITH ensambl_combined AS (
  SELECT
    ensambl.lesson_id,
    random_genres.genres::genre
  FROM
    ensambl
  JOIN
    random_genres ON ensambl.row_number = random_genres.row_number
)
-- Insert into ensamble
INSERT INTO ensamble(lesson_id, genres)
SELECT lesson_id, genres
FROM ensambl_combined;


-- Insert Students to Lessons
WITH student_lesson_join AS (
  SELECT
    student.student_id,
    lesson.lesson_id
  FROM
    student
  CROSS JOIN
    lesson
)
INSERT INTO student_lesson_cross_reference(student_id, lesson_id)
SELECT student_id, lesson_id
FROM student_lesson_join;



--Links students to physical instruments
INSERT INTO instrument_rental(student_id, rental_id)
VALUES
  ((SELECT person_id FROM person WHERE name = 'Emma Eriksson'),  (SELECT rental_id FROM in_stock WHERE in_stock.brand = 'Steinway' AND in_stock.cost = 50)),
  ((SELECT person_id FROM person WHERE name = 'Oscar Olsson'),   (SELECT rental_id FROM in_stock WHERE in_stock.brand = 'Ibanez' AND in_stock.cost = 30)),
  ((SELECT person_id FROM person WHERE name = 'Mia Mårtensson'), (SELECT rental_id FROM in_stock WHERE in_stock.brand = 'Mapex')),
  ((SELECT person_id FROM person WHERE name = 'Lucas Lundgren'), (SELECT rental_id FROM in_stock WHERE in_stock.brand = 'Stradivarius' AND in_stock.cost = 50));


--extra ensambles that are not completely filled 
INSERT INTO lesson(min_students, max_students, lesson_time, instructor_id)
VALUES
  (2, 3, '2023-12-05 10:30:00', (SELECT instructor_id FROM instructor ORDER BY random() LIMIT 1)),
  (2, 6, '2023-12-08 10:30:00', (SELECT instructor_id FROM instructor ORDER BY random() LIMIT 1)),
  (2, 3, '2023-12-15 10:30:00', (SELECT instructor_id FROM instructor ORDER BY random() LIMIT 1)),
  (2, 6, '2023-12-12 10:30:00', (SELECT instructor_id FROM instructor ORDER BY random() LIMIT 1)),
  (2, 4, '2023-12-18 10:30:00', (SELECT instructor_id FROM instructor ORDER BY random() LIMIT 1)),
  (2, 6, '2023-12-10 10:30:00', (SELECT instructor_id FROM instructor ORDER BY random() LIMIT 1));

INSERT INTO ensamble(lesson_id, genres)
VALUES
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-05 10:30:00'), 'Jazz'),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-08 10:30:00'), 'Classical'),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-15 10:30:00'), 'Jazz'),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-12 10:30:00'), 'Classical'),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-18 10:30:00'), 'Jazz'),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-10 10:30:00'), 'Classical');

INSERT INTO student_lesson_cross_reference(lesson_id, student_id)
VALUES 
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-05 10:30:00'), (SELECT student_id FROM student ORDER BY student_id ASC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-05 10:30:00'), (SELECT student_id FROM student ORDER BY student_id DESC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-08 10:30:00'), (SELECT student_id FROM student ORDER BY student_id ASC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-08 10:30:00'), (SELECT student_id FROM student ORDER BY student_id DESC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-12 10:30:00'), (SELECT student_id FROM student ORDER BY student_id ASC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-12 10:30:00'), (SELECT student_id FROM student ORDER BY student_id DESC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-15 10:30:00'), (SELECT student_id FROM student ORDER BY student_id ASC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-15 10:30:00'), (SELECT student_id FROM student ORDER BY student_id DESC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-18 10:30:00'), (SELECT student_id FROM student ORDER BY student_id ASC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-18 10:30:00'), (SELECT student_id FROM student ORDER BY student_id DESC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-10 10:30:00'), (SELECT student_id FROM student ORDER BY student_id ASC LIMIT 1)),
  ((SELECT lesson_id FROM lesson WHERE lesson_time = '2023-12-10 10:30:00'), (SELECT student_id FROM student ORDER BY student_id DESC LIMIT 1));




--student_contact_person examples
INSERT INTO person(name, contact_details_tlf, personal_number, address, email)
VALUES
  ('Leo Långberg', '070-312-21-45', 20021003, 'Jyllandsgatan 138', 'langbergleo@gmail.com'),
  ('Elias Gaghlasian', '076-324-44-23', 20030807, 'Ringvägen 72', 'Brofist.Man43@gmail.com'),
  ('Ammar Alzeno', '072-520-33-73', 20020430, 'Kapellvägen 9', 'alzeno.ammar@gmail.com');

INSERT INTO student_contact_person(student_id, contact_person_id)
VALUES
  ((SELECT student_id FROM student ORDER BY RANDOM() LIMIT 1), (SELECT person_id FROM person WHERE name = 'Leo Långberg')),
  ((SELECT student_id FROM student ORDER BY RANDOM() LIMIT 1), (SELECT person_id FROM person WHERE name = 'Elias Gaghlasian')),
  ((SELECT student_id FROM student ORDER BY RANDOM() LIMIT 1), (SELECT person_id FROM person WHERE name = 'Ammar Alzeno'));

   
--deletes all views created in the insertion script
DROP VIEW IF EXISTS stud5, instruc3, random_difficulty_levels, random_times, individl, ensambl, groupl, groupl_combined,
          individl_combined, ensambl_combined, student_lesson_join, combined_student_rental, random_genres,
          random_instruments;
--Insertion is now complete
 
