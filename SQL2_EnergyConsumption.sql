
SELECT * 
FROM `portfolio-project-2-369721.Energy.energy_consumption`
ORDER BY 1;


--Identify the 10 countries where consumption per person is the highest 

SELECT Entity, Primary_energy_consumption_per_capita__kWh_person_
FROM `portfolio-project-2-369721.Energy.energy_consumption`
WHERE Year = 2021 and Code is not null 
ORDER BY Primary_energy_consumption_per_capita__kWh_person_ DESC 
LIMIT 10;

-- Per Person Energy Consumption according to Continents in 2021 


SELECT Entity, Primary_energy_consumption_per_capita__kWh_person_ as Primary_cons
FROM `portfolio-project-2-369721.Energy.energy_consumption`
WHERE Year = 2021 and Entity IN ("Africa", "North America", "South America", "Oceania","Europe", "Asia")
ORDER BY Primary_energy_consumption_per_capita__kWh_person_ DESC ;

--View Population data for 2021 

SELECT * 
FROM `portfolio-project-2-369721.Energy.population_2021`;

--Join two tables to obtain the total energy for year 2021 
CREATE or REPLACE TABLE portfolio-project-2-369721.Energy.Total_energy_consumption
(Location STRING, 
Code STRING, 
Per_person_consumption_2021 FLOAT64, 
Population_2021 numeric,
Total_consumption_2021 FLOAT64); 
INSERT INTO portfolio-project-2-369721.Energy.Total_energy_consumption
(SELECT  en.Entity, en.Code, en.Primary_energy_consumption_per_capita__kWh_person_,pop.Population_2021, pop.Population_2021*en.Primary_energy_consumption_per_capita__kWh_person_ as Total_consumption_2021
FROM `portfolio-project-2-369721.Energy.energy_consumption` en
JOIN `portfolio-project-2-369721.Energy.population_2021` pop
  ON en.Entity =  pop.location
  AND en.Year = pop.Year_
WHERE en.Code is not null and en.Entity!= "World"
); 
SELECT *, ((Total_consumption_2021)/ (SELECT SUM(Total_consumption_2021) FROM `portfolio-project-2-369721.Energy.Total_energy_consumption`))*100 as Percentage_consumption 
FROM `portfolio-project-2-369721.Energy.Total_energy_consumption`
ORDER BY 5 DESC ;

WITH Yearly_consumption AS 
(SELECT * FROM
(
  -- #1 from_item
  SELECT 
   *
  FROM `portfolio-project-2-369721.Energy.energy_consumption`
  WHERE  Entity= 'World'

)
PIVOT
(
  -- #2 aggregate
  SUM(Primary_energy_consumption_per_capita__kWh_person_) AS Yearly_consumption
  -- #3 pivot_column
  FOR Year in (1965,2021) 
))
SELECT Yearly_consumption_1965 as Total_yearly_1965, Yearly_consumption_2021 as Total_yearly_2021, 
((Yearly_consumption_2021)-(Yearly_consumption_1965)) As Increase_Consumption 
FROM Yearly_consumption;

