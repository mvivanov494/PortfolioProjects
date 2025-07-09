USE datacleaningportfolioproject;

SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';

DROP TABLE IF EXISTS nashville_housing_data;
CREATE TABLE nashville_housing_data(
unique_id INT NULL,
parcel_id TEXT NULL,
land_use TEXT NULL,
property_address TEXT NULL,
sale_date DATE NULL,
sale_price INT NULL,
legal_reference TEXT NULL,
sold_as_vacant TEXT NULL,
owner_name TEXT NULL,
owner_address TEXT NULL,
acreage DOUBLE NULL,
tax_distinct TEXT NULL,
land_value INT NULL,
building_value INT NULL,
total_value INT NULL,
year_built INT NULL,
bedrooms INT NULL,
full_baths INT NULL,
half_baths INT NULL
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\datacleaningportfolioproject\\NHD.csv' INTO TABLE nashville_housing_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
@unique_id, @parcel_id, @land_use, @property_address,
@sale_date, @sale_price, @legal_reference, @sold_as_vacant,
@owner_name, @owner_address, @acreage, @tax_distinct,
@land_value, @building_value, @total_value, @year_built,
@bedrooms, @full_baths, @half_baths
)
SET
  unique_id        = NULLIF(@unique_id, ''),
  parcel_id        = NULLIF(@parcel_id, ''),
  land_use         = NULLIF(@land_use, ''),
  property_address = NULLIF(@property_address, ''),
  sale_date        = NULLIF(@sale_date, ''),
  sale_price       = NULLIF(@sale_price, '0'),
  legal_reference  = NULLIF(@legal_reference, ''),
  sold_as_vacant   = NULLIF(@sold_as_vacant, ''),
  owner_name       = NULLIF(@owner_name, ''),
  owner_address    = NULLIF(@owner_address, ''),
  acreage          = NULLIF(@acreage, '0'),
  tax_distinct     = NULLIF(@tax_distinct, ''),
  land_value       = NULLIF(@land_value, '0'),
  building_value   = NULLIF(@building_value, '0'),
  total_value      = NULLIF(@total_value, '0'),
  year_built       = NULLIF(@year_built, '0'),
  bedrooms         = NULLIF(@bedrooms, '0'),
  full_baths       = NULLIF(@full_baths, '0'),
  half_baths       = NULLIF(@half_baths, '0');

SELECT * FROM nashville_housing_data;

-- Cleaning data in sql queries

-- Standardizing date formats
/*
ALTER TABLE nashville_housing_data
ADD sale_date_converted DATE;

UPDATE nashville_housing_data
SET sale_date_converted = CONVERT(DATE, sale_date);

ALTER TABLE nashville_housing_data
DROP COLUMN sale_data;
*/

-- Populate property address data
SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, IFNULL(a.property_address, b.property_address)
FROM nashville_housing_data a
JOIN nashville_housing_data b
	ON a.parcel_id = b.parcel_id
    AND a.unique_id <> b.unique_id
WHERE a.property_address IS NULL;

SET SQL_SAFE_UPDATES = 0;
-- IFNULL(A,B) means if A is null then replace it with B
UPDATE nashville_housing_data a 
JOIN nashville_housing_data b
	ON a.parcel_id = b.parcel_id
    AND a.unique_id <> b.unique_id
SET a.property_address = IFNULL(a.property_address, b.property_address)
WHERE a.property_address IS NULL
AND b.property_address IS NOT NULL;

-- Breaking out address into individual columns (address, city, state)
/* 
INSTR(str, substr) returns the starting position of a substring in a string
SUBSTRING(str, index A, index B) cuts out substring from the given string from index A to B
REVERSE() flips the string
LOCATE() returns the index of the first delimiter in this case ' '
LENGTH() returns the index of the final character

SUBSTRING_INDEX() extracts a portion of a string based on a delimiter (not a character position)
SUBSTRING_INDEX(str, delimiter, count) 
if count > 0 returns everything up to the count-th occurrence of the delimiter from the LEFT
if count < 0 returns everything after the count-th occurrence of the delimiter from the RIGHT 
TRIM() removes leading/trailing spaces
space will be our delimiter ' '
-1 means everything after the first ' ' from the RIGHT
*/

SELECT
TRIM(SUBSTRING(property_address, 1, LENGTH(property_address) - LOCATE(' ', REVERSE(property_address)))) AS address_trimmed,
TRIM(SUBSTRING_INDEX(property_address, ' ', -1)) AS city
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD address_trimmed TEXT;

UPDATE nashville_housing_data
SET address_trimmed = TRIM(SUBSTRING(property_address, 1, LENGTH(property_address) - LOCATE(' ', REVERSE(property_address)))) ;

ALTER TABLE nashville_housing_data
ADD city TEXT;

UPDATE nashville_housing_data
SET city = TRIM(SUBSTRING_INDEX(property_address, ' ', -1));

-- The LEFT(string, index) function in SQL returns a specified number of characters from the beginning (left side) of a string.
SELECT
TRIM(SUBSTRING_INDEX(owner_address, ' ', -1)) AS owner_state,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ' ', -2), ' ', 1)) AS owner_city,
TRIM(LEFT(owner_address, LENGTH(owner_address) - LENGTH(SUBSTRING_INDEX(owner_address, ' ', -2)))) AS owner_street
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD owner_address_trimmed TEXT;

UPDATE nashville_housing_data
SET owner_address_trimmed = TRIM(LEFT(owner_address, LENGTH(owner_address) - LENGTH(SUBSTRING_INDEX(owner_address, ' ', -2))));

ALTER TABLE nashville_housing_data
ADD owner_city TEXT;

UPDATE nashville_housing_data
SET owner_city = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ' ', -2), ' ', 1));

ALTER TABLE nashville_housing_data
ADD owner_state TEXT;

UPDATE nashville_housing_data
SET owner_state = TRIM(SUBSTRING_INDEX(owner_address, ' ', -1));

-- Change Y and N to Yes and No in "Sold as Vacant' field
SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant)
FROM nashville_housing_data
GROUP BY sold_as_vacant
ORDER BY 2;

SELECT sold_as_vacant,
	CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		 WHEN sold_as_vacant = 'N' THEN 'No'
		 ELSE sold_as_vacant
		 END
FROM nashville_housing_data;

UPDATE nashville_housing_data
SET sold_as_vacant = 	CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		 WHEN sold_as_vacant = 'N' THEN 'No'
		 ELSE sold_as_vacant
		 END;

-- Removing duplicates with a CTE
WITH RowNumCTE AS(
SELECT unique_id, 
	ROW_NUMBER() OVER (
    PARTITION BY parcel_id,
				 property_address,
                 sale_price,
                 sale_date,
                 legal_reference
                 ORDER BY
					unique_id
                    ) row_num
FROM nashville_housing_data
)

DELETE FROM nashville_housing_data
WHERE unique_id IN (SELECT unique_id FROM RowNumCTE WHERE row_num > 1);

-- Delete unused columns

SELECT *
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
DROP COLUMN owner_address;

ALTER TABLE nashville_housing_data
DROP COLUMN property_address;

ALTER TABLE nashville_housing_data
DROP COLUMN tax_distinct;

-- Pie charts

-- Looking at the percentage of houses built in each year in Nashville
-- COUNT(*) counts all rows that match either the WHERE condition or, if GROUP BY is used, all rows within each group.
-- The subquery COUNT(*) is not affected by the group by statement
SELECT year_built, COUNT(*) as count, 
COUNT(*)/(SELECT COUNT(*) FROM nashville_housing_data WHERE year_built IS NOT NULL) *100 AS percentage
FROM nashville_housing_data
WHERE year_built IS NOT NULL
GROUP BY year_built
ORDER BY percentage DESC;

-- Bar charts

-- Looking at the amount of homes with X amount of bedrooms
SELECT DISTINCT(bedrooms), COUNT(bedrooms) AS count
FROM nashville_housing_data 
WHERE bedrooms IS NOT NULL
GROUP BY bedrooms
ORDER BY bedrooms;

-- Looking at the amount of homes with X amount of full bathrooms
SELECT DISTINCT(full_baths), COUNT(full_baths) AS count
FROM nashville_housing_data
WHERE full_baths IS NOT NULL
GROUP BY full_baths
ORDER BY full_baths;

-- Looking at the number of land plots in X price bracket
SELECT
	CASE
		WHEN land_value < 100000 THEN 'Under 100k'
        WHEN land_value BETWEEN 100000 AND 200000 THEN '100k-200k'
        WHEN land_value BETWEEN 200000 AND 300000 THEN '200k-300k'
        WHEN land_value BETWEEN 300000 AND 400000 THEN '300k-400k'
        WHEN land_value BETWEEN 400000 AND 500000 THEN '400k-500k'
        WHEN land_value BETWEEN 500000 AND 600000 THEN '500k-600k'
        WHEN land_value BETWEEN 600000 AND 700000 THEN '600k-700k'
        WHEN land_value BETWEEN 700000 AND 800000 THEN '700k-800k'
        WHEN land_value BETWEEN 800000 AND 900000 THEN '800k-900k'
        WHEN land_value BETWEEN 1000000 AND 2000000 THEN '1M-2M'
        WHEN land_value BETWEEN 2000000 AND 3000000 THEN '2M-3M'
        WHEN land_value > 3000000 THEN 'Over 3M'
        ELSE 'Missing Land Value'
	END AS land_value_range,  Count(*) AS count,
	CASE
        WHEN land_value < 100000 THEN 1
		WHEN land_value BETWEEN 100000 AND 200000 THEN 2
		WHEN land_value BETWEEN 200000 AND 300000 THEN 3
		WHEN land_value BETWEEN 300000 AND 400000 THEN 4
		WHEN land_value BETWEEN 400000 AND 500000 THEN 5
		WHEN land_value BETWEEN 500000 AND 600000 THEN 6
		WHEN land_value BETWEEN 600000 AND 700000 THEN 7
		WHEN land_value BETWEEN 700000 AND 800000 THEN 8
		WHEN land_value BETWEEN 800000 AND 900000 THEN 9
		WHEN land_value BETWEEN 1000000 AND 2000000 THEN 10
		WHEN land_value BETWEEN 2000000 AND 3000000 THEN 11
		WHEN land_value > 3000000 THEN 12
		ELSE 0
  END AS sort_order
FROM nashville_housing_data
WHERE land_value IS NOT NULL
GROUP BY land_value_range, sort_order
ORDER BY sort_order;

-- Looking counts of homes in each bracket of building values
SELECT
  CASE
    WHEN building_value < 100000 THEN 'Under 100k'
    WHEN building_value BETWEEN 100000 AND 200000 THEN '100k-200k'
    WHEN building_value BETWEEN 200000 AND 300000 THEN '200k-300k'
    WHEN building_value BETWEEN 300000 AND 400000 THEN '300k-400k'
    WHEN building_value BETWEEN 400000 AND 500000 THEN '400k-500k'
    WHEN building_value BETWEEN 500000 AND 600000 THEN '500k-600k'
    WHEN building_value BETWEEN 600000 AND 700000 THEN '600k-700k'
    WHEN building_value BETWEEN 700000 AND 800000 THEN '700k-800k'
    WHEN building_value BETWEEN 800000 AND 900000 THEN '800k-900k'
    WHEN building_value BETWEEN 900000 AND 1000000 THEN '900k-1M'
    WHEN building_value BETWEEN 1000000 AND 2000000 THEN '1M-2M'
    WHEN building_value BETWEEN 2000000 AND 3000000 THEN '2M-3M'
    WHEN building_value BETWEEN 3000000 AND 4000000 THEN '3M-4M'
    WHEN building_value BETWEEN 4000000 AND 5000000 THEN '4M-5M'
    WHEN building_value BETWEEN 5000000 AND 6000000 THEN '5M-6M'
    WHEN building_value BETWEEN 6000000 AND 7000000 THEN '6M-7M'
    WHEN building_value BETWEEN 7000000 AND 8000000 THEN '7M-8M'
    WHEN building_value BETWEEN 8000000 AND 9000000 THEN '8M-9M'
    WHEN building_value BETWEEN 9000000 AND 10000000 THEN '9M-10M'
    WHEN building_value BETWEEN 10000000 AND 11000000 THEN '10M-11M'
    WHEN building_value BETWEEN 11000000 AND 12000000 THEN '11M-12M'
    WHEN building_value > 12000000 THEN 'Over 12M'
    ELSE 'Missing Building Value'
  END AS building_value_range,

  COUNT(*) AS count,

  CASE
    WHEN building_value < 100000 THEN 1
    WHEN building_value BETWEEN 100000 AND 200000 THEN 2
    WHEN building_value BETWEEN 200000 AND 300000 THEN 3
    WHEN building_value BETWEEN 300000 AND 400000 THEN 4
    WHEN building_value BETWEEN 400000 AND 500000 THEN 5
    WHEN building_value BETWEEN 500000 AND 600000 THEN 6
    WHEN building_value BETWEEN 600000 AND 700000 THEN 7
    WHEN building_value BETWEEN 700000 AND 800000 THEN 8
    WHEN building_value BETWEEN 800000 AND 900000 THEN 9
    WHEN building_value BETWEEN 900000 AND 1000000 THEN 10
    WHEN building_value BETWEEN 1000000 AND 2000000 THEN 11
    WHEN building_value BETWEEN 2000000 AND 3000000 THEN 12
    WHEN building_value BETWEEN 3000000 AND 4000000 THEN 13
    WHEN building_value BETWEEN 4000000 AND 5000000 THEN 14
    WHEN building_value BETWEEN 5000000 AND 6000000 THEN 15
    WHEN building_value BETWEEN 6000000 AND 7000000 THEN 16
    WHEN building_value BETWEEN 7000000 AND 8000000 THEN 17
    WHEN building_value BETWEEN 8000000 AND 9000000 THEN 18
    WHEN building_value BETWEEN 9000000 AND 10000000 THEN 19
    WHEN building_value BETWEEN 10000000 AND 11000000 THEN 20
    WHEN building_value BETWEEN 11000000 AND 12000000 THEN 21
    WHEN building_value > 12000000 THEN 22
    ELSE 0
  END AS sort_order
FROM nashville_housing_data
WHERE building_value IS NOT NULL
GROUP BY building_value_range, sort_order
ORDER BY sort_order;



-- Standalone values

-- The biggest owned plot of land in Nashville
SELECT MAX(acreage) FROM nashville_housing_data;
SELECT address_trimmed, city, land_use, acreage
FROM nashville_housing_data
WHERE acreage LIKE '160.06';

-- Addresses of some of the lowest value buildings in Nashville
SELECT address_trimmed, city, MIN(building_value)
FROM nashville_housing_data
WHERE building_value IS NOT NULL
GROUP BY address_trimmed, city
ORDER BY 3;

-- Showing the addresses of some of the most expensive buildings in Nashville
SELECT address_trimmed, building_value
FROM nashville_housing_data
WHERE building_value IS NOT NULL
ORDER BY building_value DESC;

-- Address of the most expensive building in Nashville (A Catholic Church)
SELECT address_trimmed, city, land_use, building_value
FROM nashville_housing_data
WHERE building_value LIKE 12971800;

-- Address of the cheapest building in Nashville (Home off the market)
Select address_trimmed, city, land_use, building_value
FROM nashville_housing_data
WHERE building_value LIKE '1400';


SELECT * FROM nashville_housing_data;










