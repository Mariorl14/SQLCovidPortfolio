select * from SQLPorfolio..Deaths$ where continent = 'North America';
select * from SQLPorfolio..Vaccinations$ where continent = 'North America' ;
--Data to be used

select location, date, total_cases, new_cases, total_deaths, population 
from SQLPorfolio..Deaths$
order by 1,2;

-- Total cases vs total deaths

select location, date, total_cases, total_deaths, concat((round((total_deaths/NULLIF(total_cases, 0)),2)*100),'%') as 'Death %'
from SQLPorfolio..Deaths$
order by 1,2;


-- Total cases VS Popultation
-- % population with covid
select location, date, total_cases, population, concat((round((total_cases/NULLIF(population, 0)),2)*100),'%') as 'Cases % Country'
from SQLPorfolio..Deaths$
--where location LIKE '%states%'
order by 1,2;


-- Highest Infection rate in each population by country

select location,population, MAX(total_cases) AS 'Highest Amount Cases', max((round((total_cases/NULLIF(population, 0)),2)*100)) as '% Population Infected'
from SQLPorfolio..Deaths$
group by location, population
order by 4 DESC;

-- % death by country

--Replace balnk spaces with nulls 
--update SQLPorfolio..Deaths$ set continent = null
--where continent = '';

--% death by country
select location,population, MAX(cast(total_deaths as int)) AS 'Highest Amount deaths', max((round((total_deaths/NULLIF(population, 0)),2)*100)) as '% Population Death'
from SQLPorfolio..Deaths$
where continent is not null
group by location, population
order by 4 DESC;

-- Total by country
select location, MAX(cast(total_deaths as int)) AS 'Highest Amount deaths'
from SQLPorfolio..Deaths$
where continent is not null
group by location
order by 2 DESC;

------------------------- Continents -----------------

-- Contintents with the highest death count 

select continent, MAX(cast(total_deaths as int)) AS 'Highest Amount deaths'
from SQLPorfolio..Deaths$
where continent is not null
group by continent
order by 2 DESC;

--Sames queries but Group by by continent


------------ GLOBAL ------------

-- % total deaths
select sum(new_cases) as 'total cases', sum(cast(new_deaths as int)) as 'total deaths',
(sum(cast(new_deaths as int))/sum(new_cases))*100 as '% total deaths'
from SQLPorfolio..Deaths$
where continent is not null 
order by 1,2;

-- day by day total deaths
select date, sum(new_cases) as 'total cases', sum(cast(new_deaths as int)) as 'total deaths'
from SQLPorfolio..Deaths$
where continent is not null 
group by date
order by 1,2;

------------------------------- JOINS with Vaccinations ---------------------- 

--update SQLPorfolio..Vaccinations$  set continent = null
--where continent = '';

select * from SQLPorfolio..Vaccinations$ ;

select * from SQLPorfolio..Deaths$ 
join SQLPorfolio..Vaccinations$ 
on SQLPorfolio..Deaths$.location = SQLPorfolio..Vaccinations$.location
and SQLPorfolio..Deaths$.date = SQLPorfolio..Vaccinations$.date;

-- Total Population vs Vaccinations per day 
select SQLPorfolio..Deaths$.continent, SQLPorfolio..Deaths$.location, SQLPorfolio..Deaths$.date, SQLPorfolio..Deaths$.population, SQLPorfolio..Vaccinations$.new_vaccinations
from SQLPorfolio..Deaths$ 
join SQLPorfolio..Vaccinations$ 
on SQLPorfolio..Deaths$.location = SQLPorfolio..Vaccinations$.location
and SQLPorfolio..Deaths$.date = SQLPorfolio..Vaccinations$.date
where SQLPorfolio..Deaths$.continent is not null
order by 2,3;

select SQLPorfolio..Deaths$.continent, SQLPorfolio..Deaths$.location, SQLPorfolio..Deaths$.date, SQLPorfolio..Deaths$.population, SQLPorfolio..Vaccinations$.new_vaccinations,
sum(cast(SQLPorfolio..Vaccinations$.new_vaccinations as int)) over (partition by SQLPorfolio..Deaths$.location order by SQLPorfolio..Deaths$.location, SQLPorfolio..Deaths$.date) as Daybyday
from SQLPorfolio..Deaths$ 
join SQLPorfolio..Vaccinations$ 
on SQLPorfolio..Deaths$.location = SQLPorfolio..Vaccinations$.location
and SQLPorfolio..Deaths$.date = SQLPorfolio..Vaccinations$.date
where SQLPorfolio..Deaths$.continent is not null
order by 2,3;


-- % of people vaccinated 
--CTE
With pop (continent, location, date, population, new_vaccinations, Daybyday)
as
(
select SQLPorfolio..Deaths$.continent, SQLPorfolio..Deaths$.location, SQLPorfolio..Deaths$.date, SQLPorfolio..Deaths$.population, SQLPorfolio..Vaccinations$.new_vaccinations,
sum(cast(SQLPorfolio..Vaccinations$.new_vaccinations as int)) over (partition by SQLPorfolio..Deaths$.location order by SQLPorfolio..Deaths$.location, SQLPorfolio..Deaths$.date) as Daybyday
from SQLPorfolio..Deaths$ 
join SQLPorfolio..Vaccinations$ 
on SQLPorfolio..Deaths$.location = SQLPorfolio..Vaccinations$.location
and SQLPorfolio..Deaths$.date = SQLPorfolio..Vaccinations$.date
where SQLPorfolio..Deaths$.continent is not null
)
select *, (Daybyday/population)*100 as '% vaccinated' from pop;



------------ Several Views ----------- 

Create view ContintentDeathCount as
select SQLPorfolio..Deaths$.continent, SQLPorfolio..Deaths$.location, SQLPorfolio..Deaths$.date, SQLPorfolio..Deaths$.population, SQLPorfolio..Vaccinations$.new_vaccinations,
sum(cast(SQLPorfolio..Vaccinations$.new_vaccinations as int)) over (partition by SQLPorfolio..Deaths$.location order by SQLPorfolio..Deaths$.location, SQLPorfolio..Deaths$.date) as Daybyday
from SQLPorfolio..Deaths$ 
join SQLPorfolio..Vaccinations$ 
on SQLPorfolio..Deaths$.location = SQLPorfolio..Vaccinations$.location
and SQLPorfolio..Deaths$.date = SQLPorfolio..Vaccinations$.date
where SQLPorfolio..Deaths$.continent is not null

Create view HighestDeathByCountry as
select location, MAX(cast(total_deaths as int)) AS 'Highest Amount deaths'
from SQLPorfolio..Deaths$
where continent is not null
group by location

create view PopulationInfectedPOR AS
select location,population, MAX(total_cases) AS 'Highest Amount Cases', max((round((total_cases/NULLIF(population, 0)),2)*100)) as '% Population Infected'
from SQLPorfolio..Deaths$
group by location, population;