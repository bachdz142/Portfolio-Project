select *
from [Portfolio project]..CovidDeaths
order by 3, 4

-- Select Data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- likeihood of dying if you contract covid in your country


select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2, 0) as 'Percent'
from [Portfolio project]..CovidDeaths
where location like '%vietnam%'
order by 1,2 

-- Show what percent of population got covid

select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as 'Percent'
from [Portfolio project]..CovidDeaths
where location like '%vietnam%'
order by 1,2

-- Looking at country with hightest infection rate compare to population
select location, population, Max(total_cases) as HighestInfectCount, Max((total_cases/population)*100) as 'MaxPercent'
from [Portfolio project]..CovidDeaths
--where location like '%vietnam%'
group by location, population
order by 4 desc


-- Break things down by continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where continent is not  null
group by continent


-- Show Countries with highest Death Count per Population
select location, population, Max(cast(total_deaths as int)) as HighestDeathCount, Max((total_cases/population)*100) as 'MaxPercent'
from [Portfolio project]..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- Show continent with highest deathcount
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where continent is not  null
group by continent  
order by TotalDeathCount desc


-- Global numbers

select date
, Sum(new_cases) as 'total cases'
, sum(cast(new_deaths as int)) 'total deth'
, sum(cast(new_deaths as int))/sum(new_cases)*100 'Death Percentage' --, round((total_deaths/total_cases)*100, 2, 0) as 'Percent'
from [Portfolio project]..CovidDeaths
where continent is not null
group by date
order by 1, 2
-- Looking at Total Population and Vaccinations
-- Use CTE
With PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
	Select 
	dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations
	, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
	from [Portfolio project]..CovidVaccinations as vac
	join [Portfolio project]..CovidDeaths as dea 
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null -- Trong CTE khong duoc Order By
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulatedVaccinated  -- always include this line if run multiple time
Create Table #PercentPopulatedVaccinated
(
	Continent nvarchar(255) 
	, Location nvarchar(255)
	, Date datetime	
	, Population numeric
	, New_vaccination numeric
	, RollingPeopleVaccinated numeric
)
Insert into #PercentPopulatedVaccinated
Select 
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location) as RollingPeopleVaccinated
from [Portfolio project]..CovidVaccinations as vac
join [Portfolio project]..CovidDeaths as dea 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null -- Trong CTE khong duoc Order By

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulatedVaccinated

--Create virew to store data for later

Create View PercentPopulationVaccinated as
Select 
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidVaccinations as vac
join [Portfolio project]..CovidDeaths as dea 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



USE [Portfolio project]  -- Use this line to specify database
Go
Create View Globalstat as
select date
, Sum(new_cases) as 'total cases'
, sum(cast(new_deaths as int)) 'total deth'
, sum(cast(new_deaths as int))/sum(new_cases)*100 'Death Percentage' --, round((total_deaths/total_cases)*100, 2, 0) as 'Percent'
from [Portfolio project]..CovidDeaths
where continent is not null
group by date
