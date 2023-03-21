
Select *
From [Project Portfolio]..CovidDeaths
Where continent is null
Order by 3,4


Select *
From [Project Portfolio]..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Project Portfolio]..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the liklihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, cast(total_deaths as bigint)/NULLIF(cast(total_cases as float),0)*100 AS deathPercentage
From [Project Portfolio]..CovidDeaths
Where location like '%Guyana%'
Order by 1,2


-- Looking at total cases vs population
-- Shows percentage of what population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Project Portfolio]..CovidDeaths
--Where location like '%Guyana%'
Order by 1,2

-- Looking at countries with highest infection rate compared to population.

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Project Portfolio]..CovidDeaths
--Where location like '%Guyana%'
Group by Location, population
Order by PercentPopulationInfected desc


-- Showing countries with highest death count per Population.
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Project Portfolio]..CovidDeaths
--Where location like '%Guyana%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Breaking things down by continent
-- Showing the continents with the highest death count per population.

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Project Portfolio]..CovidDeaths
--Where location not like '%income%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers
-- had a error with dividing by 0 but check NULLIF for solution0

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From [Project Portfolio]..CovidDeaths
--Where location like '%Guyana%'
Where continent is not null
--Group by date
Order by 1,2


--Death Percentage accross the whole world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From [Project Portfolio]..CovidDeaths
--Where location like '%Guyana%'
Where continent is not null
--Group by date
Order by 1,2


--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

-- Had an error here with (cast....as int), but it shouldve been (cast...as bigint)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3


--Using a CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
-- Drop Table for when removing something

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


Create Table PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3


Use [Project Portfolio]
GO
Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, Convert(date, dea.date)) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3

