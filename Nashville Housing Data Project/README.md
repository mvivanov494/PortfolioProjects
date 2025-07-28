## Personal Project, Nashville Housing Data Cleaning, Analysis, and Visualization

#### Tableau Dashboard Link:
<https://shorturl.at/NhTgX>

This project showcases a complete end-to-end data cleaning, transformation, analysis, and visualization workflow using SQL, Excel, and Tableau, centered around real estate property data from Nashville, Tennessee. It highlights key data analysis skills including ETL processes, data quality management, and dashboard development.

### Tools Used:
---

- MySQL – For importing, cleaning, and analyzing structured data using advanced SQL

- Excel – For initial cleaning, formatting, and handling nulls and duplicates

- Tableau – For interactive data visualization and dashboard design

- Git/GitHub – For version control and project documentation

- Project Overview Imported a raw dataset of 56,000+ rows using LOAD DATA INFILE in MySQL

### Code:
---

- Standardized and split full address fields into street, city, and state using string functions like SUBSTRING_INDEX, LEFT, and LOCATE
  
```sql
ALTER TABLE nashville_housing_data
ADD address_trimmed TEXT;

UPDATE nashville_housing_data
SET address_trimmed = TRIM(SUBSTRING(property_address, 1, LENGTH(property_address) - LOCATE(' ', REVERSE(property_address)))) ;

ALTER TABLE nashville_housing_data
ADD city TEXT;

UPDATE nashville_housing_data
SET city = TRIM(SUBSTRING_INDEX(property_address, ' ', -1));
```

- Removed duplicate rows using Common Table Expressions (CTEs) with ROW_NUMBER() OVER (PARTITION BY ...)
  
```sql
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
```

- Converted categorical flags such as ‘Y’ and ‘N’ to readable formats like ‘Yes’ and ‘No’
  
```sql
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
```

- Created new categorized columns for building and land value ranges using CASE statements
  
```sql
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
```

- Aggregated and grouped home counts by bedrooms, bathrooms, year built, and price tiers
  
```sql
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
```

- Deleted irrelevant columns after transformation to finalize the dataset

- Built a Tableau dashboard to visualize metrics such as construction year distribution, bedroom counts, building value tiers, land usage, and notable high/low-value properties

- Key Concepts Demonstrated Data wrangling with SQL (CTEs, joins, aggregates, string manipulation)

- Data pipeline setup from raw CSV to structured, queryable tables

- Value binning using CASE for price brackets

- Excel techniques for NULL handling and formatting (Ctrl+H, filters, keyboard shortcuts)

### Outcome: 
---

This project simulates a real-world data cleaning and reporting workflow that a business analyst or data analyst would perform to prepare property data for stakeholder analysis, reporting, or integration into BI tools.
