select * from [dbo].[CovidDeaths$]
group by date
order by 4

select * from [dbo].[CovidVaccinations$]
order by 3,4

--select location,date,total_cases,new_cases,total_deaths,population from [dbo].[CovidDeaths$]

--Shows likelihood of death from covid 
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as death_perct from [dbo].[CovidDeaths$]
--where location like 'India'
order by 2

--Looking at total cases vs population
select location,date,total_cases,new_cases,population,cast((total_cases/population)*100 as int) as positive_perct from [dbo].[CovidDeaths$]
--where location like 'India'
order by 2

--Looking at countries with highest infection rate compared to their population
select location,population,max(total_cases) as maximum_cases,max(total_cases/population)*100 as max_positive_perct from [dbo].[CovidDeaths$]
where continent is not null
group by location,population
order by 1 asc

--Looking at countries with highest death count
select location,max(cast(total_deaths as int)) as max_deaths from [dbo].[CovidDeaths$]
where continent is not null
group by location
order by 2 desc

--Looking at continents with highest death count
select location,max(cast(total_deaths as int)) as max_deaths from [dbo].[CovidDeaths$]
where continent is null
group by location
order by 2 desc

--Creating a view for continent stats
create view Continent_deaths as
select location,max(cast(total_deaths as int)) as max_deaths from [dbo].[CovidDeaths$]
where continent is null
group by location


--Looking at Global numbers grouped by date 
select date,sum(cast(new_cases as int)) as Cases,sum(cast(new_deaths as int)) as Deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 
from [dbo].[CovidDeaths$]
where continent is not null
group by date
order by 1

--Looking at a total figure for the whole world till the end of the data ie. 30/04/2021
select sum(cast(new_cases as int)) as Cases,sum(cast(new_deaths as int)) as Deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from [dbo].[CovidDeaths$]
where continent is not null
order by 1

--Looking at a total figure for INDIA till the end of the data ie. 30/04/2021
select sum(cast(new_cases as int)) as Cases,sum(cast(new_deaths as int)) as Deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from [dbo].[CovidDeaths$]
where location like 'India'
order by 1


------------------------------------
--Joining Covid death and vaccination tables 
select * from [dbo].[CovidDeaths$] covD join [dbo].[CovidVaccinations$] covV on covD.location = covV.location and covD.date = covV.date

--Calculating population vs vaccinated people or per day basis
select covd.continent,covd.location,covd.date,covd.population,
covv.total_vaccinations,covv.new_vaccinations,
sum(cast(covV.new_vaccinations as int)) over (partition by covv.location order by covd.location,covd.date) as total_vacciness_administered
from [dbo].[CovidDeaths$] covD join [dbo].[CovidVaccinations$] covV 
on covD.location = covV.location and covD.date = covV.date
where covd.continent is not null 
order by 2,3

--Calculating population vs vaccinated people or per day basis IN INDIA 
select covd.continent,covd.location,covd.date,covd.population,
covv.total_vaccinations,covv.new_vaccinations,
sum(cast(covV.new_vaccinations as int)) over (partition by covv.location order by covd.location,covd.date) as total_vacciness_administered
from [dbo].[CovidDeaths$] covD join [dbo].[CovidVaccinations$] covV 
on covD.location = covV.location and covD.date = covV.date
where covd.continent is not null and covd.location like 'India'
order by 2,3

--Calculating Rolling vaccinated population percentage per day basis
select covd.continent,covd.location,covd.date,covd.population,
covv.total_vaccinations,covv.new_vaccinations,
sum(cast(covV.new_vaccinations as int)) over (partition by covv.location order by covd.location,covd.date) as total_vacciness_administered,
(covv.total_vaccinations/covd.population)*100 as RollingVaccPercentage
from [dbo].[CovidDeaths$] covD join [dbo].[CovidVaccinations$] covV 
on covD.location = covV.location and covD.date = covV.date
where covd.continent is not null
order by 2,3


--Making a CTE for further calculations
with VacVSPop as (
select covd.continent,covd.location,covd.date,covd.population,
covv.total_vaccinations,covv.new_vaccinations,
sum(cast(covV.new_vaccinations as int)) over (partition by covv.location order by covd.location,covd.date) as total_vacciness_administered,
(covv.total_vaccinations/covd.population)*100 as RollingVaccPercentage
from [dbo].[CovidDeaths$] covD join [dbo].[CovidVaccinations$] covV 
on covD.location = covV.location and covD.date = covV.date
where covd.continent is not null
)
select date,population,RollingVaccPercentage,total_vaccinations/population as rollcheck from VacVSPop

--Making a temp table of the same data in above query

--drop table #VacVSPop
create table #VacVSPop (
continent nvarchar(50),location nvarchar(50),date datetime,population int,total_vaccinations numeric,
new_vaccinations numeric,total_vaccinations_adm numeric,rolling_vacc numeric)

insert into #VacVSPop 
select covd.continent,covd.location,covd.date,covd.population,
covv.total_vaccinations,covv.new_vaccinations,
sum(cast(covV.new_vaccinations as int)) over (partition by covv.location order by covd.location,covd.date) as total_vacciness_administered,
(covv.total_vaccinations/covd.population)*100 as RollingVaccPercentage
from [dbo].[CovidDeaths$] covD join [dbo].[CovidVaccinations$] covV 
on covD.location = covV.location and covD.date = covV.date
where covd.continent is not null

select * from #VacVSPop
where location like 'Canada'

--Creating another view for sharing data with other members of the team

create view VaccinesVsPopulation as 
select covd.continent,covd.location,covd.date,covd.population,
covv.total_vaccinations,covv.new_vaccinations,
sum(cast(covV.new_vaccinations as int)) over (partition by covv.location order by covd.location,covd.date) as total_vacciness_administered,
(covv.total_vaccinations/covd.population)*100 as RollingVaccPercentage
from [dbo].[CovidDeaths$] covD join [dbo].[CovidVaccinations$] covV 
on covD.location = covV.location and covD.date = covV.date
where covd.continent is not null


