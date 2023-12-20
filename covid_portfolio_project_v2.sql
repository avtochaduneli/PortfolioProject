select * from 
PortfolioProject..CovidDeaths
order by 3,4

--select * from 
--PortfolioProject..CovidDeaths
--order by 3,4

--select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--shows likelyhood of dying if you contract covid in your country
exec sp_help 'dbo.CovidDeaths';
alter table dbo.CovidDeaths
alter column total_deaths float

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at total_cases vs population
--shows what percentage of population got covid

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highet infection rate compared to population

select location,max(total_cases) as HighestInfectionCount,population,Max((total_cases)/(population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths

--where location like '%states%'

group by location, population 
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

select location,max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location

--Lets break things down by continent

select Continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continent with highest death count per population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases),sum(new_deaths),sum(new_deaths)/sum(new_cases)*100--total_cases,total_deaths,(total_deaths/total_cases)* 100
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations
set ANSI_WARNINGS OFF
exec sp_help '[dbo].[CovidVacccinations]';
alter table dbo.CovidVacccinations
alter column new_vaccinations Float

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --USE CTE

 with PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)

 as (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *,(RollingPeopleVaccinated/population)*100 from PopVsVac

 --Temp Table
 drop table if exists #PercentPopulationVaccinated
 create Table #PercentPopulationVaccinated
 (continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  insert into #PercentPopulationVaccinated
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3
 
 select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated

 --creating view to store data for later visualization
 create view PercentPopulationVaccinated as 
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 