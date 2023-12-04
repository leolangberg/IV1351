-- Database: iv1351

CREATE TYPE genre         AS ENUM('Classical', 'Jazz', 'Pop', 'Rock');
CREATE TYPE instrumentals AS ENUM('Piano', 'Guitar', 'Bass', 'Drums', 'Violin', 'Saxophone', 'Trumpet', 'Flute');
CREATE TYPE difficulty    AS ENUM('Beginner','Intermediate','Advanced');
CREATE TYPE lesson_type   AS ENUM('individual', 'grouplesson', 'ensamble');


CREATE TABLE person (
  person_id SERIAL NOT NULL,
  name VARCHAR(100) NOT NULL,
  contact_details_tlf VARCHAR(100) NOT NULL,
  personal_number INT UNIQUE NOT NULL,
  address VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,    --email not implemented yet
  PRIMARY KEY(person_id)
);
      CREATE TABLE student (
        student_id SERIAL REFERENCES person(person_id) ON DELETE CASCADE,
        PRIMARY KEY(student_id)
      );
          CREATE TABLE student_sibling (
            student_id  SERIAL REFERENCES student(student_id) ON DELETE CASCADE,
            sibling_id SERIAL REFERENCES student(student_id) ON DELETE CASCADE,
            PRIMARY KEY(student_id, sibling_id)
          );
            CREATE TABLE student_contact_person (
            student_id SERIAL REFERENCES student(student_id) ON DELETE CASCADE,
            contact_person_id SERIAL REFERENCES person(person_id) ON DELETE CASCADE,
            PRIMARY KEY(student_id, contact_person_id)
          );

CREATE TABLE instructor (
	instructor_id SERIAL REFERENCES person(person_id) ON DELETE CASCADE,
    PRIMARY KEY(instructor_id)
);

CREATE TABLE instructor_time_available (
     instructor_id SERIAL REFERENCES instructor(instructor_id) ON DELETE CASCADE,
     time_available TIMESTAMP NOT NULL,
     PRIMARY KEY(instructor_id, time_available)
);

CREATE TABLE instrument (
  instrument_id SERIAL NOT NULL,
  instrument_type_name instrumentals UNIQUE NOT NULL,
  PRIMARY KEY(instrument_id)
);

CREATE TABLE price (
  price_id SERIAL NOT NULL,
  lesson_type lesson_type NOT NULL,
  level difficulty,  
  lesson_cost DOUBLE PRECISION NOT NULL,
  valid_from  TIMESTAMP NOT NULL,
  PRIMARY KEY(price_id)
);

CREATE TABLE lesson (    
  lesson_id SERIAL NOT NULL, 
  student_count INT NOT NULL DEFAULT 0,
  min_students INT,
  max_students INT,  
  lesson_time TIMESTAMP NOT NULL,
  instructor_id SERIAL REFERENCES instructor(instructor_id), 
  price_id SERIAL REFERENCES price(price_id),
  PRIMARY KEY(lesson_id)
);
ALTER TABLE lesson ALTER COLUMN price_id DROP NOT NULL;
ALTER TABLE lesson ALTER COLUMN price_id DROP DEFAULT;

CREATE TABLE individual (
  lesson_id SERIAL REFERENCES lesson(lesson_id) ON DELETE CASCADE,
  level difficulty NOT NULL,
  instrument_id SERIAL REFERENCES instrument(instrument_id),
  PRIMARY KEY(lesson_id, instrument_id)  
);

CREATE TABLE grouplesson (
  lesson_id SERIAL REFERENCES lesson(lesson_id) ON DELETE CASCADE,
  level difficulty NOT NULL,
  instrument_id SERIAL REFERENCES instrument(instrument_id),
  PRIMARY KEY(lesson_id, instrument_id) 
);

CREATE TABLE ensamble (
  lesson_id SERIAL REFERENCES lesson(lesson_id) ON DELETE CASCADE,
  genres genre NOT NULL,
  PRIMARY KEY(lesson_id)
);


CREATE TABLE student_lesson_cross_reference (     
  lesson_id SERIAL REFERENCES lesson(lesson_id) ON DELETE CASCADE,
  student_id SERIAL REFERENCES student(student_id) ON DELETE CASCADE,
  PRIMARY KEY(lesson_id, student_id)
);



CREATE TABLE in_stock (
  instrument_id SERIAL REFERENCES instrument(instrument_id),
  rental_id SERIAL NOT NULL,
  brand VARCHAR(100),
  cost DOUBLE PRECISION NOT NULL,
  PRIMARY KEY(rental_id)
  
);

CREATE TABLE instrument_rental (
  time_rented DATE NOT NULL DEFAULT CURRENT_DATE,
  time_returned DATE,
  student_id SERIAL REFERENCES student(student_id),
  rental_id SERIAL REFERENCES in_stock(rental_id),
  PRIMARY KEY(student_id, rental_id)
);


--#######################################################################################
--#######################################################################################
--TRIGGERS--
--#######################################################################################
--#######################################################################################

-- max 2 rented instruments (TRIGGER)
CREATE OR REPLACE FUNCTION check_max_rented_instruments()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    SELECT COUNT(*)
    FROM instrument_rental
    WHERE student_id = NEW.student_id
  ) >= 2 THEN
    RAISE NOTICE 'A student can rent at most 2 instruments at the same time';
    RETURN NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER max_rented_instruments_trigger
BEFORE INSERT OR UPDATE
ON instrument_rental
FOR EACH ROW
EXECUTE FUNCTION check_max_rented_instruments();


--each rental_id can only correspond to 1 student
CREATE OR REPLACE FUNCTION unique_rental_function()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM instrument_rental WHERE rental_id = NEW.rental_id
  ) THEN
  RAISE NOTICE '%rental_id already rented', NEW.rental_id;
  RETURN NULL;
END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unique_rental_trigger
BEFORE INSERT OR UPDATE
ON instrument_rental
FOR EACH ROW
EXECUTE FUNCTION unique_rental_function();


--if 'individual' then set min/max + lesson_type
CREATE OR REPLACE FUNCTION set_default_students_for_individual()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE lesson
  SET min_students = COALESCE(min_students, 1),
      max_students = COALESCE(max_students, 1),
      price_id = (SELECT price_id FROM price 
                  WHERE lesson_type = 'individual' 
                  AND level = NEW.level 
                  ORDER BY valid_from
                  LIMIT 1
                  ) 
  WHERE lesson_id = NEW.lesson_id;
  RAISE NOTICE 'set_default_individual';

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_students_for_individual_trigger
AFTER INSERT
ON individual
FOR EACH ROW
EXECUTE FUNCTION set_default_students_for_individual();

--lesson_type for grouplesson
CREATE OR REPLACE FUNCTION set_default_grouplesson()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE lesson
  SET price_id = (SELECT price_id FROM price 
                  WHERE lesson_type = 'grouplesson' 
                  AND level = NEW.level 
                  ORDER BY valid_from
                  LIMIT 1
                  ) 
  WHERE lesson_id = NEW.lesson_id;
  RAISE NOTICE 'set_default_grouplesson';

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_grouplesson_trigger
AFTER INSERT
ON grouplesson
FOR EACH ROW
EXECUTE FUNCTION set_default_grouplesson();

--lesson_type for ensamble
CREATE OR REPLACE FUNCTION set_default_ensamble()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE lesson
  SET price_id = (SELECT price_id FROM price 
                  WHERE lesson_type = 'ensamble' 
                  ORDER BY valid_from
                  LIMIT 1
                  ) 
  WHERE lesson_id = NEW.lesson_id;
  RAISE NOTICE 'set_default_ensamble for lesson_id: % ', NEW.lesson_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_ensamble_trigger
AFTER INSERT
ON ensamble
FOR EACH ROW
EXECUTE FUNCTION set_default_ensamble();





--student_count updated from student_lesson_cross_reference (TRIGGER)
CREATE OR REPLACE FUNCTION update_student_count()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the lesson is full
  IF (
    SELECT COUNT(slcr.student_id)
    FROM student_lesson_cross_reference slcr
    WHERE slcr.lesson_id = NEW.lesson_id
  ) > (SELECT max_students FROM lesson WHERE lesson_id = NEW.lesson_id) THEN
     RAISE NOTICE 'Lesson is full. Cannot add more students to lesson_id: %', NEW.lesson_id;
     RETURN NULL;
  END IF;

  -- If the lesson is not full, update the student count
  UPDATE lesson
  SET student_count = (
    SELECT COUNT(slcr.student_id)
    FROM student_lesson_cross_reference slcr
    WHERE slcr.lesson_id = NEW.lesson_id
  )
  WHERE lesson_id = NEW.lesson_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_student_count_trigger
BEFORE INSERT OR UPDATE 
ON student_lesson_cross_reference
FOR EACH ROW
EXECUTE FUNCTION update_student_count();







--Symmetrical Sibling inserts--
--tertiary (works for multiple siblings)
CREATE OR REPLACE FUNCTION symmetrical_sibling_trigger()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert the new sibling link
  INSERT INTO student_sibling(student_id, sibling_id)
  VALUES (NEW.sibling_id, NEW.student_id)
  ON CONFLICT DO NOTHING;

  -- Check if the newly inserted student has existing siblings
  IF EXISTS (
    SELECT 1
    FROM student_sibling
    WHERE student_id = NEW.student_id
  ) THEN
    -- Link the new student to existing siblings
    INSERT INTO student_sibling(student_id, sibling_id)
    SELECT NEW.student_id, sibling_id
    FROM student_sibling
    WHERE student_id = NEW.sibling_id
      AND sibling_id != NEW.student_id
    ON CONFLICT DO NOTHING;

    -- Link existing siblings to the new student
    INSERT INTO student_sibling(student_id, sibling_id)
    SELECT sibling_id, NEW.student_id
    FROM student_sibling
    WHERE student_id = NEW.student_id
      AND sibling_id != NEW.sibling_id
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER symmetrical_sibling
AFTER INSERT 
ON student_sibling
FOR EACH ROW
EXECUTE FUNCTION symmetrical_sibling_trigger();


--Symmetrical Sibling deletes--
CREATE OR REPLACE FUNCTION symmetrical_sibling_delete_trigger()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM student_sibling
  WHERE OLD.student_id = sibling_id AND OLD.sibling_id = student_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER symmetrical_sibling_del
AFTER DELETE
ON student_sibling
FOR EACH ROW
EXECUTE FUNCTION symmetrical_sibling_delete_trigger();









CREATE OR REPLACE FUNCTION time_available_booked_function()
RETURNS TRIGGER AS $$
DECLARE
  t TIMESTAMP;  -- Declare a variable to store the result of the SELECT statement
BEGIN
  SELECT l.lesson_time
  INTO t
  FROM lesson l
  WHERE l.lesson_id = NEW.lesson_id;

  -- Check if there is a matching time_available in instructor_time_available
  IF EXISTS (
    SELECT 1
    FROM instructor_time_available
    WHERE time_available = t
  ) THEN
    -- If a match is found, delete the corresponding record in instructor_time_available
    DELETE FROM instructor_time_available WHERE time_available = t;
    RAISE NOTICE 'time_available for % found', NEW.lesson_id;
  ELSE
    -- If no match is found, raise an exception
    DELETE FROM lesson WHERE lesson_id = NEW.lesson_id;
    RAISE NOTICE 'Lesson with lesson_id % deleted', NEW.lesson_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

---individual makes use of the isntructor_time_available ---
CREATE TRIGGER time_available_booked
AFTER INSERT
ON individual
FOR EACH ROW
EXECUTE FUNCTION time_available_booked_function();


--corrects updates on price
CREATE OR REPLACE FUNCTION update_prices_function()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE lesson
  SET price_id = NEW.price_id
  WHERE (SELECT lesson_type FROM price WHERE lesson.price_id = price.price_id) = NEW.lesson_type 
  AND (NEW.level IS NULL OR (SELECT level FROM price WHERE lesson.price_id = price.price_id) = NEW.level)
  AND lesson_time > NEW.valid_from;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_prices 
AFTER UPDATE
ON price
FOR EACH ROW
EXECUTE FUNCTION update_prices_function();






