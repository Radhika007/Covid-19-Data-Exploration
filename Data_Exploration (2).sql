use CovidDB;
Select * from CovidDeaths where continent is not null order by 3,4;

-- selecting data to start with
Select Location, date, total_cases, new_cases, total_deaths, population from CovidDeaths
where continent is not null order by 1,2 ;

-- Total deaths vs Total Cases
--Likelyhood of dying in the United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths where Location like '%state%' and continent is not null order by 1,2;

-- What percentage of population affected by covid in US
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths where Location like '%state%' order by 1,2;

-- What percentage of population affected by covid in India
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulation from CovidDeaths
where location = 'India' order by 1,2;

--Countries with highest infection rate
Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected from CovidDeaths
where location like '%state%' group by 
Location, population order by PercentPopulationInfected desc;

-- Countries with highest death count per population
Select distinct Location, max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths
where continent is not null group by location order by TotalDeathCount desc;

-- Continents with highest death count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths
where continent is not null group by continent order by TotalDeathCount desc;

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, cast((sum(cast(new_deaths as int))/sum(new_cases))*100.0 as float) as DeathPercentage
from CovidDeaths where continent is not null group by date order by 1,2 ;

-- Covid Vaccinations table
Select top 10 * from CovidVaccinations;

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int,v.new_vaccinations)) over 
(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated from CovidDeaths d join CovidVaccinations v
on d.location = v.location and d.date = v.date where d.continent is not null order by 2,3;

with CTE as (
    Select d.location, d.date, d.population, v.new_vaccinations_smoothed from CovidDeaths d join CovidVaccinations v ON
    d.location = v.location and d.date=v.date where v.new_vaccinations_smoothed is not null
)
Select * from CTE;

alter table CovidVaccinations alter column new_vaccinations_smoothed int;

-- Average of new_vaccinations smoothed in all countries
Select avg(v.new_vaccinations_smoothed) over (partition by d.location order by d.date) as avg_new_vacc_smoothed, d.location, d.date from
CovidDeaths d join CovidVaccinations v on d.location = v.location and d.date = v.date where d.continent is not null and v.new_vaccinations_smoothed is not null;