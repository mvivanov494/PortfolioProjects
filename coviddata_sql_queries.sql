/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types

*/

USE coviddata;

-- Exploring Data that we are going to be starting with

SELECT *
FROM coviddeathstable
WHERE location IS NOT NULL;

SELECT location, curr_date, total_cases, total_deaths 
FROM coviddeathstable LIMIT 60000;

DESCRIBE coviddata.coviddeathstable;
DESCRIBE covidvaccinationstable;

DROP TABLE coviddeathstable;
DROP TABLE covidvaccinationstable;

--Table creation

CREATE TABLE coviddeathstable (
iso_code VARCHAR(100),
continent VARCHAR(100),
location VARCHAR(100),
curr_date DATE,
population BIGINT,
total_cases DOUBLE,
new_cases DOUBLE,
new_cases_smoothed DOUBLE,
total_deaths DOUBLE,
new_deaths DOUBLE,
new_deaths_smoothed DOUBLE,
total_cases_per_million DOUBLE,
new_cases_per_million DOUBLE,
new_cases_smoothed_per_million DOUBLE,
total_deaths_per_million DOUBLE,
new_deaths_per_million DOUBLE,
new_deaths_smoothed_per_million DOUBLE,
reproduction_rate DOUBLE,
icu_patients DOUBLE,
icu_patients_per_million DOUBLE,
hosp_patients DOUBLE,
hosp_patients_per_million DOUBLE,
weekly_icu_admissions DOUBLE,
weekly_icu_admissions_per_million DOUBLE,
weekly_hosp_admissions DOUBLE,
weekly_hosp_admissions_per_million DOUBLE
);

CREATE TABLE covidvaccinationstable(
iso_code VARCHAR(100),
continent VARCHAR(100),
location VARCHAR(100),
curr_date DATE,
new_tests DOUBLE,
total_tests DOUBLE,
total_tests_per_thousand DOUBLE,
new_tests_per_thousand DOUBLE,
new_tests_smoothed DOUBLE,
new_tests_smoothed_per_thousand DOUBLE,
positive_rate DOUBLE,
tests_per_case DOUBLE,
tests_units TEXT,
total_vaccinations DOUBLE,
people_vaccinated DOUBLE,
people_fully_vaccinated DOUBLE,
new_vaccinations DOUBLE,
new_vaccinations_smoothed DOUBLE,
total_vaccinations_per_hundred DOUBLE,
people_vaccinated_per_hundred DOUBLE,
people_fully_vaccinated_per_hundred DOUBLE,
new_vaccinations_smoothed_per_million DOUBLE,
stringency_index DOUBLE,
population_density DOUBLE,
median_age DOUBLE,
aged_65_older DOUBLE,
aged_70_older DOUBLE,
gdp_per_capita DECIMAL(60,30),
extreme_poverty DOUBLE,
cardiovasc_death_rate DOUBLE,
diabetes_prevalence DOUBLE,
female_smokers DOUBLE,
male_smokers DOUBLE,
handwashing_facilities DOUBLE,
hospital_beds_per_thousand DOUBLE,
life_expectancy DOUBLE,
human_development_index DOUBLE
);

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
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/coviddata/BASE2(vaccinations)tocsv.csv'
INTO TABLE covidvaccinationstable
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
  @iso_code, @continent, @location, @curr_date, @new_tests, @total_tests,
  @total_tests_per_thousand, @new_tests_per_thousand, @new_tests_smoothed,
  @new_tests_smoothed_per_thousand, @positive_rate, @tests_per_case,
  @tests_units, @total_vaccinations, @people_vaccinated, @people_fully_vaccinated,
  @new_vaccinations, @new_vaccinations_smoothed, @total_vaccinations_per_hundred,
  @people_vaccinated_per_hundred, @people_fully_vaccinated_per_hundred,
  @new_vaccinations_smoothed_per_million, @stringency_index, @population_density,
  @median_age, @aged_65_older, @aged_70_older, @gdp_per_capita,
  @extreme_poverty, @cardiovasc_death_rate, @diabetes_prevalence,
  @female_smokers, @male_smokers, @handwashing_facilities,
  @hospital_beds_per_thousand, @life_expectancy, @human_development_index
)
SET
  iso_code = NULLIF(@iso_code, ''),
  continent = NULLIF(@continent, ''),
  location = NULLIF(@location, ''),
  curr_date = NULLIF(@curr_date, ''),
  new_tests = NULLIF(@new_tests, ''),
  total_tests = NULLIF(@total_tests, ''),
  total_tests_per_thousand = NULLIF(@total_tests_per_thousand, ''),
  new_tests_per_thousand = NULLIF(@new_tests_per_thousand, ''),
  new_tests_smoothed = NULLIF(@new_tests_smoothed, ''),
  new_tests_smoothed_per_thousand = NULLIF(@new_tests_smoothed_per_thousand, ''),
  positive_rate = NULLIF(@positive_rate, ''),
  tests_per_case = NULLIF(@tests_per_case, ''),
  tests_units = NULLIF(@tests_units, ''),
  total_vaccinations = NULLIF(@total_vaccinations, ''),
  people_vaccinated = NULLIF(@people_vaccinated, ''),
  people_fully_vaccinated = NULLIF(@people_fully_vaccinated, ''),
  new_vaccinations = NULLIF(@new_vaccinations, ''),
  new_vaccinations_smoothed = NULLIF(@new_vaccinations_smoothed, ''),
  total_vaccinations_per_hundred = NULLIF(@total_vaccinations_per_hundred, ''),
  people_vaccinated_per_hundred = NULLIF(@people_vaccinated_per_hundred, ''),
  people_fully_vaccinated_per_hundred = NULLIF(@people_fully_vaccinated_per_hundred, ''),
  new_vaccinations_smoothed_per_million = NULLIF(@new_vaccinations_smoothed_per_million, ''),
  stringency_index = NULLIF(@stringency_index, ''),
  population_density = NULLIF(@population_density, ''),
  median_age = NULLIF(@median_age, ''),
  aged_65_older = NULLIF(@aged_65_older, ''),
  aged_70_older = NULLIF(@aged_70_older, ''),
  gdp_per_capita = NULLIF(@gdp_per_capita, ''),
  extreme_poverty = NULLIF(@extreme_poverty, ''),
  cardiovasc_death_rate = NULLIF(@cardiovasc_death_rate, ''),
  diabetes_prevalence = NULLIF(@diabetes_prevalence, ''),
  female_smokers = NULLIF(@female_smokers, ''),
  male_smokers = NULLIF(@male_smokers, ''),
  handwashing_facilities = NULLIF(@handwashing_facilities, ''),
  hospital_beds_per_thousand = NULLIF(@hospital_beds_per_thousand, ''),
  life_expectancy = NULLIF(@life_expectancy, ''),
  human_development_index = NULLIF(@human_development_index, '');

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

-- Creating view(s) to store data for later visualizations

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

CREATE VIEW highestdeathcountbycontinent AS
-- Showing the continents with the highest death counts per population
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM coviddeathstable
WHERE location IS NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;
