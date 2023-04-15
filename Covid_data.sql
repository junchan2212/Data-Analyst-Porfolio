select *
from cases_covid_data$
where continent is null
order by 3,4


-- select data to be used / Chon du lieu se su dung

Select Location, date, total_cases, new_cases, total_deaths, population
From cases_covid_data$
Where continent is not null 
order by 1,2

-- total cases vs total deaths
-- Likelihood of dying when infected in Vietnam / kha nang tu vong khi nhiem covid tai Viet Nam

Select Location, date, total_cases,total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
From cases_covid_data$
Where location like '%viet%'
and continent is not null 
order by 1,2

-- total cases vs population

Select Location, date, total_cases,total_deaths, population, cast(total_cases as float)/population*100 as InfectedRate
From cases_covid_data$
Where location like '%viet%'
and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population / Xem Ty le nhiem covid nhieu nhat theo Quoc gia

Select location, population, max(cast(total_cases as float)) AS MaxCases, max(cast(total_cases as float)/population)*100 as HighestInfectedRate
From cases_covid_data$
Where continent is not null 
Group by location, population
Order by MaxInfectedRate desc

-- Countries with Highest Death Count and Highest Death Rate / Xem So luong nguoi chet va Ty le nguoi chet cao nhat theo Quoc gia

Select location, MAX(Cast(total_deaths AS float)) as HighestDeathCount,  MAX(Cast(total_deaths AS float)/population)*100 as HighestDeathRate
From cases_covid_data$
Where continent is not null 
Group by location
Order by HighestDeathRate  desc
		-- HighestDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with Highest Death Count and Highest Death Rate / Xem So luong nguoi chet va Ty le nguoi chet cao nhat theo Chau luc

Select continent, MAX(Cast(total_deaths AS float)) as HighestDeathCount, MAX(Cast(total_deaths AS float)/population)*100 as HighestDeathRate
From cases_covid_data$
Where continent is not null 
Group by continent
Order by 
		--HighestDeathRate  desc
		HighestDeathCount desc

-- GLOBAL NUMBER

Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as TotalDeathRate
From cases_covid_data$
Where continent is not null 

-- Global cases and death per date

Select cases_covid_data$.date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as TotalDeathRate
From cases_covid_data$
Where continent is not null 
Group by cases_covid_data$.date
Order by -- cases_covid_data$.date
		-- TotalCases desc
		TotalDeaths desc

-- return NULL whenever the divide-by-zero error might occur
SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cas.continent, cas.location, cas.date, cas.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as float)) OVER (Partition by cas.location ORDER BY cas.location, cas.date) AS RollingVaccination
From [dbo].[cases_covid_data$] cas
Join [dbo].[vacination_covid_data$] vac
On cas.date = vac.date
	and cas.location = vac.location
Where cas.continent is not null 
Order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query 
--Su dung CTE de tinh ty le vaccine (do RollingVaccination moi dc tao trong query truoc)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccination)
as	
(Select cas.continent, cas.location, cas.date, cas.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as float)) OVER (Partition by cas.location ORDER BY cas.location, cas.date) AS RollingVaccination
From [dbo].[cases_covid_data$] cas
Join [dbo].[vacination_covid_data$] vac
On cas.date = vac.date
	and cas.location = vac.location
Where cas.continent is not null 

)
Select *, RollingVaccination/Population as VaccinateRate
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query / su dung Temp Table de tinh ty le vaccine

Create Table #vaccinate_rate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric
)

Insert into #vaccinate_rate
Select cas.continent, cas.location, cas.date, cas.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as float)) OVER (Partition by cas.location ORDER BY cas.location, cas.date) AS RollingVaccination
From [dbo].[cases_covid_data$] cas
Join [dbo].[vacination_covid_data$] vac
On cas.date = vac.date
	and cas.location = vac.location
Where cas.continent is not null 

Select * , RollingVaccination/Population*100 as VaccinateRate
From #vaccinate_rate