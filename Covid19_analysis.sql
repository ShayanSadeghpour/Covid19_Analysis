select * 
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from [Portfolio Project]..['CovidVaccinations $']
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Project]..CovidDeaths$
order by 1,2


--Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeaths$
where location like '%states%'
order by 1,2


--shows what percentage of population got covid
select location, date, population,total_cases, (total_cases/population)*100 as PositiveCovidPercentage 
from [Portfolio Project]..CovidDeaths$
where location like '%canada%'
order by 1,2

--looking at countries with highest infection rate compare to population
select location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PositiveCovidPercentage 
from [Portfolio Project]..CovidDeaths$
Group by location, population
order by 4 desc

--shows the countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by location 
order by 2 desc


--break things down by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by continent
order by 2 desc


--Global Numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--looking at total population vs Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(convert(int, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..['CovidVaccinations $'] vacc
ON dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null            
order by 2, 3





-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 