
Select * 
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4

--Select Data 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs. Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Total Cases vs. Population... % pop. = COVID
Select Location, date, total_cases, Population, (total_cases/population)*100 as CovidPositive
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2



-- Countries w/ highest Infection Rate vs. Pop.
Select Location, Population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- Countries w/ highest Death Count per Pop.
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Continental breakdown analysis
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Cases
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Pop. vs. Vac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingAmtVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingAmtVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingAmtVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingAmtVaccinated/Population)*100 
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingAmtVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingAmtVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * , (RollingAmtVaccinated/Population)*100 as PercentPopVaccinated 
From #PercentPopulationVaccinated


-- Creating View for Visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingAmtVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- View Test

Select *
From PercentPopulationVaccinated