# COVID-19 Data Analysis Project

## Overview

This project analyzes COVID-19 data using SQL queries to provide insights into various metrics such as infection rates, death rates, and vaccination progress across different countries. The data is stored in two tables: `CovidDeaths$` and `CovidVaccinations$`. The project aims to extract meaningful statistics and trends from these datasets.

## Data Sources

- **CovidDeaths$**: Contains data related to COVID-19 cases and deaths.
- **CovidVaccinations$**: Contains data related to COVID-19 vaccinations.

## SQL Queries and Analyses

### 1. Selecting All Attributes from the Tables
```sql
SELECT * FROM [DBO].CovidDeaths$;
SELECT * FROM [DBO].CovidVaccinations$;
```
These queries retrieve all columns from the respective tables.

### 2. Total Number of Cases vs. Total Number of Deaths
```sql
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS 'percentage of deaths'
FROM [DBO].CovidDeaths$
WHERE location = 'india'
ORDER BY 1, 2;
```
This query calculates the percentage of deaths relative to total cases in India.

### 3. Total Cases vs. Population and Total Number of Deaths vs. Population
```sql
SELECT location, date, total_cases, total_deaths, population,
  (total_cases / population) * 100 AS 'percentage of population infected',
  (total_deaths / population) * 100 AS 'percentage of population died'
FROM [DBO].CovidDeaths$
WHERE location = 'canada'
ORDER BY 1, 2;
```
This query calculates the percentage of the population infected and the percentage of the population that died in Canada.

### 4. Highest Infection Rate Compared to Population
```sql
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,
  MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;
```
This query identifies countries with the highest infection rates relative to their populations.

### 5. Countries with Highest Death Count per Population
```sql
SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;
```
This query finds countries with the highest death counts.

### 6. Total Population vs. Vaccinations
```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;
```
This query calculates the rolling number of people vaccinated per location and date.

### 7. Using CTE for Population vs. Vaccinations Calculation
```sql
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
  FROM CovidDeaths$ dea
  JOIN CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM PopvsVac;
```
This query uses a Common Table Expression (CTE) to simplify the calculation of the rolling number of people vaccinated and their percentage of the population.

### 8. Using Temporary Table for Population vs. Vaccinations Calculation
```sql
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated (
  Continent NVARCHAR(255),
  Location NVARCHAR(255),
  Date DATETIME,
  Population NUMERIC,
  New_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated;
```
This query uses a temporary table to perform similar calculations as in the previous CTE query.

## Conclusion

This project provides a comprehensive analysis of COVID-19 data, including infection rates, death rates, and vaccination progress. The SQL queries used offer insights into the impact of COVID-19 on different countries and their responses in terms of vaccinations. The analysis can help in understanding the pandemic's progression and the effectiveness of measures taken to combat it.

## How to Use

1. **Clone the Repository**: 
   ```sh
   git clone <repository-url>
   ```

2. **Set Up the Database**:
   Ensure you have a SQL Server instance running and import the `CovidDeaths$` and `CovidVaccinations$` tables into your database.

3. **Run the Queries**:
   Execute the SQL queries provided in the `queries.sql` file to perform the analysis.

4. **Analyze the Results**:
   Review the output of the queries to gain insights into the COVID-19 data.

## Contributions

Feel free to contribute to this project by submitting issues or pull requests. All contributions are welcome!

