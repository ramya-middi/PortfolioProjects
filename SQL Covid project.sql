select * from CovidDeaths order by 3

--select data that we are going to be using throughout the project
Select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at the total cases and the total cases in India
--shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidDeaths
Where location = 'India'
order by 1, 2

--looking at the total cases vs population
--shows the percentage of population got covid
select location, date, population, total_cases, (total_cases/population) * 100 as percentofpopulationinfected
from CovidDeaths
Where location = 'India'
order by 1, 2

--looking at the countries with highest infection rate compared to population
select location, population, max(total_cases) Highestinfectionrate, max((total_cases/population))*100 percentpopulationinfected
from CovidDeaths
where continent is not null
group by location, population
order by 3 desc

--showing deathpercentage vs Population
select location, population, (total_deaths)/population *100 as DeathsvsPopulation
from CovidDeaths
group by location, population
order by 1

---showing countries with highest death count per population
select location, population, max(total_deaths) HighestDeaths, max((total_deaths/population))*100 percentpopulationdiedofcovid
from CovidDeaths
where continent is not null
group by location, population
order by 3 desc

--Let's break things down by continent
--showing the continent with highest death count per population
select continent, max(total_deaths) HighestDeaths, max((total_deaths/population)) * 100 as percentpopulationdiedofcovid
from CovidDeaths
where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 
as DeathPercentage
from CovidDeaths
Where continent is not null
--group by date
order by 1, 2

select * from CovidVaccinations

--Looking at the total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as float)) over
(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths DEA
join
CovidVaccinations VAC
on DEA.LOCATION = VAC.LOCATION 
AND DEA.DATE = VAC.DATE
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (Continent, location, date, Population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as float)) over
(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths DEA
join
CovidVaccinations VAC
on DEA.LOCATION = VAC.LOCATION 
AND DEA.DATE = VAC.DATE
where dea.continent is not null
--order by 2,3 
)

Select *,rollingpeoplevaccinated/Population *100 as percentpopulationvaccinated
from PopvsVac

--WITH A TEMP TABLE

drop table if exists #Percentpopulationvaccinated
create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as float)) over
(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths DEA
join
CovidVaccinations VAC
on DEA.LOCATION = VAC.LOCATION 
AND DEA.DATE = VAC.DATE
--where dea.continent is not null
--order by 2,3 

Select *,rollingpeoplevaccinated/Population *100 as percentpopulationvaccinated
from #Percentpopulationvaccinated

-- Creating view to store data for later visualisations

Create View Percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as float)) over
(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths DEA
join
CovidVaccinations VAC
on DEA.LOCATION = VAC.LOCATION 
AND DEA.DATE = VAC.DATE
where dea.continent is not null
--order by 2,3 

select *, (rollingpeoplevaccinated/population) *100 percentpopulationvaccinated from Percentpopulationvaccinated