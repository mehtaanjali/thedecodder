select *
from covid_eda.coviddeaths
where continent is not null
order by 3,4;

/* select*
from covid_eda.covidvaccinations
order by 3,4 */

/* selecting the data to be used*/
select location, date, total_cases, new_cases,total_deaths, population
from covid_eda.coviddeaths
where continent is not null
order by 1,2;

/*seeing total cases vs total deaths*/
-- gives likelihood of dying og covid in india
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_eda.coviddeaths
where location like'%india'
order by 1,2;

-- total cases vs population
-- percentage of population that got covid
select location, date, population,total_cases, (total_cases/population)*100 as percentage_population_infected
from covid_eda.coviddeaths
-- where location like'%india'
where continent is not null
order by 1,2;

-- looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as percentage_population_infected
from covid_eda.coviddeaths
-- where location like'%india'
where continent is not null
group by location, population
order by percentage_population_infected desc;

-- countries with highest death count per population
select location, max(total_deaths) as total_death_count
from covid_eda.coviddeaths
-- where location like'%india'
where continent is not null     -- imp: just to make it visually appealing, added to every script so that i dont get the data of a continent as whole which is there in my original dataset
group by location
order by total_death_count desc;


-- seeing by continent
/*select location, max(total_deaths) as total_death_count
from covid_eda.coviddeaths
-- where location like'%india'
where continent is null     
group by location
order by total_death_count desc*/    -- a way to write 

-- by continent 
select continent, max(total_deaths) as total_death_count
from covid_eda.coviddeaths
-- where location like'%india'
where continent is not null     
group by continent
order by total_death_count desc;

-- continents with highest death count per population
select continent , max(total_deaths) as total_death_count
from covid_eda.coviddeaths
where continent is not null
group by continent 
order by total_death_count desc;

-- seeing from global perspective
select  date, sum(new_cases) as total_cases, sum(new_deaths ) as total_deaths, sum(new_deaths)/sum(new_cases) *100 as death_percentage
from covid_eda.coviddeaths
-- where location like'%india'
where continent is not null
group by date
order by 1,2;

/*-- seeing for total in world only 3 nos. will show as o/p 
select  sum(new_cases) as total_cases, sum(new_deaths ) as total_deaths, sum(new_deaths)/sum(new_cases) *100 as death_percentage
from covid_eda.coviddeaths
-- where location like'%india'
where continent is not null
group by date
order by 1,2;
*/


/*seeing vaccination table*/
select * 
from covid_eda.covidvaccinations;

-- joing tables
-- and lokking at total population vs vaccines
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated   -- sums new vacc to the rolling one
-- (rolling_people_vaccinated/population)*100  -- this shows error as cant use the column that is just created above hence using cte 
from covid_eda.coviddeaths as dea
join covid_eda.covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- use CTE for calculation on partition by (common table expression , serve as temporary table within sql, efficient way to reference data or manipulate it from original table 
with pop_vs_vac (continent, location, date, population, new_vaccinations,rolling_people_vaccinated)  -- num of cols in cte should be equal to that in below, else error
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated   -- sums new vacc to the rolling one
from covid_eda.coviddeaths as dea
join covid_eda.covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3  this cant be used
)
select*,(rolling_people_vaccinated/population)*100 as percent
from pop_vs_vac;


-- temp table(same thing diff method)
drop table if exists percent_population_vaccinated;
create table percent_population_vaccinated
(
continent varchar(255),
location varchar(255),
date text,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
;
insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated   -- sums new vacc to the rolling one
from covid_eda.coviddeaths as dea
join covid_eda.covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3
;
select *, (rolling_people_vaccinated/population)*100
from percent_population_vaccinated
;


-- creating view to store data for visualization
drop view if exists percent_population_vaccinated;  -- if not written then error 1050
create view percent_population_vaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated   -- sums new vacc to the rolling one
from covid_eda.coviddeaths as dea
join covid_eda.covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select * 
from percent_population_vaccinated


