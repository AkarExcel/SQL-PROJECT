SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolio_project..COVIDDEATH
order by 1,2

--Looking at total_case vs total_death
-- Shows percentage Likelihood of dying from covid 

SELECT location, date,population, total_cases, total_deaths, 
cast((CAST(total_deaths as decimal)/CAST(total_cases as decimal))*100 as decimal(8,5)) as DeathPercentage
FROM portfolio_project..COVIDDEATH
--where location like '%benin%'
order by 1,2

-- Looking at country with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX(cast((CAST(total_cases as decimal)/CAST(population as decimal))*100 as decimal(8,5))) as 
PercentPopulationInfected
FROM portfolio_project..COVIDDEATH
Group By population, location
order by PercentPopulationInfected desc

--Show country with Highest death country per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio_project..COVIDDEATH
where continent is not null
Group By location
order by TotalDeathCount desc

--Break down by continent 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio_project..COVIDDEATH
where continent is not null
Group By continent
order by TotalDeathCount desc

-- Global Number
Select Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM portfolio_project..COVIDDEATH

-- select all from vaccination table
select *
from portfolio_project..COVIDDEATH


-- Looking at total vaccination vs population
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from portfolio_project..COVIDDEATH dea
join portfolio_project..COVIDVACCINE vac
on dea.date = vac.date and
dea.location = vac.location
where dea.continent is not null
order by location,date

with PopvsVac (continent, location, date,population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from portfolio_project..COVIDDEATH dea
join portfolio_project..COVIDVACCINE vac
on dea.date = vac.date and
dea.location = vac.location
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE
Drop Table if exists #PercenPopulationVaccinated4
create Table #PercenPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations  numeric,
RollingPeopleVaccinated numeric
)


insert into #PercenPopulationVaccinated
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from portfolio_project..COVIDDEATH dea
join portfolio_project..COVIDVACCINE vac
on dea.date = vac.date and
dea.location = vac.location
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as RollingPopulationPercentage
From #PercenPopulationVaccinated

-- Creating a view to visualize the RollingPopulationPercentage
Create view PercenPopulationVaccinated as
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from portfolio_project..COVIDDEATH dea
join portfolio_project..COVIDVACCINE vac
on dea.date = vac.date and
dea.location = vac.location
where dea.continent is not null



select * from PercenPopulationVaccinated