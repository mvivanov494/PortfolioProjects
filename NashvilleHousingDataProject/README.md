**Tableau Dashboard Link:**
https://public.tableau.com/app/profile/mikhail.ivanov8682/viz/NashvilleHousingDataDashboard_17521083222670/Dashboard1

**Nashville Housing Data Cleaning & Visualization Project**
This project showcases a complete end-to-end data cleaning, transformation, analysis, and visualization workflow using SQL, Excel, and Tableau, centered around real estate property data from Nashville, Tennessee. It highlights key data analysis skills including ETL processes, data quality management, and dashboard development.

**Tools Used**
MySQL – For importing, cleaning, and analyzing structured data using advanced SQL

Excel – For initial cleaning, formatting, and handling nulls and duplicates

Tableau – For interactive data visualization and dashboard design

Git/GitHub – For version control and project documentation

**Project Overview**
Imported a raw dataset of 56,000+ rows using LOAD DATA INFILE in MySQL

Standardized and split full address fields into street, city, and state using string functions like SUBSTRING_INDEX, LEFT, and LOCATE

Replaced missing or blank values using NULLIF, IFNULL, and manual preprocessing in Excel

Removed duplicate rows using Common Table Expressions (CTEs) with ROW_NUMBER() OVER (PARTITION BY ...)

Converted categorical flags such as ‘Y’ and ‘N’ to readable formats like ‘Yes’ and ‘No’

Created new categorized columns for building and land value ranges using CASE statements

Aggregated and grouped home counts by bedrooms, bathrooms, year built, and price tiers

Deleted irrelevant columns after transformation to finalize the dataset

Built a Tableau dashboard to visualize metrics such as construction year distribution, bedroom counts, building value tiers, land usage, and notable high/low-value properties

**Key Concepts Demonstrated**
Data wrangling with SQL (CTEs, joins, aggregates, string manipulation)

Data pipeline setup from raw CSV to structured, queryable tables

Value binning using CASE for price brackets

Dimensional modeling through address field decomposition

Excel techniques for NULL handling and formatting (Ctrl+H, filters, keyboard shortcuts)

Visual analytics and interactive dashboard publishing in Tableau

**Outcome**
This project simulates a real-world data cleaning and reporting workflow that a business analyst or data analyst would perform to prepare property data for stakeholder analysis, reporting, or integration into BI tools.
