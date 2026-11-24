-- Exercise 1.1: CityBike setup
DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

CREATE TABLE stations (
    station_id INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city VARCHAR(40) NOT NULL,
    capacity INT NOT NULL
);
CREATE TABLE bikes (
    bike_id INT PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);
CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    member_id INT REFERENCES members(member_id),
    bike_id INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date DATE,
    fee NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty', 4), (20, 'Riverside', 'Almaty', 3),
 (30, 'Expo Gate', 'Astana', 5), (40, 'Old Town', 'Shymkent', 2),
 (50, 'Depot', 'Astana', 0);
INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10, 4.50), (102, 'City Cruiser', 10, 4.50),
 (103, 'Mountain X', 20, 7.00), (104, 'Mountain X', 30, 7.00),
 (105, 'Road Sprint', 30, 9.25), (106, 'Folding Mini', 40, 3.75),
 (107, 'Cargo Hauler', 20, 12.00), (108, 'Road Sprint', 10, 9.25);
INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty', DATE '2023-03-14'),
 (2, 'Daniyar Serik', 'Almaty', DATE '2023-07-02'),
 (3, 'Marta Kowalski', 'Astana', DATE '2024-01-20'),
 (4, 'Chen Wei', 'Astana', DATE '2024-05-11'),
 (5, 'Omar Haddad', 'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova', 'Almaty', DATE '2025-02-05');
INSERT INTO rentals VALUES
 (1,1,101,DATE '2024-04-05',DATE '2024-04-08',13.50),
 (2,1,103,DATE '2024-06-11',DATE '2024-06-16',35.00),
 (3,1,108,DATE '2025-02-02',DATE '2025-02-04',18.50),
 (4,1,102,DATE '2025-05-20',DATE '2025-05-27',31.50),
 (5,2,101,DATE '2024-05-01',DATE '2024-05-02',4.50),
 (6,2,107,DATE '2024-11-15',DATE '2024-11-19',48.00),
 (7,2,107,DATE '2025-03-08',DATE '2025-03-14',72.00),
 (8,3,104,DATE '2024-02-14',DATE '2024-02-18',28.00),
 (9,3,105,DATE '2024-08-03',DATE '2024-08-06',27.75),
 (10,3,104,DATE '2025-01-09',DATE '2025-01-10',7.00),
 (11,3,105,DATE '2025-06-01',DATE '2025-06-09',74.00),
 (12,4,104,DATE '2024-07-19',DATE '2024-07-21',14.00),
 (13,4,105,DATE '2025-04-12',DATE '2025-04-15',27.75),
 (14,4,103,DATE '2025-07-23',DATE '2025-07-29',42.00),
 (15,5,106,DATE '2024-10-05',DATE '2024-10-12',26.25),
 (16,5,106,DATE '2025-01-18',DATE '2025-01-20',7.50),
 (17,5,106,DATE '2025-08-14',DATE '2025-08-21',26.25),
 (18,2,102,DATE '2025-09-02',DATE '2025-09-05',13.50),
 (19,1,101,DATE '2025-10-10',NULL,NULL),
 (20,4,108,DATE '2024-12-28',DATE '2025-01-03',55.50),
 (21,3,103,DATE '2025-02-26',DATE '2025-03-02',28.00),
 (22,5,104,DATE '2025-05-05',DATE '2025-05-08',21.00);

-- Exercise 2.1: A function over one row
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE result INT;
BEGIN
    SELECT end_date - start_date INTO result FROM rentals WHERE rental_id = p_rental_id;
    RETURN result;
END; $$ LANGUAGE plpgsql;
SELECT rental_days(2); --5
SELECT rental_days(11); --8
SELECT rental_days(19); -- null
SELECT rental_days(999); --null
-- Answer: rentals 19 and 999 both return NULL, but for different reasons.
-- Rental 19 exists but has a NULL end_date; rental 999 has no matching row.

-- Exercise 2.2: A function over many rows
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE result INT;
BEGIN
    SELECT COUNT(*) INTO result FROM rentals WHERE member_id = p_member_id;
    RETURN result;
END; $$ LANGUAGE plpgsql;
SELECT member_rental_count(1); --5
SELECT member_rental_count(5); --4
SELECT member_rental_count(6); --0
SELECT member_rental_count(99); --0
-- Answer: COUNT(*) aggregates an empty input into 0, so it does not need a
-- matching member row and does not return NULL.

-- Exercise 2.3: Returning text
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE result VARCHAR;
BEGIN
    SELECT city INTO result FROM stations WHERE station_id = p_station_id;
    RETURN result;
END; $$ LANGUAGE plpgsql;
SELECT station_city(30); --Astana
SELECT station_city(77); -- null

-- Exercise 2.4: Using a function inside a query
SELECT rental_id, member_id, rental_days(rental_id) AS duration_days
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration_days DESC;
-- 11	3	8
-- 4	1	7
-- 15	5	7
-- 17	5	7
-- 20	4	6
-- 7	2	6
-- 14	4	6
-- 2	1	5

-- Exercise 3.1: IN parameters
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END; $$ LANGUAGE plpgsql;
SELECT fee_with_discount(74.00, 15); --62.90

-- Exercise 3.2: OUT parameters
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE)
AS $$
BEGIN
    SELECT COUNT(*)::INT, COALESCE(SUM(fee), 0), MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals WHERE member_id = p_member_id;
END; $$ LANGUAGE plpgsql;
SELECT member_stats(3); --5,164.75,2025-06-01
SELECT * FROM member_stats(3);
-- 5	164.75	"2025-06-01"
SELECT * FROM member_stats(6);
-- 0	0	null
-- Answer: SELECT function(...) returns one composite value, while SELECT *
-- expands OUT parameters into separate columns. SELECT * is suitable for joins.
-- Member 6 returns 0, 0, and NULL.

-- Exercise 3.3: INOUT parameters
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END; $$ LANGUAGE plpgsql;
SELECT apply_late_fee((SELECT fee FROM rentals WHERE rental_id = 1));--18.50

-- Exercise 3.4: VARIADIC parameters
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC)
AS $$
BEGIN
    SELECT COALESCE(SUM(p_fees[i]), 0), ROUND(AVG(p_fees[i]), 2), MAX(p_fees[i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END; $$ LANGUAGE plpgsql;
SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
-- 98.50 24.63 35.00
SELECT * FROM fee_summary();
--ERROR:  function fee_summary() does not exist              ^
-- HINT:  No function matches the given name and argument types. You might need to add explicit type casts. 

-- Answer:It cannot understand type of it

-- Exercise 3.5: Choosing a mode
-- Answer: (a) IN for a lookup id; (b) INOUT for an updated running balance;
-- (c) VARIADIC for an unknown-length list; (d) OUT parameters for statistics
-- returned together after one table scan.

-- Exercise 4.1: A function with one parameter
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE((SELECT SUM(fee) FROM rentals WHERE member_id = p_member_id), 0);
END; $$ LANGUAGE plpgsql;
SELECT total_fees(1); --98.50
SELECT total_fees(6); --0

-- Exercise 4.2: Overloading the name
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE((SELECT SUM(fee) FROM rentals
                     WHERE member_id = p_member_id AND start_date >= p_from_date), 0);
END; $$ LANGUAGE plpgsql;
SELECT total_fees(1, DATE '2024-01-01'); --98.50
SELECT total_fees(1, DATE '2025-01-01'); --50.00
SELECT p.oid::regprocedure
FROM pg_proc AS p
WHERE p.proname = 'total_fees'
ORDER BY p.oid::regprocedure::TEXT;
-- "total_fees(integer)"
-- "total_fees(integer,date)"

-- Exercise 4.3: Giving a parameter a default value
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01')
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE((SELECT SUM(fee) FROM rentals
                     WHERE member_id = p_member_id AND start_date >= p_from_date), 0);
END; $$ LANGUAGE plpgsql;
 SELECT total_fees(1);
--  ERROR:  function total_fees(integer) is not unique
-- HINT:  Could not choose a best candidate function. You might need to add explicit type casts. 
-- Answer: It need to call to return something but it cannot choose what to use


-- Exercise 4.4: Resolving the ambiguity
DROP FUNCTION total_fees(INTEGER);
SELECT total_fees(1); --50.00
-- Answer: the remaining two-argument version uses its default date,
-- 2025-01-01, and returns 50.00. Dropping the other version would leave the
-- one-argument function, which returns 98.50, so it would not be the same.

-- Exercise 4.5: Overloading on type, not just on count
CREATE OR REPLACE FUNCTION total_fees(p_full_name VARCHAR)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE((SELECT SUM(r.fee) FROM members AS m
                     LEFT JOIN rentals AS r ON r.member_id = m.member_id
                     WHERE m.full_name = p_full_name), 0);
END; $$ LANGUAGE plpgsql;
SELECT total_fees('Aisha Nurlanova'); --98.50
SELECT total_fees(1); --50.00
-- Answer: VARCHAR and INTEGER are distinct signatures, so argument type
-- resolves the call. The name version totals all of Aisha's rentals (98.50);
-- the integer version uses its default date and totals only 2025 rentals (50.00).

-- Exercise 5.1: Search by pattern
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE(found_id INT, found_model VARCHAR, found_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model, b.daily_rate
    FROM bikes AS b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM find_bikes('%road%');
-- 105	"Road Sprint"	9.25
-- 108	"Road Sprint"	9.25
SELECT * FROM find_bikes('%Mini');
-- 106	"Folding Mini"	3.75
SELECT find_bikes('%road%');
-- "["105","Road Sprint","9.25"]"
-- "["108","Road Sprint","9.25"]"
-- Answer: without FROM, each result row is returned as one composite value;
-- FROM expands the table-returning function into its named columns.

-- Exercise 5.2: A table from a join
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE(rental_id INT, bike_model VARCHAR, station_name VARCHAR,
              duration_days INT, rental_fee NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id, b.model, s.station_name, r.end_date - r.start_date, r.fee
    FROM rentals AS r
    JOIN bikes AS b ON b.bike_id = r.bike_id
    JOIN stations AS s ON s.station_id = b.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END; $$ LANGUAGE plpgsql;
SELECT * FROM member_history(3);
-- 8	"Mountain X"	"Expo Gate"	4	28.00
-- 9	"Road Sprint"	"Expo Gate"	3	27.75
-- 10	"Mountain X"	"Expo Gate"	1	7.00
-- 21	"Mountain X"	"Riverside"	4	28.00
-- 11	"Road Sprint"	"Expo Gate"	8	74.00

-- Exercise 5.3: When the column names collide
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(bike_id INT, model VARCHAR, daily_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model, daily_rate
    FROM bikes
    WHERE station_id = p_station_id;
END; $$ LANGUAGE plpgsql;
 -- SELECT * FROM bike_list(10);
-- ERROR:  column reference "bike_id" is ambiguous
-- It could refer to either a PL/pgSQL variable or a table column. 
-- Answer: PL/pgSQL parses the ambiguous unqualified names only when executing
-- RETURN QUERY, so CREATE succeeds but the call fails.

-- First fix: use distinct output column names.
DROP FUNCTION bike_list(INT);
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(found_id INT, found_model VARCHAR, found_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model, daily_rate FROM bikes
    WHERE station_id = p_station_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM bike_list(10);
-- 101	"City Cruiser"	4.50
-- 102	"City Cruiser"	4.50
-- 108	"Road Sprint"	9.25

-- Second fix: retain output names and qualify table columns.
DROP FUNCTION bike_list(INT);
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(bike_id INT, model VARCHAR, daily_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT b.bike_id, b.model, b.daily_rate FROM bikes AS b
    WHERE b.station_id = p_station_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM bike_list(10);
-- 101	"City Cruiser"	4.50
-- 102	"City Cruiser"	4.50
-- 108	"Road Sprint"	9.25

-- Exercise 5.4: Casting the output
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE(s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name, COUNT(b.bike_id)::INT,
           (s.capacity - COUNT(b.bike_id))::INT
    FROM stations AS s
    LEFT JOIN bikes AS b ON b.station_id = s.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM station_board('Astana');
--ERROR:  structure of query does not match function result type
-- Returned type bigint does not match expected type integer in column "s_bikes" (position 2). 
--Fixed
-- "Expo Gate"	2	3
-- "Depot"	0	0

-- Answer: COUNT returns BIGINT. Without explicit casts, PostgreSQL raises a
-- returned-type mismatch because the function declares INT output columns.

-- Exercise 6.1: An anonymous block
DO $$
<<rental_report>>
DECLARE total_rentals INT := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals FROM rentals;
    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_reports $$;
--ERROR:  end label "rental_reports" differs from block's label "rental_report"
-- LINE 7: END rental_reports $$;
--Fixed
--NOTICE:  The rentals table holds 22 rows.
-- Answer: a mismatched END label raises a syntax error because it must match
-- the opening block label.

-- Exercise 6.2: A subblock and a hidden variable
DO $$
<<outer_block>>
DECLARE fee_total NUMERIC;
BEGIN
    SELECT SUM(fee) INTO fee_total FROM rentals;
    RAISE NOTICE 'Outer before: %', fee_total;
    DECLARE fee_total NUMERIC;
    BEGIN
        SELECT SUM(fee) INTO fee_total FROM rentals WHERE start_date >= DATE '2025-01-01';
        RAISE NOTICE 'Subblock: %', fee_total;
        RAISE NOTICE 'Outer from subblock: %', outer_block.fee_total;
    END;
    RAISE NOTICE 'Outer after: %', fee_total;
END outer_block $$;
-- NOTICE:  Outer before: 621.50
-- NOTICE:  Subblock: 369.00
-- NOTICE:  Outer from subblock: 621.50
-- NOTICE:  Outer after: 621.50
-- Answer: the four values are 621.50, 369.00, 621.50, and  621.50. The inner
-- assignment does not change the outer variable; declarations are block-local.

-- Exercise 6.3: Declarations are local
DO $$
BEGIN
    DECLARE
        only_first INT := 1;
    BEGIN
        RAISE NOTICE 'First subblock: %', only_first;
    END;

    RAISE NOTICE 'Second subblock: %', only_first;
END $$;
-- ERROR:  column "only_first" does not exist
-- LINE 1: only_first

DO $$
DECLARE
        only_first INT := 1;
BEGIN
    BEGIN
        RAISE NOTICE 'First subblock: %', only_first;
    END;

    RAISE NOTICE 'Second subblock: %', only_first;
END $$;
-- NOTICE:  First subblock: 1
-- NOTICE:  Second subblock: 1
-- Answer: a subblock variable is inaccessible after its block ends. Moving the
-- declaration to the outer block makes it visible in both nested subblocks.

-- Exercise 6.4: From a block to a function
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC) AS $$
BEGIN
    SELECT COALESCE(SUM(fee) FILTER (WHERE start_date < p_from_date), 0),
           COALESCE(SUM(fee) FILTER (WHERE start_date >= p_from_date), 0)
    INTO before_total, after_total
    FROM rentals;
END; $$ LANGUAGE plpgsql;
SELECT * FROM fee_split(DATE '2025-01-01'); --252.50	369.00
SELECT before_total + after_total AS total_from_split,
       (SELECT SUM(fee) FROM rentals) AS total_from_rentals
FROM fee_split(DATE '2025-01-01'); -- 621.50	621.50

-- Exercise 7.1: Station occupancy
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC) AS $$
DECLARE station_capacity INT;
BEGIN
    SELECT s.capacity, COUNT(b.bike_id)::INT
    INTO station_capacity, bikes_parked
    FROM stations AS s LEFT JOIN bikes AS b ON b.station_id = s.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.capacity;
    capacity_pct := CASE WHEN station_capacity = 0 THEN NULL
                         ELSE ROUND(bikes_parked * 100.0 / station_capacity, 1) END;
END; $$ LANGUAGE plpgsql;
SELECT s.station_id, s.station_name, l.*
FROM stations AS s, LATERAL station_load(s.station_id) AS l;
-- 10	"Central Park"	3	75.0
-- 20	"Riverside"	2	66.7
-- 30	"Expo Gate"	2	40.0
-- 40	"Old Town"	1	50.0
-- 50	"Depot"	0	
-- Answer: station 50 returns NULL percentage because zero capacity makes
-- occupancy undefined; NULL represents this instead of inventing a percentage.

-- Exercise 7.2: Top members, with a default
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE(member_name VARCHAR, rental_count INT, total_spent NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name, COUNT(r.rental_id)::INT, COALESCE(SUM(r.fee), 0)
    FROM members AS m LEFT JOIN rentals AS r ON r.member_id = m.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY COALESCE(SUM(r.fee), 0) DESC, m.full_name
    LIMIT p_limit;
END; $$ LANGUAGE plpgsql;
SELECT * FROM top_members();
-- "Marta Kowalski"	5	164.75
-- "Chen Wei"	4	139.25
-- "Daniyar Serik"	4	138.00
SELECT * FROM top_members(6);
-- "Marta Kowalski"	5	164.75
-- "Chen Wei"	4	139.25
-- "Daniyar Serik"	4	138.00
-- "Aisha Nurlanova"	5	98.50
-- "Omar Haddad"	4	81.00
-- "Elena Petrova"	0	0
-- Answer: Aisha has more rentals than Chen but ranks below her because the
-- function ranks by total amount spent, not by the number of rentals.

-- Exercise 7.3: An invoice for an open rental
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE(member_name VARCHAR, bike_model VARCHAR, rental_days INT,
              amount_owed NUMERIC, rental_status TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name, b.model,
           (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
           ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date) * b.daily_rate, 2),
           CASE WHEN r.end_date IS NULL THEN 'OPEN' ELSE 'CLOSED' END
    FROM rentals AS r JOIN members AS m ON m.member_id = r.member_id
    JOIN bikes AS b ON b.bike_id = r.bike_id
    WHERE r.rental_id = p_rental_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM rental_invoice(11);
-- "Marta Kowalski"	"Road Sprint"	8	74.00	"CLOSED"
SELECT * FROM rental_invoice(19);
--"Aisha Nurlanova"	"City Cruiser"	411	1849.50	"OPEN"
-- Answer: rental 11 calculates 74.00, equal to its stored fee. Rental 19 uses
-- CURRENT_DATE, so it changes daily. Such a function is not IMMUTABLE.

-- Exercise 7.4: A report per city
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE(member_count INT, rental_count INT, total_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id)::INT, COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members AS m LEFT JOIN rentals AS r ON r.member_id = m.member_id
    WHERE m.city = p_city;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE(member_count INT, rental_count INT, total_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id)::INT, COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members AS m
    LEFT JOIN rentals AS r ON r.member_id = m.member_id AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END; $$ LANGUAGE plpgsql;
SELECT * FROM city_report('Almaty');
-- 3	9	236.50
SELECT * FROM city_report('Almaty', DATE '2025-01-01');
-- 3	5	135.50
-- Answer: the date condition belongs in ON to retain members with no matching
-- post-date rentals. For Almaty, ON gives 3 members; WHERE gives 2 because
-- Elena has no rentals and is removed by the WHERE condition.

-- Lab Questions
-- 1. A name is the identifier; a signature is name plus argument types.
--    PostgreSQL needs the signature to identify one overloaded function to drop.
-- 2. Dollar quotes delimit a function body without escaping internal quotes:
--    $$ BEGIN RAISE NOTICE 'It''s ready'; END; $$ is much clearer than quoted text.
-- 3. Use several OUT parameters for a fixed, small group of related values;
--    use RETURNS TABLE when returning a variable number of result rows.
-- 4. VARIADIC must be last, otherwise f(INT, VARIADIC INT[], INT) makes it
--    impossible to decide which trailing integer belongs to the array.
-- 5. RETURN NEXT appends one result row at a time; RETURN QUERY appends every
--    row produced by a query to the function's result set.
-- 6. A default lets a longer overload accept a shorter call, which can collide
--    with an existing overload. Avoid this by using distinct names or avoiding
--    overlapping default-argument signatures.
-- 7. A subblock variable ceases to exist when the subblock ends. Read a hidden
--    outer variable with its block label, for example outer_block.fee_total.
-- 8. Advantage: centralised, reusable business logic. Disadvantage: harder
--    database-specific testing/versioning and more load on the database server.
-- 9. Trusted PL/pgSQL cannot access host resources and ordinary users may use
--    it; untrusted PL/Python can access server resources and requires superuser.
-- 10. CREATE OR REPLACE cannot change argument types; PostgreSQL creates a
--     distinct overload, which may surprise callers or cause ambiguity.
