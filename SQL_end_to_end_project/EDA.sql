-- Exploratory Data Analysis

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

SELECT * 
FROM sql_data_cleaning.layoffs_cleaned;

select  
Max(total_laid_off), 
max(percentage_laid_off)
from layoffs_cleaned;

select 
company, sum(total_laid_off)
from layoffs_cleaned
group by company 
order by sum(total_laid_off) desc;

select *
from  layoffs_cleaned
order by `date` desc;

select
country, sum(total_laid_off)
from layoffs_cleaned
group by country
order by sum(total_laid_off) desc;

select max(`date`), min(`date`)
from layoffs_cleaned;

select 
industry, sum(total_laid_off) ,sum(percentage_laid_off)
from layoffs_cleaned
group by industry
order by sum(percentage_laid_off) desc; 

select 
country, 
year(`date`),
sum(total_laid_off)
from layoffs_cleaned
group by country, 
	year(`date`)
order by sum(total_laid_off) desc;


with running_laid_off as (
select 
 year(`date`) as Year,
 month(`date`) as Month,
sum(total_laid_off) as total_laid
from layoffs_cleaned
where  year(`date`) is not null and month(`date`) is not null
group by year(`date`),month(`date`)
order by year(`date`),month(`date`)
)
select *,
sum(total_laid) over(order by year, month rows between unbounded preceding and current row) as running_laid,
sum(total_laid) over(partition by year order by year, month rows between unbounded preceding and current row) as running_laid_per_year
from running_laid_off;

-- rank with most laid with year

with company_year as  (
select company,
year(`date`) as year,
sum(total_laid_off) as tota_laid
-- rank() over (partition by year order by sum(total_laid_off) desc) as rnk
from layoffs_cleaned
group by company, year(`date`)
), 
ranking_yearly as (
select *,
dense_rank() over( partition by year order by tota_laid desc) as rnk
from company_year
where year is not null )

select * from ranking_yearly
where rnk <= 5
order by year desc
