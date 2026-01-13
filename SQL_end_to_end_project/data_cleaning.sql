-- SQL Project - Data Cleaning
SELECT * FROM sql_data_cleaning.layoffs;

-- DATA CLEANING
describe layoffs;

SELECT * FROM layoffs;

-- 1 Remove Duplicates
-- 2 Stadardize the data
-- 3 Null values or blank values
-- 4 Remove unnecessury column or rows

-- first we create a staging table. this is the one we will perfrom data cleanign and keep our raw data safe
create table layoffs_clen 
like layoffs;
select * from layoffs_clen;

-- insert date 
insert into layoffs_clen 
select * from layoffs;

-- check duplicates
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs_clen;

with duplicate_cte as 
(select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date` ,stage,country) as row_num
from layoffs_clen
)
select * from duplicate_cte
where row_num = 2;

-- check 
select * from layoffs_clen
where company like 'Yahoo';

-- isert into clened data into layoffs_cleaned
CREATE TABLE `layoffs_cleaned` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_cleaned
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date` ,stage,country) as row_num
from layoffs_clen;


select * from layoffs_cleaned
where row_num = 2;

-- delete duplicates
delete from layoffs_cleaned
where row_num > 1;

-- drop column row_num (will occupie space)
alter table layoffs_cleaned
drop column row_num;

select * from layoffs_cleaned;

-- 2 Standardization of date

select * from layoffs_cleaned
where company != trim(company);

update layoffs_cleaned
set company = trim(company);
-- ----------------------------------------------------
select distinct industry
from layoffs_cleaned
order by 1;

select * from layoffs_cleaned
where industry  like 'Crypto%';

update layoffs_cleaned
set industry = 'Crypto'
where industry in ('Crypto Currency','CryptoCurrency');

-- -----------------------------------------------------------
select Distinct country
from layoffs_cleaned
where country like '%.'
order by 1;

update layoffs_cleaned
set country = 'United States'
where country like '%.';

select distinct country
from layoffs_cleaned
order by 1;

-- ------------------------------------------
select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoffs_cleaned;

update layoffs_cleaned
set `date` = str_to_date(`date`,'%m/%d/%Y');

-- change datatype
alter table layoffs_cleaned
modify column `date` date;

select * from layoffs_cleaned
order by 1 ;


-- 3 Handling Nulls

select *
from layoffs_cleaned
where industry is null or industry = '' ;

update layoffs_cleaned
set industry = null
where industry = '';

select *
from layoffs_cleaned
where company = "Juul";

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with

select t1.industry, t2.industry from layoffs_cleaned t1
join layoffs_cleaned t2
	on t1.company = t2.company and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_cleaned t1
join layoffs_cleaned t2
	on t1.company = t2.company
set t1.industry = t2.industry 
where t1.industry is null
and t2.industry is not null;

select * from layoffs_cleaned
where industry is null or industry = '';

-- -------------------------------------------------
select * 
from layoffs_cleaned
where stage is null;

update layoffs_cleaned
set stage = 'Unknown'
where stage is null;

select * from layoffs_cleaned
where stage is null;


select * 
from layoffs_cleaned
where total_laid_off is null and percentage_laid_off is null;

-- deleting rows after discussing with client

delete from layoffs_cleaned
where total_laid_off is null and percentage_laid_off is null;

select * from layoffs_cleaned;
