/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT location, date, population, total_cases, total_deaths
FROM dbo.CovidDeaths
ORDER BY 2, 1

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths 
WHERE continent is null
ORDER BY 1,2 


-- Shows likelihood of dying if you contract COVID in your country
SELECT location, MAX(population) as Population, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths, (MAX(cast(total_deaths as int))/MAX(total_cases))*100 as DeathPercentage
FROM dbo.CovidDeaths 
WHERE continent is not null
GROUP BY location
HAVING MAX(cast(total_deaths as int)) is not null
ORDER BY DeathPercentage Desc

-- Showing countries with the Highest Death Count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM dbo.CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths Desc

-- Looking at countries with Highest Infection rate compared to Pupulation
SELECT location, MAX(population) as Population, MAX(total_cases) as TotalCases, (MAX(total_cases)/MAX(population))*100 as InfectionRate
FROM dbo.CovidDeaths 
WHERE continent is not null
GROUP BY location
HAVING MAX(total_cases) is not null
ORDER BY InfectionRate Desc


-- Showing continents with the Highest Death Count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM dbo.CovidDeaths 
WHERE continent is null and location != 'World' and location != 'Upper middle income' and location != 'High income' and location != 'Lower middle income' and location != 'Low income' and location != 'International' and location != 'European Union'
GROUP BY location
ORDER BY TotalDeaths Desc


-- Shows continents with the highest death rates
SELECT location, MAX(population) as Population, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths, (MAX(cast(total_deaths as int))/MAX(total_cases))*100 as DeathPercentage
FROM dbo.CovidDeaths 
WHERE continent is null and location != 'World' and location != 'Upper middle income' and location != 'High income' and location != 'Lower middle income' and location != 'Low income' and location != 'International' and location != 'European Union'
GROUP BY location
HAVING MAX(cast(total_deaths as int)) is not null
ORDER BY DeathPercentage Desc



-- Total Population vs Vaccinations
-- Shows Total number of vaccinations in a country on a rolling basis 
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location is not null
ORDER BY 1,2 


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select Location, MAX(Population) as Population, MAX(TotalPeopleVaccinated) as TotalVaccinations,
	MAX(TotalPeopleVaccinated)/MAX(Population)*100 as VaccinationToPopulationRatio
From #PercentPopulationVaccinated
GROUP BY Location
ORDER BY 4 DESC





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalVaccinations
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3