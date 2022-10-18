-- displaying our covid deaths data
SELECT *
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL;

-- displaying our covid vaccinations data
SELECT *
FROM CovidData..CovidVaccinations
WHERE continent IS NOT NULL;
ORDER BY 3;

-- Select specific columns for analysis from covid deaths table
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Investigating Total cases vs total deaths
-- Shows the likelihhod of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS percentage_of_deaths
FROM CovidData..CovidDeaths
WHERE location LIKE '%Africa%' AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total cases Vs Population
-- Shows what percentatge of the population has been infected with Covid
SELECT location,date,population,total_cases,(total_cases/population)*100 AS population_percentage
FROM CovidData..CovidDeaths
--WHERE location LIKE '%Africa%'
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases)AS HighestInfectionCount,MAX((total_cases/population))*100 AS population_percentage
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY population_percentage DESC;

-- Looking at countries with the highest death count compared to population
SELECT location,population,MAX(total_deaths)AS HighestDeathCount,MAX((total_deaths/population))*100 AS death_percentage
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestDeathCount DESC;

-- Let's look at continents with highest death count
SELECT continent,MAX(total_deaths)AS HighestDeathCount
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- 

--GLOBAL NUMBERS
-- death percentage grouped by date
SELECT date,SUM(new_cases) AS sum_of_new_cases,SUM(CAST(new_deaths AS int)) AS sum_of_new_deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathpercentage
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- death percentage globally
SELECT SUM(new_cases) AS sum_of_new_cases,SUM(CAST(new_deaths AS int)) AS sum_of_new_deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathpercentage
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs vaccination
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths d
JOIN CovidData..CovidVaccinations v
		ON d.location = v.location
		AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE
With popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths d
JOIN CovidData..CovidVaccinations v
		ON d.location = v.location
		AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS percentagevaccinated
FROM popvsvac
ORDER BY 2,3;

-- CREATE TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths d
Join CovidData..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

-- CREATE VIEW
CREATE VIEW percentofvaccinated AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths d
JOIN CovidData..CovidVaccinations v
		ON d.location = v.location
		AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3;
