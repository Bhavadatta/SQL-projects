
---Selecting all attributes from coviddeaths table
SELECT*
FROM [DBO].COvidDeaths$


---Selecting all attributes form covidvacinations table
SELECT*
FROM [DBO].COvidvaccinations$



--Looking at Total Number of Cases VS Total number of deaths
---Shows likelihood of dying if in contact with Covid-19 in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'percentage of deaths'
FROM [DBO].COvidDeaths$
where location='india'
order by 1,2 




--Looking at Total Cases VS Population and Total Number of deaths VS Population
---Shows what percentage of population got covid and also died in your country
Select location,date,(total_cases),total_deaths,population,(total_cases/population)*100 as 'percentage of population infected',(total_deaths/population)*100 as 'percentage of population died'
from [CovidDeaths$]
where location='canada'
order by 1,2


---Looking at Highest Infetcion rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

---Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
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
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



