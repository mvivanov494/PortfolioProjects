**Covid data from:** https://ourworldindata.org/covid-deaths between 2020-02-24 to 2021-04-30 from all countries 85,000+ entries per CSV file
**Tableau Dashboard Link: **
https://public.tableau.com/app/profile/mikhail.ivanov8682/viz/CovidDataDashboard_17517669300950/Dashboard1

🦠 **COVID-19 Global Data Exploration & Analysis**
This project demonstrates full-cycle data exploration using SQL to analyze and uncover insights from global COVID-19 datasets. It highlights core analyst skills including data cleaning, joins, CTEs, window functions, aggregate analysis, and performance optimization using temporary tables and views.

🔧 **Tools Used**
MySQL – For data import, cleaning, and in-depth querying

CSV Files – Raw COVID-19 death and vaccination datasets

Windows File System – Used LOAD DATA INFILE to bring data into MySQL from local CSVs

Git/GitHub – For source control and project sharing

📁 **Project Overview**
Imported and normalized large-scale COVID-19 datasets into SQL using LOAD DATA INFILE with NULLIF() handling

Created clean, relational tables for COVID deaths and vaccinations globally

Performed advanced SQL analysis to compute infection and death percentages, population-level vaccination rates, and temporal insights

Applied joins, CTEs, temporary tables, and views to structure reusable and modular analytics queries

Segmented analysis by country, continent, and date for trend breakdowns

Created views to simplify repeated access to key KPIs, including highest infection rate, rolling vaccination percentage, and global death rates

🧠 **Key SQL Concepts Demonstrated**
Data Cleaning: Using NULLIF() to handle missing entries on load

Data Joins: Merged vaccination and death datasets on location and date

Window Functions: Used SUM() OVER (PARTITION BY ...) for cumulative vaccination counts

CTEs: Structured complex logic like percent vaccinated by population

Temporary Tables: Stored intermediate rolling results for analysis and visualization

Views: Persisted KPIs like highest death rates, infection rates, and vaccination coverage

Aggregate Functions: Calculated total cases, deaths, infection % by population, and death rates

CASE Statements: Used for readable output formatting and filtering logic

🔍 **Example Analysis Conducted**
Likelihood of death per infection in the U.S.

Infection penetration (% of population infected) by country

Rolling vaccination trends using window functions

Global case fatality rate across all countries

Top countries by infection and death rates (absolute and per capita)

Most affected continents by cumulative death totals

🧮 **Views Created**
percentpopulationvaccinated – Cumulative vaccinations by country

highestinfectionrate – Countries with highest % of population infected

highestdeathcount – Countries with highest death counts

highestdeathcountbycontinent – Continent-level death tallies

worlddeathpercentage – Global fatality ratio based on reported cases and deaths

🧾 **Outcome**
This project showcases practical data exploration methods used in health and crisis analytics. By using SQL to analyze real-world COVID-19 data, it simulates the responsibilities of a data analyst investigating trends in large, multi-dimensional public health datasets.
