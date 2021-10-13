select * 
from PortfolioProject.dbo.Covid_deaths$
order by 3,4

select * 
from PortfolioProject.dbo.Covid_vaccinations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.Covid_deaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contrct covid in your country

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject.dbo.Covid_deaths$
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got Covid

select location, date, new_cases, total_deaths, total_cases, population, (total_cases/population)*100 as percent_population_infected
from PortfolioProject.dbo.Covid_deaths$
where location like '%Australia%'
order by 1,2

select * from PortfolioProject.dbo.Covid_deaths$

select * from PortfolioProject.dbo.Covid_vaccinations$

-- Looking at Countries with the Highest Infection Rates compared to Population

select location, population, max(total_cases/population)*100 as percent_population_infected
from PortfolioProject.dbo.Covid_deaths$
group by location, population
order by percent_population_infected desc


-- Looking at Countries with the Highest Death Count

select location, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..Covid_deaths$
where continent is not null
group by location, continent
order by total_death_count desc



-- Looking at Countries with the Highest Death Rates compared to Population

select location, population, max(total_deaths/population)*100 as death_rate
from PortfolioProject.dbo.Covid_deaths$
where continent is not null
group by location, population
order by death_rate desc


-- LETS BREAK THINGS DOWN BY CONTINENT 

-- Looking at Continents with the Highest Death Count compared to Population

select continent, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..Covid_deaths$
where continent is not null
group by continent
order by total_death_count desc

-- Looking at Continents with the Highest Death Rates compared to Population

select continent, max(total_deaths/population)*100 as death_rate
from PortfolioProject.dbo.Covid_deaths$
where continent is not null
group by continent
order by death_rate desc


-- GLOBAL NUMBERS 

-- Global death rate as a percentage of total cases

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject.dbo.Covid_deaths$
where continent is not null
group by date 
order by 1

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject.dbo.Covid_deaths$
where continent is not null


-- Looking at Total Populations vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeople_Vaccinated/Population)*100
from PortfolioProject.dbo.Covid_deaths$ as dea
join PortfolioProject.dbo.Covid_vaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeople_Vaccinated/Population)*100
from PortfolioProject.dbo.Covid_deaths$ as dea
join PortfolioProject.dbo.Covid_vaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


--- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeople_Vaccinated/Population)*100
from PortfolioProject.dbo.Covid_deaths$ as dea
join PortfolioProject.dbo.Covid_vaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--creating a View to store data for later vizualisation 

Create View #

use PortfolioProject
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeople_Vaccinated/Population)*100
from PortfolioProject.dbo.Covid_deaths$ as dea
join PortfolioProject.dbo.Covid_vaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

