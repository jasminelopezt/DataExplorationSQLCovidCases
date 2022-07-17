/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



Select *
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 1,2

--TOTAL CASES VS. POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION (globally) GOT COVID
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 AS 
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, MAX(cast(total_deaths as int)) as TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

---BREAKING THINGS DOWN BY CONTINENT

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(cast(total_deaths as int)) as TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TOTALDEATHCOUNT desc

--GLOBAL NUMBERS SUMMARIZED
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
       On dea.location = vac.location
	   and dea.date = vac.date

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--shows percentage of population that has received at least one covid vaccine
SELECT dea.continent, dea.location, dea.date, dea.population
vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
       On dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



--DATA WORKING WITH NOW
Select *
From PortfolioProject..CovidVaccinations$
Where continent is not null
Order By 3,4

-- Countries with Highest Diabetes Prevalence of Covid patients

Select Location, MAX(diabetes_prevalence) as HighestDiabetesPrevalence
From PortfolioProject..CovidVaccinations$
--Where location like '%states%'
Group by Location, diabetes_prevalence
ORDER BY diabetes_prevalence desc

Select *
From PortfolioProject..CovidVaccinations$
Where continent is not null
Order By 3,4

