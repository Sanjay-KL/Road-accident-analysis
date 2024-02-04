CREATE DATABASE road_accidents;

-- Chicking Data in the Table /*

SELECT * FROM road_accidents;

SELECT DISTINCT junction_control
FROM road_accidents;

SELECT DISTINCT junction_detail
FROM road_accidents;

SELECT DISTINCT accident_severity
FROM road_accidents;

SELECT DISTINCT road_surface_conditions
FROM road_accidents;

SELECT DISTINCT accident_severity
FROM road_accidents;

SELECT DISTINCT road_type
FROM road_accidents;


--Q1) Find Casualities happened on different road conditions.

SELECT  road_surface_conditions, SUM(number_of_casualties) as casualities_count
FROM road_accidents
GROUP BY road_surface_conditions
ORDER BY casualities_count DESC;

--Q2) Which day of Week has more number of Accidents.
SELECT day_of_week, COUNT(DISTINCT accident_index) as casualities_count
FROM road_accidents
GROUP BY day_of_week
ORDER BY casualities_count DESC;

--Q3) Query to Find Accidents happened in Different road type.
SELECT road_surface_conditions, COUNT(DISTINCT accident_index) as accidents_no
FROM road_accidents
GROUP BY road_surface_conditions
ORDER BY accidents_no DESC;

--Q4) Query to find No_of_accidents and Casualties under different Trafic controls.

SELECT 
	CASE WHEN junction_control = 'Give way or uncontrolled' THEN 'Un_monitered'
	 WHEN junction_control = 'Not at junction or within 20 metres' THEN 'Near_Junction'
	 WHEN junction_control = 'Authorised person' THEN 'Traffic Personel'
	 WHEN junction_control = 'Data missing or out of range' THEN 'Others'
	 ELSE 'Auto signals and Stop Boards' END as control_type,
	 COUNT(DISTINCT accident_index) as accidents_no, SUM(number_of_casualties) as casualities_count
FROM road_accidents
GROUP BY CASE WHEN junction_control = 'Give way or uncontrolled' THEN 'Un_monitered'
	 WHEN junction_control = 'Not at junction or within 20 metres' THEN 'Near_Junction'
	 WHEN junction_control = 'Authorised person' THEN 'Traffic Personel'
	 WHEN junction_control = 'Data missing or out of range' THEN 'Others'
	 ELSE 'Auto signals and Stop Boards' END
ORDER BY accidents_no DESC, casualities_count;

--Q5) Query to Find different Casualities happened in the Year 2022 with different severity and with percent.

SELECT accident_severity, SUM(number_of_casualties) as fatal_casualities,
CAST(SUM(number_of_casualties)*100.0/(SELECT  SUM(number_of_casualties) FROM road_accidents 
WHERE year( accident_date)='2022')as decimal(10,2)) as accident_perc
FROM road_accidents
WHERE accident_date BETWEEN '2022-01-01' and '2022-12-31'
GROUP BY accident_severity;


--Q6) Casualties by Vehicle Types in 2022 and Order them with higher count first.


SELECT 
	CASE 
	WHEN vehicle_type in ('Agricultural vehicle') THEN 'Agricultural'
	WHEN vehicle_type in ('Car','Taxi/Private hire car') THEN 'Cars'
	WHEN vehicle_type in ('Motorcycle over 500cc','Motorcycle 125cc and under','Motorcycle 50cc and under',
	'Motorcycle over 125cc and up to 500cc','Pedal cycle') THEN 'Bike'
	WHEN vehicle_type in ('Bus or coach (17 or more pass seats)','Minibus (8 - 16 passenger seats)') THEN 'Bus'
	WHEN vehicle_type in ('Van / Goods 3.5 tonnes mgw or under','Goods over 3.5t. and under 7.5t','Goods 7.5 tonnes mgw and over') THEN 'Van'
	ELSE 'Other' END as Vehicle_grp,
	SUM(number_of_casualties) as casualtiesby_vehicle_type
FROM road_accidents
WHERE year(accident_date) = '2022'
GROUP BY
	CASE
	WHEN vehicle_type in ('Agricultural vehicle') THEN 'Agricultural'
	WHEN vehicle_type in ('Car','Taxi/Private hire car') THEN 'Cars'
	WHEN vehicle_type in ('Motorcycle over 500cc','Motorcycle 125cc and under','Motorcycle 50cc and under',
	'Motorcycle over 125cc and up to 500cc','Pedal cycle') THEN 'Bike'
	WHEN vehicle_type in ('Bus or coach (17 or more pass seats)','Minibus (8 - 16 passenger seats)') THEN 'Bus'
	WHEN vehicle_type in ('Van / Goods 3.5 tonnes mgw or under','Goods over 3.5t. and under 7.5t','Goods 7.5 tonnes mgw and over') THEN 'Van'
	ELSE 'Other' END
ORDER BY casualtiesby_vehicle_type DESC;


--Q7) Query to Find Monthly Casualties trend Monthly on YOY Basis.
WITH casualty_2022 as(
SELECT DATENAME(MONTH, accident_date) as months, SUM(number_of_casualties) as monthly_casualties
FROM road_accidents
WHERE YEAR(accident_date) = '2022'
GROUP BY DATENAME(MONTH, accident_date))

, casualty_2021 as(
SELECT DATENAME(MONTH, accident_date) as months, DATEPART(MONTH, accident_date) as months_num,SUM(number_of_casualties) as monthly_casualties
FROM road_accidents
WHERE YEAR(accident_date) = '2021'
GROUP BY DATENAME(MONTH, accident_date),DATEPART(MONTH, accident_date))

SELECT c21.months, c21.monthly_casualties as monthly_casualties_2021
, c22.monthly_casualties as monthly_casualties_2022, c21.monthly_casualties-c22.monthly_casualties AS yoy_changes
FROM casualty_2021 c21
JOIN casualty_2022 c22 on c21.months = c22.months
ORDER BY c21.months_num;

--Q8) Query to Find Casualties by Road Type and their Percentage.
SELECT road_type, SUM(number_of_casualties) as casualties, 
CAST(SUM(number_of_casualties)*100.0/
	(SELECT  SUM(number_of_casualties) FROM road_accidents)as decimal(10,2)) as casualty_perc
FROM road_accidents
GROUP BY road_type
ORDER BY casualties DESC;

--Q9) Query to Find Casualty by areas.
SELECT urban_or_rural_area, SUM(number_of_casualties) as casualties, 
CAST(SUM(number_of_casualties)*100.0/
	(SELECT  SUM(number_of_casualties) FROM road_accidents)as decimal(10,2)) as casualty_perc
FROM road_accidents
GROUP BY urban_or_rural_area
ORDER BY casualties DESC;

--Q10) Query to Find TOP 5 Casualty by Light Condition and junction_detail.
SELECT Top 5
	CASE
		WHEN light_conditions = 'Daylight' THEN 'Day'
		ELSE  'Night' END as light_condition,
SUM(number_of_casualties) as casualties, 
CAST(SUM(number_of_casualties)*100.0/(SELECT  SUM(number_of_casualties) FROM road_accidents)as decimal(10,2)) as casualty_perc,
junction_detail
FROM road_accidents
GROUP BY CASE
		WHEN light_conditions = 'Daylight' THEN 'Day'
		ELSE  'Night' END, junction_detail
ORDER BY casualties DESC;

--Q11) Query to Find Top 10 Location by No of Casualties.

SELECT TOP 10 local_authority as location, SUM(number_of_casualties) as Total_casualties
FROM road_accidents
GROUP BY local_authority
ORDER BY Total_casualties DESC;
