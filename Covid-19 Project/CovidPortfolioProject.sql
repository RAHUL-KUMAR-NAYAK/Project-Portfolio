--Deaths Table
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4;

--Vaccinations Table
Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
Order by 3, 4



Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

-- Total Cases vs Total Deaths
--Death Rate : (total_deaths/total_cases) * 100			#Shows the likelihood of dying if you contract Covid in India
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
and continent is not null
Order by 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, total_cases, population, (total_cases/population) * 100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
and continent is not null
Order by 1, 2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfected, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'India'
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- (Accurate) Showing contintents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

-- (Inaccurate) Showing contintents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

-- New cases, fatalities and death percentage recorded on each respective date
Select date, SUM(new_cases) as DailyCases, SUM(new_deaths) as FatalityRecord, ISNULL(SUM(new_deaths)/SUM(NULLIF(new_cases, 0)), 0) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2

-- New cases, fatalities and death percentage recorded globally
Select SUM(new_cases) as DailyCases, SUM(new_deaths) as FatalityRecord, ISNULL(SUM(new_deaths)/SUM(NULLIF(new_cases, 0)), 0) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null


-- Total Population VS Vaccinations 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location) as CummulativeVaccinations
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null and new_vaccinations is not null
Order by 2, 3


-- Using CTE to perform calculations on the Partition By
With PopVsVacc (continent, location, date, population, new_vaccinations, CummulativeVaccinations)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location) as CummulativeVaccinations
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null 
)
Select *, (CummulativeVaccinations/population)*100 as PopVaccPercentage
From PopVsVacc


-- Using Temp Table to perform Calculation on Partition By

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CummulativeVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location) as CummulativeVaccinations
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null and new_vaccinations is not null

Select *, (CummulativeVaccinations/population)*100 as PopVaccPercentage
From #PercentPopulationVaccinated