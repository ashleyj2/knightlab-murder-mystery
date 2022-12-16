/*
SQL Murder Mystery
https://mystery.knightlab.com/
Queries I used to solve the murder mystery
12/15/2022
Ashley Joyner
*/

--Get the names of the tables in this database. This command is specific to SQLite.
SELECT name 
FROM sqlite_master
WHERE type = 'table'

--Find the structure of the `crime_scene_report` table. Change the value of 'name' to see the 
--structure of the other tables
SELECT sql 
FROM sqlite_master
WHERE name = 'crime_scene_report'

--Reading ALL interview transcripts
SELECT p.id, p.name, i.transcript
FROM person AS p
JOIN interview AS i
ON i.person_id = p.id;
--too many to read, not enough info to start with
-- killer?? id: 67318	name: Jeremy Bowers

--SQL city murder crime scene report           
SELECT *
FROM crime_scene_report
WHERE city LIKE '%SQL%' AND type = 'murder'
ORDER BY date;      
--2018-01-15 report 1: Security footage shows that there were 2 witnesses. The first witness lives 
    --at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on 
    --"Franklin Ave".
--2018-02-15 report 2: REDACTED REDACTED REDACTED
--2018-02-15 report 3: Someone killed the guard! He took an arrow to the knee!

--finding first witness
SELECT *
FROM person
WHERE address_street_name LIKE '%Northwestern Dr%'
ORDER BY address_number DESC
LIMIT 1;
--id: 14887	
--name: Morty Schapiro	
--license id: 118009	
--address number: 4919	
--street name: Northwestern Dr	
--SSN: 111564949

--Morty Schapiro interview transcript
SELECT *
FROM interview
WHERE person_id = 14887;
--I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership 
--number on the bag started with "48Z". Only GOLD members have those bags. The man got into a car 
--with a plate that included "H42W".

--finding second witness
SELECT *
FROM person
WHERE name LIKE '%Annabel%' 
    AND address_street_name LIKE '%Franklin Ave%';
--id: 16371
--name:	Annabel Miller
--license id: 490173
--address number: 103
--street name: Franklin Ave
--SSN: 318771143
					
--Annabel Miller interview transcript
SELECT *
FROM interview
WHERE person_id = 16371;
--I saw the murder happen, and I recognized the killer from my gym when I was working out last week 
--on January the 9th.

--Using witness transcripts to find killer
SELECT  p.name, m.id, d.plate_number, c.check_in_date AS date, m.membership_status AS status
FROM get_fit_now_check_in AS c
JOIN get_fit_now_member AS m
ON c.membership_id = m.id
JOIN person AS p
ON m.person_id = p.id
JOIN drivers_license AS d
ON p.license_id = d.id
WHERE m.id LIKE '48Z%' AND d.plate_number LIKE '%H42W%' AND date = 20180109 AND status = 'gold';
--name: Jeremy Bowers
--gym membership id: 48Z55	
--license plate number: 0H42W2	
--at the gym on: 20180109	
--membership type: gold

--Get info on killer using name
SELECT *
FROM person
WHERE name = 'Jeremy Bowers';
--id: 67318	
--name: Jeremy Bowers	
--license id: 423327	
--address number: 530	
--street name: Washington Pl, Apt 3A	
--SSN: 871539279

--get killers interview transcript
SELECT *
FROM interview
WHERE person_id = 67318;
--I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" 
--(65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended 
--the SQL Symphony Concert 3 times in December 2017.

--Use hired gun's description to find who hired him
SELECT p.id,
    p.name, 
    i.annual_income, 
    d.height, 
    d.hair_color, 
    d.gender, 
    d.car_make, 
    d.car_model, 
	(SELECT COUNT(*)
	 FROM facebook_event_checkin AS f
	 WHERE p.id = f.person_id 
        AND date LIKE '201712%' 
        AND event_name LIKE '%SQL Symphony Concert%'
	) AS event_num
FROM drivers_license AS d
JOIN person AS p
ON d.id = p.license_id
LEFT JOIN income AS i
ON p.ssn = i.ssn
WHERE (d.height BETWEEN 65 AND 67) 
    AND d.hair_color = 'red' 
    AND d.gender = 'female'
	AND d.car_make = 'Tesla' 
    AND d.car_model = 'Model S' 
    AND event_num = 3
ORDER BY i.annual_income DESC;
--id: 99716	
--name: Miranda Priestly	
--annual income: $310,000	
--height: 66	
--hair color: red	
--gender: female	
--car make: Tesla	
--car model: Model S	
--event_num: 3

--get masterminds interview transcript
SELECT *
FROM interview
WHERE person_id = 99716;
--no results

--Other Miranda Priestly info
SELECT *
FROM person
WHERE id = 99716;
--license id: 202298	
--address: 1883	Golden Ave	
--ssn: 987756388
SELECT *
FROM drivers_license
WHERE id = 202298;
--age: 68
SELECT *
FROM get_fit_now_member
WHERE person_id = 99716;
--not a gym member

--checking my solution
INSERT INTO solution VALUES (1, 'Miranda Priestly');
        SELECT value FROM solution;