/* Calcul des indicateurs */

-- 1. Nombre total de réservations
SELECT COUNT([Trip ID]) AS "Total Bookings" FROM UberDB.dbo.TripDetails;
-- Total Bookings : 103 728

-- 2. Coût total des réservations
SELECT (SUM(fare_amount) + SUM([Surge Fee])) AS "Total Booking Value" FROM UberDB.dbo.TripDetails;
-- Total Booking Value : 1 553 672.81 $

-- 3. Coût moyen d'une réservation 
SELECT ROUND((SUM(fare_amount) + SUM([Surge Fee])) / COUNT([Trip ID]),2) AS "Average Booking Value"
FROM UberDB.dbo.TripDetails;
-- Average Booking Value : 14.98 $

-- 4. Distance totale de course
SELECT SUM(trip_distance) AS "Total Trip Distance" FROM UberDB.dbo.TripDetails;
-- Total Trip Distance : 348 933.81 miles

-- 5. Distance moyenne de course
SELECT AVG(trip_distance) AS "Average Trip Distance" FROM UberDB.dbo.TripDetails;
-- Average Trip Distance : 3.36 miles

-- 6. Temps moyen de course
WITH duree_course AS (
	SELECT 
		[Trip ID],
		DATEDIFF(MINUTE, [Pickup Time], [Drop Off Time]) AS trip_duration
	FROM UberDB.dbo.TripDetails
)
SELECT AVG(trip_duration) AS "Average Trip Time"
FROM duree_course;
-- Average Trip Time : 15 minutes

/* Regroupements */

-- 1. Nombre total de réservations par type de paiement
SELECT 
	Payment_type, 
	COUNT([Trip ID]) AS "Total Bookings"
FROM UberDB.dbo.TripDetails
GROUP BY Payment_type
ORDER BY COUNT([Trip ID]) DESC;
-- Uber Pay	  : 69 530
-- Cash		  : 33 434
-- Amazon Pay : 584
-- Google Pay : 180

-- 2. Coût total des réservations par type de paiement
SELECT 
	Payment_type, 
	(SUM(fare_amount) + SUM([Surge Fee])) AS "Total Booking Value"
FROM UberDB.dbo.TripDetails
GROUP BY Payment_type
ORDER BY (SUM(fare_amount) + SUM([Surge Fee])) DESC;
-- Uber Pay	  : 1 099 036.51 $
-- Cash		  : 443 360.8 $
-- Amazon Pay : 8 556 $
-- Google Pay : 2 719.5 $

-- 3. Distance totale de course par type de paiement
SELECT 
	Payment_type, 
	SUM(trip_distance) AS "Total Trip Distance"
FROM UberDB.dbo.TripDetails
GROUP BY Payment_type
ORDER BY SUM(trip_distance) DESC;
-- Uber Pay	  : 231 217.24 
-- Cash		  : 114 560.37 
-- Amazon Pay : 2 412.7
-- Google Pay : 743.5 

-- 4. Nombre total de réservations par type de voyage (jour/nuit)
WITH trip_hour AS (
	SELECT 
		[Trip ID],
		DATEPART(HOUR,[Pickup Time]) AS heure
	FROM UberDB.dbo.TripDetails
),
trip_type AS (
	SELECT 
		[Trip ID],
		CASE 
			WHEN heure >= 17 OR heure < 6 THEN 'Night'
			ELSE 'Day'
		END AS day_night
	FROM trip_hour
)
SELECT 
	day_night AS "Trip Type",
	COUNT([Trip ID]) AS "Total Bookings"
FROM trip_type
GROUP BY day_night; 
-- Day   : 67 716
-- Night : 36 012

-- 5. Coût total des réservations par type de voyage
WITH trip_hour AS (
	SELECT 
		[Trip ID],
		DATEPART(HOUR,[Pickup Time]) AS heure,
		fare_amount,
		[Surge Fee]
	FROM UberDB.dbo.TripDetails
),
trip_type AS (
	SELECT 
		[Trip ID],
		CASE 
			WHEN heure >= 17 OR heure < 6 THEN 'Night'
			ELSE 'Day'
		END AS day_night,
		fare_amount,
		[Surge Fee]
	FROM trip_hour
)
SELECT 
	day_night AS "Trip Type",
	(SUM(fare_amount) + SUM([Surge Fee])) AS "Total Booking Value"
FROM trip_type
GROUP BY day_night; 
-- Day   : 974 939.66 $
-- Night : 578 733.15 $

-- 6. Distance totale de course par type de voyage
WITH trip_hour AS (
	SELECT 
		[Trip ID],
		DATEPART(HOUR,[Pickup Time]) AS heure,
		trip_distance
	FROM UberDB.dbo.TripDetails
),
trip_type AS (
	SELECT 
		[Trip ID],
		CASE 
			WHEN heure >= 17 OR heure < 6 THEN 'Night'
			ELSE 'Day'
		END AS day_night,
		trip_distance
	FROM trip_hour
)
SELECT 
	day_night AS "Trip Type",
	SUM(trip_distance) AS "Total Trip Distance"
FROM trip_type
GROUP BY day_night; 
-- Day   : 210 705.23
-- Night : 138 228.58

/* Analyse du type de véhicule */

SELECT 
	Vehicle,
	COUNT([Trip ID]) AS "Total Bookings",
	(SUM(fare_amount) + SUM([Surge Fee])) AS "Total Booking Value",
	ROUND((SUM(fare_amount) + SUM([Surge Fee])) / COUNT([Trip ID]),2) AS "Average Booking Value",
	SUM(trip_distance) AS "Total Trip Distance"
FROM UberDB.dbo.TripDetails
GROUP BY Vehicle
ORDER BY (SUM(fare_amount) + SUM([Surge Fee])) DESC;
-- UberX        : 38 744 | 583 879.64 $ | 15.07 $ | 131 496.06
-- Uber Comfort : 17 078 | 253 995.49 $ | 14.87 $ | 56 790.29
-- Uber Black   : 16 710 | 250 192.46 $ | 14.97 $ | 56 149.26
-- UberXL       : 16 698 | 249 424.43 $ | 14.94 $ | 55 720.68
-- Uber Green   : 14 498 | 216 180.79 $ | 14.91 $ | 48 777.52

/* Nombre total de réservations par jour */

SELECT 
	DATEPART(DAY,[Pickup Time]) AS jour,
	COUNT([Trip ID]) AS "Total Bookings"
FROM UberDB.dbo.TripDetails
GROUP BY DATEPART(DAY,[Pickup Time])
ORDER BY DATEPART(DAY,[Pickup Time]);

/* Analyse de la localisation */

-- 1. Point de prise en charge le plus fréquent
WITH trip_number_by_location AS (
	SELECT 
		PULocationID,
		COUNT([Trip ID]) AS "Number of Trips"
	FROM UberDB.dbo.TripDetails
	GROUP BY PULocationID
),
max_trip_number_LocationID AS (
	SELECT 
		PULocationID
	FROM trip_number_by_location 
	WHERE [Number of Trips] = (SELECT MAX([Number of Trips]) FROM trip_number_by_location)
)
SELECT loc.Location AS "Most Frequent Pickup Point"
FROM  max_trip_number_LocationID AS mtnl
	JOIN UberDB.dbo.Location AS loc 
		ON mtnl.PULocationID = loc.LocationID;
-- Most Frequent Pickup Point : Penn Station/Madison Sq West

-- 2. Point de dépôt le plus fréquent
WITH trip_number_by_location AS (
	SELECT 
		DOLocationID,
		COUNT([Trip ID]) AS "Number of Trips"
	FROM UberDB.dbo.TripDetails
	GROUP BY DOLocationID
),
max_trip_number_LocationID AS (
	SELECT 
		DOLocationID
	FROM trip_number_by_location 
	WHERE [Number of Trips] = (SELECT MAX([Number of Trips]) FROM trip_number_by_location)
)
SELECT loc.Location AS "Most Frequent Dropoff Point"
FROM  max_trip_number_LocationID AS mtnl
	JOIN UberDB.dbo.Location AS loc 
		ON mtnl.DOLocationID = loc.LocationID;
-- Most Frequent Dropoff Point : Upper East Side North

-- 3. Trajet le plus long
WITH max_distance_ID AS (
	SELECT 
		PULocationID,
		DOLocationID,
		trip_distance
	FROM UberDB.dbo.TripDetails
	WHERE trip_distance = (SELECT MAX(trip_distance) FROM UberDB.dbo.TripDetails)
),
pickup_location AS (
	SELECT 
		loc.Location AS pickup_location,
		trip_distance
	FROM max_distance_ID AS mdi 
		JOIN UberDB.dbo.Location AS loc 
			ON mdi.PULocationID = loc.LocationID
),
dropoff_location AS (
	SELECT loc.Location AS dropoff_location
	FROM max_distance_ID AS mdi 
		JOIN UberDB.dbo.Location AS loc 
			ON mdi.DOLocationID = loc.LocationID
)
SELECT CONCAT(pickup_location, ' -> ', dropoff_location, '(', trip_distance, ' miles)') AS "Farthest Trip"
FROM pickup_location 
	FULL JOIN dropoff_location
		ON 1 = 1;
-- Farthest Trip : Lower East Side -> Crown Heights North (144.1 miles)

-- 4. TOP 5 des réservations par emplacement 
WITH total_bookings_by_locationID AS (
	SELECT 
		PULocationID,
		COUNT([Trip ID]) AS "Total Bookings"
	FROM UberDB.dbo.TripDetails
	GROUP BY PULocationID
),
total_bookings_by_location AS (
	SELECT 
		l.Location,
		tbbl.[Total Bookings]
	FROM total_bookings_by_locationID AS tbbl 
		JOIN UberDB.dbo.Location AS l
			ON tbbl.PULocationID = l.LocationID
)
SELECT TOP 5 *
FROM total_bookings_by_location
ORDER BY [Total Bookings] DESC;
-- Penn Station/Madison Sq West : 4 475
-- Upper East Side North        : 4 459
-- Upper East Side South		: 4 124
-- Lenox Hill East				: 3 955
-- Upper West Side North		: 3 752

-- 5. Véhicule préféré pour la prise en charge
WITH pickup_preferred_vehicle AS (
	SELECT 
		Vehicle,
		COUNT(PULocationID) AS "Total Bookings"
	FROM UberDB.dbo.TripDetails
	GROUP BY Vehicle 
)
SELECT TOP 5 *
FROM pickup_preferred_vehicle
ORDER BY [Total Bookings] DESC;
-- UberX		: 38 744
-- Uber Comfort : 17 078
-- Uber Black   : 16 710
-- UberXL		: 16 698
-- Uber Green   : 14 498

/* Analyse du temps */

-- 1. Nombre total de réservations par jour de la semaine
SELECT 
	DATEPART(WEEKDAY, [Pickup Time]) AS num_jour,
	FORMAT([Pickup Time], 'ddd') AS jour,
	COUNT([Trip ID]) AS "Total Bookings"
FROM UberDB.dbo.TripDetails
GROUP BY DATEPART(WEEKDAY, [Pickup Time]), FORMAT([Pickup Time], 'ddd')
ORDER BY DATEPART(WEEKDAY, [Pickup Time]);
-- 1 | lun. | 14 653
-- 2 | mar. | 15 098
-- 3 | mer. | 15 718
-- 4 | jeu. | 11 171
-- 5 | ven. | 9 260
-- 6 | sam. | 18 663
-- 7 | dim. | 19 165

-- 2. Coût total des réservations par jour de la semaine
SELECT 
	DATEPART(WEEKDAY, [Pickup Time]) AS num_jour,
	FORMAT([Pickup Time], 'ddd') AS jour,
	SUM(fare_amount) + SUM([Surge Fee]) AS "Total Booking Value"
FROM UberDB.dbo.TripDetails
GROUP BY DATEPART(WEEKDAY, [Pickup Time]), FORMAT([Pickup Time], 'ddd')
ORDER BY DATEPART(WEEKDAY, [Pickup Time]);
-- 1 | lun. | 212 843.49 $
-- 2 | mar. | 224 344.81 $
-- 3 | mer. | 238 565.38 $
-- 4 | jeu. | 172 651.75 $
-- 5 | ven. | 146 366.83 $
-- 6 | sam. | 276 207.42 $
-- 7 | dim. | 282 693.13 $

-- 3. Distance totale des courses par jour de la semaine
SELECT 
	DATEPART(WEEKDAY, [Pickup Time]) AS num_jour,
	FORMAT([Pickup Time], 'ddd') AS jour,
	SUM(trip_distance) AS "Total Trip Distance"
FROM UberDB.dbo.TripDetails
GROUP BY DATEPART(WEEKDAY, [Pickup Time]), FORMAT([Pickup Time], 'ddd')
ORDER BY DATEPART(WEEKDAY, [Pickup Time]);
-- 1 | lun. | 46 507.90
-- 2 | mar. | 49 487.95
-- 3 | mer. | 52 564.64
-- 4 | jeu. | 40 868.37
-- 5 | ven. | 35 601.55
-- 6 | sam. | 61 978.60
-- 7 | dim. | 61 924.80

-- 4. Nombre total de réservations par heure et par jour
SELECT 
	DATEPART(HOUR, [Pickup Time]) AS heure,
	DATEPART(WEEKDAY, [Pickup Time]) AS num_jour,
	FORMAT([Pickup Time], 'ddd') AS jour,
	COUNT([Trip ID]) AS "Total Bookings"
FROM UberDB.dbo.TripDetails
GROUP BY DATEPART(HOUR, [Pickup Time]), DATEPART(WEEKDAY, [Pickup Time]), FORMAT([Pickup Time], 'ddd')
ORDER BY DATEPART(HOUR, [Pickup Time]), DATEPART(WEEKDAY, [Pickup Time]);

-- 5. Coût total des réservations par heure et par jour
SELECT 
	DATEPART(HOUR, [Pickup Time]) AS heure,
	DATEPART(WEEKDAY, [Pickup Time]) AS num_jour,
	FORMAT([Pickup Time], 'ddd') AS jour,
	SUM(fare_amount) + SUM([Surge Fee]) AS "Total Booking Value"
FROM UberDB.dbo.TripDetails
GROUP BY DATEPART(HOUR, [Pickup Time]), DATEPART(WEEKDAY, [Pickup Time]), FORMAT([Pickup Time], 'ddd')
ORDER BY DATEPART(HOUR, [Pickup Time]), DATEPART(WEEKDAY, [Pickup Time]);

-- 6. Distance totale des courses par heure et par jour
SELECT 
	DATEPART(HOUR, [Pickup Time]) AS heure,
	DATEPART(WEEKDAY, [Pickup Time]) AS num_jour,
	FORMAT([Pickup Time], 'ddd') AS jour,
	SUM(trip_distance) AS "Total Trip Distance"
FROM UberDB.dbo.TripDetails
GROUP BY DATEPART(HOUR, [Pickup Time]), DATEPART(WEEKDAY, [Pickup Time]), FORMAT([Pickup Time], 'ddd')
ORDER BY DATEPART(HOUR, [Pickup Time]), DATEPART(WEEKDAY, [Pickup Time]);