select * from CovidVaccinations
select * from CovidDeaths

-- Looking at total cases vs total deaths

select location, count(location) AS country_appear,total_cases,total_deaths,population from CovidDeaths
Group by location,total_cases,total_deaths,population
order by 1,2

select location, count(location) AS country_appear, sum(total_cases) as Total_cases, AVG (population) AS avg_population, total_deaths
from CovidDeaths
Group by location, total_deaths


select location, sum(total_cases) as total_cases_asofnow from CovidDeaths
group by location
having sum(total_cases) is null 
order by 1

select location, COUNT(location) as loc_appeared, total_cases from CovidDeaths 
where total_cases is null 
group by location, total_cases




-- Looking at total cases vs total deaths (percentage of death)

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
from CovidDeaths
where continent is not null

-- Looking at total cases vs Population (percentage of covid affected)

select location, date, population, total_cases,  CAST((total_cases/population)*100 AS DECIMAL(10,8)) AS affected_percentage
from CovidDeaths
where continent is not null

-- Looking at the highest infection rate coutrywise

select location, population, MAX(total_cases) AS maximum_infected,  MAX(CAST((total_cases/population)*100 AS DECIMAL(10,8))) AS affected_percentage
from CovidDeaths
where continent is not null
Group by location, population
order by affected_percentage

-- Looking for highest death count countries per population

select location, population, MAX(cast(total_deaths as int)) AS maximum_death,  MAX(CAST((cast(total_deaths as int)/population)*100 AS DECIMAL(10,8))) AS death_percentage
from CovidDeaths
where continent is not null
Group by location, population
order by death_percentage DESC

-- Looking for death percentage (continent-wise)

select	continent, 
		sum(cast(total_deaths as int)) as total_no_of_death, 
		sum(population) as total_population, 
		(sum(cast(total_deaths as int))/sum(population))*100 AS percentage_of_death  
from CovidDeaths
where NOT (total_deaths is NULL OR continent is NULL OR population is NULL) 
group by continent
order by percentage_of_death

-- Looking for death percentages per day accros the world

select	date, 
		SUM(cast(total_deaths as int)) AS total_no_of_death, 
		sum (total_cases) AS total_no_of_cases,
		(SUM(cast(total_deaths as int))/sum (total_cases))*100 AS death_percentage
from CovidDeaths
Group by date
order by death_percentage DESC

-- Looking for earliest date of vaccination in each country

select location, date, population, total_vaccinations from CovidVaccinations
where NOT (total_vaccinations is null or continent is null) 
order by location, date


-- Looking for new vaccinations per day, in every country accros the world

select	location, 
		date, 
		population, 
		new_vaccinations,
		sum(cast(new_vaccinations as int)) over (partition by location order by location, date) AS Total_vac_asof_that_day
from CovidVaccinations 
where continent is not null
order by location, date


-- Creating a view table

create view PercentagePopulationVaccinated as 
select	location, 
		date, 
		population, 
		new_vaccinations,
		sum(cast(new_vaccinations as int)) over (partition by location order by location, date) AS Total_vac_asof_that_day
from CovidVaccinations 
where continent is not null

-- Looking for new vaccinations percentage per day, in every country accros the world

select *,(Total_vac_asof_that_day/population)*100 AS PercentagePopuVaccinated 
from PercentagePopulationVaccinated
order by location

