SELECT * FROM covid_data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_data
ORDER BY 1,2

--Total Cases vs Total Deaths in Serbia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_data
WHERE location = 'Serbia'
ORDER BY 1,2

--Total Cases vs Population in Serbia

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM covid_data
WHERE location = 'Serbia'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covid_data
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with highest death count

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM covid_data
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with the highest death count

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM covid_data
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Total Population vs Vaccination 

SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (Partition by location ORDER BY location, date) as 
PeopleVaccinated
FROM covid_data
WHERE continent is not null
ORDER BY 2,3


--Creating CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (Partition by location ORDER BY location, date) as 
PeopleVaccinated
FROM covid_data
WHERE continent is not null
)
SELECT *, (PeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE if EXISTS  #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
PeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (Partition by location ORDER BY location, date) as 
TotalPeopleVaccinated
FROM covid_data
WHERE continent is not null


SELECT *, (PeopleVaccinated/Population)*100
FROM  #PercentPopulationVaccinated


--Creating View 

Create View PercentPopulationVaccinated AS
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (Partition by location ORDER BY location, date) as 
RollingPeopleVaccinated
FROM covid_data
WHERE continent is not null

SELECT *
FROM PercentPopulationVaccinated
