
--SELECT *
--FROM PortfolioProject_1..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject_1..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_Cases, total_deaths, population
FROM PortfolioProject_1..CovidDeaths
ORDER BY 1,2 

-- Comparing Total Cases vs Total Deaths (by Country) 
-- Column shows likelihood of dying due to COVID19 in country
SELECT Location, date, total_cases, new_Cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2 

-- Comparing Total Cases vs Population (by Country)
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS CovidPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2 

-- Countries with highest infection rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject_1..CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, Population
ORDER BY 4 Desc


-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 2 Desc

-- Continent with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 Desc

-- Alternative form of above query
-- "More Correct numbers"
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 Desc

-- Global COVID19 case statistics
SELECT Date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

-- Global COVID19 statistics aggregate
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT *
FROM PortfolioProject_1..CovidDeaths as DEA
JOIN PortfolioProject_1..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

-- Comparing Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY DEA.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject_1..CovidDeaths as dea
JOIN PortfolioProject_1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL	
ORDER BY 2,3

-- USING CommonTableExpression(CTE)
WITH PopvsVac (Contient, Location, Date, Population, New_Vaccinations, RollingVaccinationCount) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY DEA.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject_1..CovidDeaths as dea
JOIN PortfolioProject_1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL	
--ORDER BY 2,3
)
SELECT *, (RollingVaccinationCount/Population)*100 AS PercentOfPopulationVaccinated
FROM PopvsVac


-- USING Temporary Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY DEA.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject_1..CovidDeaths as dea
JOIN PortfolioProject_1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL	
--ORDER BY 2,3
SELECT *, (RollingVaccinationCount/Population)*100 AS PercentOfPopulationVaccinated
FROM #PercentPopulationVaccinated

-- Population counts are not updated frequently
-- Causes RollingVaccinationCount to be greater than Population
-- And PercentOfPopulationVaccinated to be greater than 100%



-- Creating view to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY DEA.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject_1..CovidDeaths as dea
JOIN PortfolioProject_1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL	
--ORDER BY 2,3

