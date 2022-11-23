SELECT * 
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
ORDER BY 3,4 ; 

--SELECT *  
--FROM `portfolio-project-1-369518.covid_info_ds.covid_vacc_info`
--ORDER BY 3,4 ; 

-- Select the data that we are going to be using 

SELECT location,date,total_cases, new_cases,total_deaths, population 
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
ORDER BY 1,2; # sorted by location and date 


--looking at Total cases and Total deaths in India 
--Likelihood of death if you contract covid in India 

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_Percentage
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
WHERE location= 'India'
ORDER BY 1,2; 

--Looking at Total cases and Population 

SELECT location,date,population,total_cases, (total_cases/population)*100 AS infection_rate
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
WHERE location= 'India'
ORDER BY 1,2; 

--Looking at countries with highest infection rate 
SELECT location,MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100 ) as highest_percentage_infected
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
GROUP BY location, population
ORDER BY highest_percentage_infected DESC;

-- Looking at countries with highest death rate percentage 
SELECT location, MAX(cast(total_deaths as int))  as max_deaths, MAX((total_deaths/population)*100) as highest_death_per
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
GROUP BY location
ORDER BY max_deaths DESC;

--Removing the data for the groups like the name of the continents  
SELECT location, MAX(cast(total_deaths as int))  as max_deaths, MAX((total_deaths/population)*100) as highest_death_per
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
WHERE continent is not null
GROUP BY location
ORDER BY max_deaths DESC;

--Looking at data for continents
--showing continents with highest death rate 

SELECT continent, MAX(cast(total_deaths as int))  as max_deaths
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
WHERE continent is not null
GROUP BY continent
ORDER BY max_deaths DESC; 

-- GLOBAL NUMBERS 
SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_death, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS death_perc
--new_deaths were float so couldnt sum, cast it to int  
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
WHERE continent is not null
GROUP BY date 
ORDER BY  1,2 ;

--Total in the world until today (Nov 23 2022)
SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_death, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS death_perc
--new_deaths were float so couldnt sum, cast it to int  
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info`
WHERE continent is not null
--GROUP BY date 
ORDER BY  1,2 ;

----JOIN VACCINE DATA 
-- Looking for population that is vaccinated 
SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info` dea 
JOIN `portfolio-project-1-369518.covid_info_ds.covid_vacc_info` vac 
  ON dea.location = vac.location  
  AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;   

SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_ppl_vacc-- convert(int,vac.new_vaccination) also works 
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info` dea 
JOIN `portfolio-project-1-369518.covid_info_ds.covid_vacc_info` vac 
  ON dea.location = vac.location  
  AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;   


--Using CTE 
WITH Pop_vac 
--(Continent, Location, Date, Population, New_Vaccinations, Rolling_ppl_Vacc)
AS 
( 
  SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_ppl_vacc-- convert(int,vac.new_vaccination) also works 
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info` dea 
JOIN `portfolio-project-1-369518.covid_info_ds.covid_vacc_info` vac 
  ON dea.location = vac.location  
  AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)

SELECT * , (rolling_ppl_vacc/population)*100 
FROM Pop_vac;


-- USING CREATE TABLE 
CREATE or REPLACE TEMP TABLE  portfolio-project-1-369518.covid_info_ds.PercentagePopulation_Vaccinated (Continent STRING,
Location STRING,
Date datetime,
Population numeric, 
New_vaccinations numeric, 
Rolling_ppl_vacc numeric
);
INSERT INTO  portfolio-project-1-369518.covid_info_ds.PercentagePopulation_Vaccinated
(SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_ppl_vacc-- convert(int,vac.new_vaccination) also works 
FROM `portfolio-project-1-369518.covid_info_ds.covid_deat_info` dea 
JOIN `portfolio-project-1-369518.covid_info_ds.covid_vacc_info` vac 
  ON dea.location = vac.location  
  AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
);
SELECT * , (rolling_ppl_vacc/population)*100 
FROM `portfolio-project-1-369518.covid_info_ds.PercentagePopulation_Vaccinated`; 


SELECT * 
FROM `portfolio-project-1-369518.covid_info_ds.PercentagePopulation_Vaccinated`






