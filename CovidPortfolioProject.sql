SELECT *
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidPortfolioProject..CovidDeaths
--ORDER BY 3,4

--Select Data to be analysed

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Analysing total cases vs total deaths
-- Shows likelihood of death if Covid is contracted

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location like 'Zambia'
ORDER BY 1,2

-- Analysing total cases vs population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like 'Zambia'
WHERE continent is NOT NULL
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like 'Zambia'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like 'Botswana'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS UP BY CONTINENT


-- Showing continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like 'Botswana'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like 'Zambia'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Showing global death percentage

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


-- Analysing Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.location = 'Zambia'
-- WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

USE CovidPortfolioProject
GO

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated