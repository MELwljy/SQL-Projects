#1.1
-- SELECT all columns FROM table country and only display 5 records 
SELECT * FROM country limit 5;

-- Only want to check code, name, region, population columns FROM table country;
SELECT Code,Name,Region,Population FROM country;

-- Want to check different values of region IN table country
SELECT DISTINCT Region FROM country;

-- Comment out one of the query you just wrote down
SELECT /*DISTINCT*/ Region FROM country;

#1.2
-- Display the TOP 5 countries with the largest population-- 
SELECT name,population FROM country
ORDER BY 1 desc limit 5;

-- Rank the country by descendINg region, and ascendINg surfaceArea
SELECT name, region,surfaceArea FROM country
ORDER BY 2 desc,3;

-- List the countries with lifeExpectancy => 75 and rank by ascendINg population
SELECT name,lifeExpectancy, population FROM country
WHERE lifeExpectancy >= 75 ORDER BY 3;

-- List countries became INdependent between 1980 and 1990;
SELECT name, INdepYear FROM world.country
WHERE INdepYear between 1980 and 1990;

-- List countries IN region Eastern Asia and INdepYear is null;
SELECT name, INdepYear,region FROM country
WHERE region = 'Eastern Asia' and INdepYear is Null;

-- SELECT countries IN Western Europe, with population less than 80000000 and surfacearea larger than 3000, and rank these countries by descendINg Code column
SELECT name,code, population, SurfaceArea,region FROM country
WHERE region = 'Western Europe' 
and population< 80000000
and surfacearea > 3000
ORDER BY code desc;

#2.1
-- List countries IN region Eastern Africa or North America or Middle East ORDER BY region
SELECT name,region FROM country
WHERE region IN ('Eastern Africa','North America' ,'Middle East')
ORDER BY region;

-- For all countries IN region Eastern Asia , SELECT the countries with population > 7000000 or lifeexpectancy > 75
SELECT name,lifeExpectancy, population,region FROM country
WHERE (lifeExpectancy > 75 or population>7000000) and region='Eastern Asia';

-- Identify countries with name begINnINg with ‘A’ and endINg with ‘a’
SELECT * FROM country
WHERE name like 'A%a';

#2.2

-- Use population/surfacearea to get pop_density and rank pop_density by descendINg order
SELECT name, region, population, surfacearea, population/surfacearea as pop_density 
FROM country
ORDER BY pop_density desc;

-- Bonus: how can I get countries with pop_density > 1000
SELECT name, region, population, surfacearea, population/surfacearea as pop_density 
FROM country
WHERE population/surfacearea > 1000 -- WHERE statement在FROM之后 但是是先发生的
ORDER BY pop_density desc; -- 最后运行

-- Create a column called Population_size to segment the country by population size:
-- If population < 1 million, THEN ‘small’; if 1 million <= population < 10 million, THEN ‘medium’,if 10 million <= population < 100 million, 
-- THEN ‘large; if population >= 100 million, THEN ‘Extra large’;
-- THEN show country name and population_size

-- 错误例子
-- SELECT name,
-- CASE WHEN population<1000000 THEN 'small'
-- WHEN 1000000 <= population < 10000000 THEN 'median'
-- WHEN 10000000 <= population < 100000000 THEN 'large'
-- WHEN population >= 100000000 THEN 'Extra Large'
-- ELSE 'Invalid' END AS pop_size
-- FROM country;

SELECT name,
CASE WHEN population < 1000000 THEN 'small'
	WHEN population < 10000000 THEN 'medium'
    WHEN population < 100000000 THEN 'large'
    WHEN population >= 100000000 THEN 'extra large'
    ELSE 'invalid'
    END AS population_size
    FROM country;
    
SELECT name, population,
CASE WHEN population<1000000 THEN 'small'
WHEN 1000000 <= population and population < 10000000 THEN 'median'
WHEN 10000000 <= population and population < 100000000 THEN 'large'
WHEN population >= 100000000 THEN 'Extra Large'
ELSE 'Invalid' END AS pop_size
FROM world.country;

-- IN the table, we found a column called as Code which should be country code, and another column
-- called as Code2. I want to know whether Code2 is just the first 2 letters of Code. Please write query
-- to confirm this. HINt: use substrINg to get the first 2 letters of Code, and compare with Code2, if they
-- match with each other, THEN we can confirm

SELECT code, code2,
CASE WHEN SUBSTRING(code,1,2)=code2 THEN 'match'
ELSE 'not match' 
END AS check_code
FROM country;

SELECT * FROM country
WHERE substring(code,1,2) <> code2; -- 返回不match 情况 <> 戴奥 non-equality

SELECT *, CASE WHEN substring(code,1,2) = code2 THEN 'match'
ELSE 'not match' END AS code_check FROM country;

select * from (SELECT *, CASE WHEN substring(code,1,2) = code2 THEN 'match'
ELSE 'not match' END AS code_check FROM country) as a where a.code_check = 'not match'; -- derived table 用法


# 3.1
-- Create a report showing sum of population and average life expectancy for each continent, and make sure your result doesn’t include any
-- continent with total population less than 1000000;

SELECT continent,sum(population) as total_pop, avg(LifeExpectancy) as avg_LE
FROM country
GROUP BY continent
HAVING sum(population)>=1000000;

-- Create a column called Population_size to segment the country by population size and calculate the average lifeexpectancy for each
-- segment:
-- 	If population < 1 million, THEN ‘small’; if 1 million <= population < 10 million, THEN ‘medium’, 
-- 	if 10 million <= population < 100 million, THEN ‘large; 
-- 	if population >= 100 million, THEN ‘Extra large’;
-- your final result should show the population size segment and the average life expectancy for each segment

SELECT avg(LifeExpectancy),
CASE WHEN population < 1000000 THEN 'small'
	WHEN population < 10000000 THEN 'medium'
    WHEN population < 100000000 THEN 'large'
    WHEN population >= 100000000 THEN 'extra large'
    ELSE 'invalid'
    END AS population_size
    FROM country
    GROUP BY population_size;
    
SELECT CASE WHEN population < 1000000 THEN 'small'
	WHEN population < 10000000 THEN 'medium'
    WHEN population < 100000000 THEN 'large'
    WHEN population >= 100000000 THEN 'extra large' END AS population_size, 
    avg(LifeExpectancy)
    FROM country GROUP BY 1;


-- Using table countrylanguage , to get the number of countries speaking each distinct language, THEN rank the language by how many countries
-- and by descending order
SELECT * FROM countrylanguage;

SELECT language, count(distinct countrycode) as num_of_country
FROM countrylanguage
GROUP BY language 
ORDER BY 2 desc;

SELECT language, count(distinct countrycode) as num_of_country 
FROM countrylanguage GROUP BY 1 ORDER BY 2 desc;

-- Calculate the average population for each region and exclude the region whose average population is fewer than the average population of
-- all the countries in the country table. The final result should have 2 columns region and average population. Hint: use subquery to get the
-- overall average population first

SELECT avg(population) 
FROM country
GROUP BY region;

SELECT region, avg(population) as avg_pop
FROM country
GROUP BY region
HAVING avg_pop > (SELECT avg(population) FROM country);

# 4.1 
Select * from country;
Select * from countrylanguage;

-- Use table Country and Language to find the language used in each country. I want all columns
-- from Country table and language column from Language table
-- Use 2 types of Inner Join syntax to solve this: WHERE/Join On

Select country.*,countrylanguage.Language
from country,countrylanguage
where country.Code=countrylanguage.CountryCode;

select c.*, l.language from 
country as c
join countrylanguage as l on c.code=l.CountryCode;

select c.*, l.language from 
country as c, countrylanguage as l
where c.code=l.CountryCode;

-- Use table Country and City to find each country’s capital city name. Hint: check the capital
-- column in table Country, and find which column you should use in table City to join these 2
-- tables.
select * from city;

select c.*, ci.name as capitalname from 
country as c 
join city as ci on c.capital=ci.id;

-- Use table Country and City to find each country’s capital city name, the population in the capital
-- city and the percentage of capital city’s population in the whole country. Hint: you need to use
-- calculated field, and you may want to rename the column, so that the final table won’t have 2
-- columns with the same name

select ci.Population as capital_pop,ci.population/c.population as cap_pop_perc, ci.name as capitalname from 
country as c 
join city as ci on c.capital=ci.id;

select c.*, ci.name as capitalname,
ci.population as capital_pop,  
ci.population/c.population as cap_pop_perc
from
country as c
join
city as ci
on c.capital=ci.id;

# 4.2

-- 4.2.1

select c.*, l.language from 
country as c
left join
countrylanguage as l
on c.code=l.CountryCode;


select c.*, ci.name as capitalname from 
country as c
left join
city as ci
on c.capital=ci.id ;

select c.*, ci.name as capitalname,
ci.population as capital_pop,  
ci.population/c.population as cap_pop_perc
from
country as c
left join
city as ci
on c.capital=ci.id;

-- 4.2
-- Use table Country and Countrylanguage to find the official language used in each country. Hint: use column Isofficial and
-- WHERE filter
SELECT countrylanguage.IsOfficial,countrylanguage.language,country.name 
from country LEFT JOIN countrylanguage
on country.code = countrylanguage.CountryCode
where countrylanguage.IsOfficial='T';


select c.*, l.language from 
country as c
left join
countrylanguage as l
on c.code=l.CountryCode
where l.Isofficial='T';

-- Count the number of different languages used in each country. I only need columns: country name, number of languages used.
-- Hint: do not forget GROUP BY

select c.name,count(distinct l.language) as num_language from 
country as c
left join
countrylanguage as l
on c.code=l.CountryCode
group by c.name;

select c.name, 
count(l.language) as num_language from 
country as c
left join
countrylanguage as l
on c.code=l.CountryCode
group by 1;


-- Some countries may have more than one types of official languages. Count the number of different official languages used in
-- each country. I only need columns: country name, number of languages used
select c.name,count(distinct l.language) as num_language from 
country as c
left join
countrylanguage as l
on c.code=l.CountryCode
where l.Isofficial='T'
group by c.name;

-- Multiple table joins show me the information as below:
	--  country name
	-- 	Different languages used in the country
	-- 	for each language, how many people speak as column ‘ language_pop’
	-- 	official language or not
	-- 	capital city name

SELECT * FROM city;
select c.name,l.language, l.Percentage*c.population as language_pop, l.IsOfficial, city.name as capital_name
from country as c
left join countrylanguage as l
on c.code=l.CountryCode
left join city
on city.id=c.capital;


select c.name, l.language, 
l.percentage*c.population as language_pop,
l.isofficial, ci.name as capital_name
from country as c, city as ci, 
countrylanguage as l
where c.capital=ci.id
and c.code=l.CountryCode;

select c.name, l.language, 
l.percentage*c.population as language_pop,
l.isofficial, ci.name as capital_name
from country as c
left join
city as ci
on c.capital=ci.id
left join
countrylanguage as l
on c.code=l.CountryCode;

