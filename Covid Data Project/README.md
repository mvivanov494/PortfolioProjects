### Personal Project, COVID-19 Data Analysis and Dashboard Development

#### Covid data between 2020-02-24 to 2021-04-30: 
<https://ourworldindata.org/covid-deaths>

#### Tableau Dashboard Link: 
<https://shorturl.at/YBznK> 

This project demonstrates full-cycle data exploration using SQL to analyze and uncover insights from global COVID-19 datasets. It highlights core analyst skills including data cleaning, joins, CTEs, window functions, aggregate analysis, and performance optimization using temporary tables and views. 🦠

### 🔧 Tools Used: 

- MySQL – For data import, cleaning, and in-depth querying

- CSV Files – Raw COVID-19 death and vaccination datasets

- Windows File System – Used LOAD DATA INFILE to bring data into MySQL from local CSVs

- Git/GitHub – For source control and project sharing

- Tableau

### 📁 Project Overview:

- Imported and normalized large-scale COVID-19 datasets into SQL using LOAD DATA INFILE with NULLIF() handling

```sql
-- Loading data from provided CSV files and accounting for Null spaces with NULLIF()

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/coviddata/BASE1(Deaths)tocsv.csv' INTO TABLE coviddeathstable
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
  @iso_code, @continent, @location, @curr_date, @population, @total_cases, @new_cases,
  @new_cases_smoothed, @total_deaths, @new_deaths, @new_deaths_smoothed,
  @total_cases_per_million, @new_cases_per_million, @new_cases_smoothed_per_million,
  @total_deaths_per_million, @new_deaths_per_million, @new_deaths_smoothed_per_million,
  @reproduction_rate, @icu_patients, @icu_patients_per_million, @hosp_patients,
  @hosp_patients_per_million, @weekly_icu_admissions, @weekly_icu_admissions_per_million,
  @weekly_hosp_admissions, @weekly_hosp_admissions_per_million
)
SET
  iso_code = NULLIF(@iso_code, ''),
  continent = NULLIF(@continent, ''),
  location = NULLIF(@location, ''),
  curr_date = NULLIF(@curr_date, ''),
  population = NULLIF(@population, ''),
  total_cases = NULLIF(@total_cases, ''),
  new_cases = NULLIF(@new_cases, ''),
  new_cases_smoothed = NULLIF(@new_cases_smoothed, ''),
  total_deaths = NULLIF(@total_deaths, ''),
  new_deaths = NULLIF(@new_deaths, ''),
  new_deaths_smoothed = NULLIF(@new_deaths_smoothed, ''),
  total_cases_per_million = NULLIF(@total_cases_per_million, ''),
  new_cases_per_million = NULLIF(@new_cases_per_million, ''),
  new_cases_smoothed_per_million = NULLIF(@new_cases_smoothed_per_million, ''),
  total_deaths_per_million = NULLIF(@total_deaths_per_million, ''),
  new_deaths_per_million = NULLIF(@new_deaths_per_million, ''),
  new_deaths_smoothed_per_million = NULLIF(@new_deaths_smoothed_per_million, ''),
  reproduction_rate = NULLIF(@reproduction_rate, ''),
  icu_patients = NULLIF(@icu_patients, ''),
  icu_patients_per_million = NULLIF(@icu_patients_per_million, ''),
  hosp_patients = NULLIF(@hosp_patients, ''),
  hosp_patients_per_million = NULLIF(@hosp_patients_per_million, ''),
  weekly_icu_admissions = NULLIF(@weekly_icu_admissions, ''),
  weekly_icu_admissions_per_million = NULLIF(@weekly_icu_admissions_per_million, ''),
  weekly_hosp_admissions = NULLIF(@weekly_hosp_admissions, ''),
  weekly_hosp_admissions_per_million = NULLIF(@weekly_hosp_admissions_per_million, '');
```

- Performed advanced SQL analysis to compute infection and death percentages, population-level vaccination rates, and temporal insights

```sql
-- Shows likelihood of death if you contract coronavirus in selected country
SELECT location, curr_date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeathstable WHERE location LIKE '%States%'
AND location IS NOT NULL
ORDER BY 1,2;

-- Shows percent of population infected with coronavirus in selected country
SELECT location, curr_date, total_cases, population, (total_cases/population)*100 AS PercentInfected
FROM coviddeathstable WHERE location LIKE '%States%'
AND location IS NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestPercentInfected
FROM coviddeathstable
WHERE location IS NOT NULL
GROUP BY location, population
ORDER BY HighestPercentInfected DESC;

-- Rolling highest infection rate
SELECT location, population, curr_date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestPercentInfected
FROM coviddeathstable
WHERE location IS NOT NULL
GROUP BY location, population, curr_date
ORDER BY HighestPercentInfected DESC;

-- Showing countries with the highest death count per population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM coviddeathstable
WHERE location IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Breaking things down by continent

-- Showing the continents with the highest death counts per population
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM coviddeathstable
WHERE location IS NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Global numbers

-- World death percentage
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS WorldDeathPercentage
FROM coviddeathstable 
WHERE location IS NOT NULL
ORDER BY 1,2;
```


- Applied joins, CTEs, temporary tables, and views to structure reusable and modular analytics queries

```sql
-- Looking at total population vs vaccinations
-- Shows percentage of population that has received at least one covid vaccine

SELECT dea.continent, dea.location, dea.curr_date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.curr_date) AS RollingCountofVaccinations -- , RollingCountofVaccinations/population*100 AS PercentVaxxed
FROM coviddeathstable dea
JOIN covidvaccinationstable vac
	ON dea.location = vac.location
    AND dea.curr_date = vac.curr_date
WHERE dea.location IS NOT NULL AND dea.location <> 'International' AND dea.location <> 'World'
ORDER BY 2,3;

-- Using a CTE to perform calculation on Partion By in previous query

WITH PopvsVac (continent, location, curr_date, population, new_vaccinations, RollingCountofVaccinations)
AS (
SELECT dea.continent, dea.location, dea.curr_date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.curr_date) AS RollingCountofVaccinations -- , RollingCountofVaccinations/population*100 AS PercentVaxxed
FROM coviddeathstable dea
JOIN covidvaccinationstable vac
	ON dea.location = vac.location
    AND dea.curr_date = vac.curr_date
WHERE dea.location IS NOT NULL AND dea.location <> 'International' AND dea.location <> 'World'
-- ORDER BY 2,3
)
SELECT *, (RollingCountofVaccinations/population)*100 AS RollingPercentofVaccinations
FROM PopvsVac;

-- TEMP TABLE
-- Using a Temp Table to perform calculation on Partition By in previous query

DROP TABLE IF EXISTS percentpopulationvaccinated;
CREATE TEMPORARY TABLE percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
curr_date datetime,
population numeric,
new_vaccinations numeric,
RollingCountofVaccinations numeric
);

INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.curr_date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.curr_date) AS RollingCountofVaccinations -- , RollingCountofVaccinations/population*100 AS PercentVaxxed
FROM coviddeathstable dea
JOIN covidvaccinationstable vac
	ON dea.location = vac.location
    AND dea.curr_date = vac.curr_date;
-- WHERE dea.location IS NOT NULL AND dea.location <> 'International' AND dea.location <> 'World';
-- ORDER BY 2,3;

SELECT *, (RollingCountofVaccinations/population)*100 AS RollingPercentofVaccinations
FROM percentpopulationvaccinated;
```

- Segmented analysis by country, continent, and date for trend breakdowns

- Created views to simplify repeated access to key KPIs, including highest infection rate, rolling vaccination percentage, and global death rates

```sql
CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.curr_date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.curr_date) AS RollingCountofVaccinations -- , RollingCountofVaccinations/population*100 AS PercentVaxxed
FROM coviddeathstable dea
JOIN covidvaccinationstable vac
	ON dea.location = vac.location
    AND dea.curr_date = vac.curr_date
WHERE dea.location IS NOT NULL AND dea.location <> 'International' AND dea.location <> 'World';
-- ORDER BY 2,3;

CREATE VIEW highestinfectionrate AS
-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestPercentInfected
FROM coviddeathstable
WHERE location IS NOT NULL
GROUP BY location, population
ORDER BY HighestPercentInfected DESC;

CREATE VIEW highestdeathcount AS
-- Showing countries with the highest death count per population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM coviddeathstable
WHERE location IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;
```

### 🧠 Key SQL Concepts Demonstrated:

- Data Cleaning: Using NULLIF() to handle missing entries on load

- Data Joins: Merged vaccination and death datasets on location and date

- Window Functions: Used SUM() OVER (PARTITION BY ...) for cumulative vaccination counts

- CTEs: Structured complex logic like percent vaccinated by population

- Temporary Tables: Stored intermediate rolling results for analysis and visualization

- Views: Persisted KPIs like highest death rates, infection rates, and vaccination coverage

- Aggregate Functions: Calculated total cases, deaths, infection % by population, and death rates

- CASE Statements: Used for readable output formatting and filtering logic

### 🧮 Views Created:

- percentpopulationvaccinated – Cumulative vaccinations by country

- highestinfectionrate – Countries with highest % of population infected

- highestdeathcount – Countries with highest death counts

- highestdeathcountbycontinent – Continent-level death tallies

- worlddeathpercentage – Global fatality ratio based on reported cases and deaths

### 🧾 Outcome: 

This project showcases practical data exploration methods used in health and crisis analytics. By using SQL to analyze real-world COVID-19 data, it simulates the responsibilities of a data analyst investigating trends in large, multi-dimensional public health datasets.
