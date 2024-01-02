--The Death percentage of patient who got got infected in Covid

select Location Country,population, max(total_cases) Total_Cases,max(total_deaths) Total_Deaths,(max(total_deaths)/max(total_cases))*100 death_percentage
from [project].[dbo].[covid death]
where continent is not null
group by location,population
order by 1

-- We can also use Max(population), but it will not make any differnce, since all the population number is same
--but if the population number is different and we need to calculate the late data with increase in population the following query  can be executed
-- a not null feature is used to eliminate the overall continent data
--select location,max(population) Population, max(total_cases) Total_Cases,max(total_deaths) Total_Deaths,(max(total_deaths)/max(total_cases))*100 death_percentage
--from [project].[dbo].[covid death]
--where continent is not null
--group by location
--order by 1



-- The Infected percentage of patient shows the probability of getting infected if we live in a certain country

select Location Country,Population, max(total_cases) Total_Cases,(max(total_cases)/max(population))*100 Infected_percentage
from [project].[dbo].[covid death]
where continent is not null and population>1000000
group by location,population
having max(total_cases/population)*100 > 1
order by 4 desc

--we are neglecting the countries which has the Infected percentage of less than 1, because it's conspicious that Covid had an deterimental effect on all across the globe,
--a meager percetange picturizes the fact that the country didn't made adequate tests, and also we are excluding the small countries, which has a population of less than 1M.




-- Lets look the Continent wise deaths,cases etc.,

select location Continent,population Population_of_the_Continent,max(total_cases) Total_cases,max(total_deaths) Total_Deaths,(max(total_cases)/max(population))*100 Infected_percentage,(max(total_deaths)/max(total_cases))*100 death_percentage
from [project].[dbo].[covid death]
where continent is null and location in ('asia','africa','europe','north america','south america','oceania','world')
group by location,population
order by 2 desc

-- There is not any need to use 'is null' function in here since we are including everthing that we needed in location. But I thought it will simply eliminate the countries and will show only the continent, but in the data set, it's also included 
--'upper income','lower income and many other sub categories. but if we're precisely using location then there is no need to use null function




-- Total number of people Vaccinated 

select cd.location Country,cd.population,max(cv.total_vaccinations) Total_Vaccination
from project..[covid death] cd
join project..covidvaccination cv
   on cd.location=cv.location 
   where total_vaccinations is not null and cv.continent is not null
group by cd.location,cd.population
order by  3
--In some cases, the total vaccination is higher than the population of the country. It's what out there in the DATA. I'm assuming, the WHO counts the number of vaccines shots which cludes 2 doses or 3 doses to one person.
-- The total_vaccination are not in the order that we wanted it to be, its because total-vaccination column might not be in int data type. We'll check using the following command


exec sp_help covidvaccination;
-- As you can see that the total-vaccnation column is in nvarchar data type, we need to convert it to int, since one of the other value in the column exceeds the range of  -2,147,483,648 to 2,147,483,647 we cannot convert the column to int
-- So we should convert the column to bigint type.

alter table covidvaccination
alter column total_vaccinations bigint

-- if you execute the command, Table will be ordered based on the total vaccination.

-- Using CTE

with Percentage_people_vaccinated  (Country,population,Total_vaccination,Vaccinated_percent)
as
(
select cd.location Country,cd.population,max(cv.total_vaccinations) Total_Vaccination,(max(cv.total_vaccinations)/max(population))*100 Vaccinated_percent
from project..[covid death] cd
join project..covidvaccination cv
   on cd.location=cv.location 
   where total_vaccinations is not null and cv.continent is not null
group by cd.location,cd.population
--order by  3
)
select *
from percentage_people_vaccinated



--Using a temp table for percentage of died continent wise

drop table if exists #testtemp
create table #testtemp
(
Continent nvarchar(255),
Population numeric,
Total_Deaths numeric,
Percentage_of_people_died float)

insert into #testtemp
select location continent,population,max(total_deaths) Total_deaths,(max(total_deaths)/cast(max(population) as numeric))*100 Percentage_people_died
from [covid death]
where location in ('Asia','africa','Europe','oceania') or location like '%%%america'
group by location,population

select *
from #testtemp




