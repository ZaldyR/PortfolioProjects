select * 
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

select Location, date,population, total_cases, (total_cases/population) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null


-- Looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where continent is not null
group by location, population
--Where location like '%states%'
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is  not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Death,
 sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%' 
WHERE continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
, 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
   dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
order by 2,3



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
   dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3


---- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
   dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated