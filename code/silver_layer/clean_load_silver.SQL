-- *** Clean & Load Data ***
-- insert cleaned data into silver.crm_cust_info

insert into silver.crm_cust_info ( 
cust_id,
cut_key,
cust_firstname,
cust_lastname,
cust_marital_status,
cust_gndr,
cust_createt_date)

select 
cust_id,
cut_key,
trim(cust_firstname) as cust_firstname, -- removed unncessury space
trim(cust_lastname) as cust_lastname, -- removed unncessury space
case when upper(trim(cust_marital_status)) = 'S' then 'Single'
	 when upper(trim(cust_marital_status)) = 'M' then 'Married'
	 else 'n/a'
end as cust_marital_status, -- normalize marital status values  to readable format
case when upper(trim(cust_gndr)) = 'F' then 'Female'
	 when upper(trim(cust_gndr)) = 'M' then 'Male'
	 else 'n/a'
end as cust_gndr, -- Normalize gende values to readable format
cust_createt_date
from (
	select 
	*,
	row_number() over(partition by cust_id order by cust_createt_date desc) as flag_last -- select most recent record per cust
	from bronze.crm_cust_info 
	where cust_id is not null -- filter null values
) t where  flag_last= 1 -- removing duplicates


-- insert cleaned data into silver.crm_prd_info

if OBJECT_ID ('silver.crm_prd_info','U')  is not null
	drop table silver.crm_prd_info;
create table silver.crm_prd_info(
	 prd_id int,
	 cat_id nvarchar(50),
	 prd_key nvarchar(50),
	 prd_nm nvarchar(50),
	 prd_cost int,
	 prd_line nvarchar(50),
	 prd_start_dt date,
	 prd_end_dt date,
	 dwh_create_date datetime2 default getdate() -- giving time while creating the table
);
--  added some new column for that droping and createing new
insert into silver.crm_prd_info (
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt)

select 
pri_id as prd_id,
replace(SUBSTRING(prd_key,1,5),'-','_')  as cat_id, -- extracted cat_id that will use to join erp_px_cat_g1v2 table
SUBSTRING(prd_key,7,len(prd_key)) as prd_key, -- fetching only prd_key that will use in sales_detail
prd_nm,
Isnull(prd_cost, 0) as prd_cost, -- replacing null with 0 cost

case UPPER(trim(prd_line))
	 when 'M' then 'Mountain'
	 when 'R' then 'Road'
	 when 'S' then 'Other Sales'
	 when 'T' then 'Touring'
	 else 'n/a'
end as prd_line, -- map product line codes to descriptive values
cast(prd_start_dt AS date) as pr_start_dt,
cast(LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt )-1 AS  DATE)  as prd_end_dt -- calculate end date as one day before the next start date
 from bronze.crm_prd_info;
