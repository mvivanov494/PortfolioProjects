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
-- ORDER BY parcel_id;

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