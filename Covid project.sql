SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProjects..CovidDeaths
ORDER BY 1, 2

---Looking at total cases ve total deaths
---Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage 
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


---Looking at total cases vs population
---Shows what percentage of population got covid

SELECT location, date, total_cases, population, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0)) * 100 AS Infectionpercentage 
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


---Looking at countries with the Highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, 
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS Percent_population_infected 
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY Percent_population_infected DESC


---Showing the countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM PortfolioProjects..CovidDeaths
GROUP BY location
ORDER BY total_death_count DESC

SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

---Breaking it up by continents

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC

---Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


---Global Numbers

SELECT date, SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, 
(SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS Death_percentage 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, 
(SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS Death_percentage 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


---Looking at total population vs vaccinations

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(bigint, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER by death.location, death.date) AS total_vaccines_to_date
FROM PortfolioProjects..CovidDeaths death
JOIN PortfolioProjects..CovidVaccinations vaccine
	ON	death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL 
ORDER BY 2,3

---Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccines_to_date numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(bigint, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER by death.location, death.date) AS total_vaccines_to_date
FROM PortfolioProjects..CovidDeaths death
JOIN PortfolioProjects..CovidVaccinations vaccine
	ON	death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL

SELECT *, (total_vaccines_to_date/population) * 100 AS percent_population_vaccinated
FROM #PercentPopulationVaccinated


---Creating view to store datat for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(bigint, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER by death.location, death.date) AS total_vaccines_to_date
FROM PortfolioProjects..CovidDeaths death
JOIN PortfolioProjects..CovidVaccinations vaccine
	ON	death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL



