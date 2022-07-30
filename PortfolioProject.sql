SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY	 3, 5

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY	 3, 5

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Case_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighesInfectionCount, MAX((total_cases/population)*100) AS PercentageInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentageInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continent with higest death count per population
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) as Total_Cases, 
			   SUM(cast(new_deaths as int)) as Total_Deaths, 
			   SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT DEA.continent, DEA.location, DEA.date, dea.population, vac.new_vaccinations,
			   SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location,
			   DEA.Date) as RollingPeoplevaccinated
FROM PortfolioProject..CovidDeaths AS DEA
JOIN	PortfolioProject..CovidVaccinations AS VAC
			ON DEA.location = VAC.location
			AND DEA.date		= VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3;

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeoplevaccinated)
AS 
(
SELECT DEA.continent, DEA.location, DEA.date, dea.population, vac.new_vaccinations,
			   SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location,
			   DEA.Date) as RollingPeoplevaccinated
FROM PortfolioProject..CovidDeaths AS DEA
JOIN	PortfolioProject..CovidVaccinations AS VAC
			ON DEA.location = VAC.location
			AND DEA.date		= VAC.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


