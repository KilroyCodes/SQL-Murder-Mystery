-- Find: A murder that occurred sometime on Jan 15, 2018 in SQL City

SELECT *
FROM main.crime_scene_report as csr
WHERE
    csr.date = 20180115 AND -- Jan 15, 2018
    csr.type = 'murder' AND
    city = 'SQL City';

/* One match with description as follows:
   Security footage shows that there were 2 witnesses.
   The first witness lives at the last house on "Northwestern Dr".
   The second witness, named Annabel, lives somewhere on "Franklin Ave".
 */

-- Find matching persons from 'person' table
-- First witness: last house on "Northwestern Dr"
SELECT *, max(address_number)
FROM main.person as p
WHERE
    p.address_street_name = 'Northwestern Dr';

-- Second witness: named Annabel, lives somewhere on "Franklin Ave"
SELECT *
FROM main.person as p
WHERE
    p.address_street_name = 'Franklin Ave' AND
    p.name LIKE 'Annabel%';

-- First witness: Morty Schapiro (id: 14887)
-- Second witness: Annabel Miller (id: 16371)

SELECT *
FROM main.interview as i
WHERE
    i.person_id IN (14887, 16371);

/* Killer:
   Goes to same Get Fit Now Gym, same as Annabel. Was there Jan 9
   Has Gold gym membership starting in '48Z'
   Gunshot
   Car with plate starting in 'H42W'
 */

SELECT *
 FROM main.drivers_license as dl
 WHERE
     dl.plate_number LIKE 'H42W%';
-- One match: blonde female, 21yo, Toyota Prius

SELECT *
FROM main.get_fit_now_member as gfnm
LEFT JOIN main.get_fit_now_check_in as gfnci
    ON gfnm.id = gfnci.membership_id
WHERE
    gfnci.check_in_date = 20180109 AND
    gfnci.membership_id LIKE '48Z%' AND
    gfnm.membership_status = 'gold';
/* Two hits:
   Joe Germuska (person_id: 28819)
   and Jeremy Bowers (person_id: 67318)
 */

-- Run person ID against interviews
SELECT *
FROM main.interview
WHERE
    person_id IN (28819, 67318)
 LIMIT 5;

/* One hit (Jeremy Bowers, 67318):
   I was hired by a woman with a lot of money.
   I know she's around 5'5" (65") or 5'7" (67")
   She has red hair and she drives a Tesla Model S.
   I know that she attended the SQL Symphony Concert 3 times in December 2017.
 */

-- Checking our solution:
INSERT INTO solution VALUES (1, 'Jeremy Bowers')
SELECT value FROM solution;

 -- We've found our killer! but let's find the mastermind

SELECT
    fec.person_id,
    COUNT(date) as attendance_count
FROM main.facebook_event_checkin as fec
WHERE
    fec.date LIKE '201712%' AND
    fec.event_name LIKE '%SQL Symphony%'
GROUP BY fec.person_id
HAVING attendance_count = 3;
-- Two hits for person_id: 24556 and 99716

SELECT *
FROM main.person as p
WHERE id IN (24556, 99716);
-- One female: Miranda Priestley (99716)

WITH suspect AS
(
SELECT
    name,
    id,
    license_id,
    ssn
FROM main.person
WHERE id = 99716);

SELECT
    suspect.id,
    suspect.name,
    dl.height,
    dl.gender,
    dl.hair_color,
    dl.car_make,
    dl.car_model,
    income.annual_income
FROM suspect

LEFT JOIN main.drivers_license AS dl
ON dl.id = suspect.license_id

LEFT JOIN main.income
ON income.ssn = suspect.ssn;
-- All the descriptions match. Our mastermind is definitely Miranda Priestley!

