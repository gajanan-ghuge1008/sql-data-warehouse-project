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

--  added some new column for that droping and createing new

if object_id ('silver.crm_sales_details','U') is not null
	drop table silver.crm_sales_details;

create table silver.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int ,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_date date,
	sls_sales int,
	sls_quantity int,
	sls_price int,
	dwh_create_date datetime2 default getdate());


insert into silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_date,
	sls_sales,
	sls_quantity,
	sls_price
)
select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
case when sls_order_dt = 0 OR LEN(sls_order_dt) <8 then null -- handle invalid data 
	 else cast(CAST(sls_order_dt as varchar)as DATE) -- data type casting changing correct fomat date type
end as sls_order_df, 
case when sls_ship_dt = 0 OR LEN(sls_ship_dt) < 8 then null
	 else CAST(cast(sls_ship_dt as varchar) AS date) 
end as sls_ship_dt,
case when sls_due_dt = 0 OR LEN(sls_due_dt) < 8 then null
	 else CAST(cast(sls_due_dt as varchar) AS date) 
end as sls_due_dt,

case when sls_sales IS null OR sls_sales != sls_quntity * abs(sls_price) 
	 then sls_quntity * ABS(sls_price)
	 else sls_sales
end As  sls_sales, --  Recalculating sales if original value is missing or incorrect
sls_quntity,
case when sls_price IS null OR sls_price <= 0 then
	 sls_sales/ nullif(sls_quntity,0)
	 else sls_price -- drive price if original values are missing or invalid
end AS  sls_price
from bronze.crm_sales_details


-- insert cleaned data into silver.erp__cust_az12
insert into silver.erp_cust_az12(
cid,bdate,gen)

select
case when cid like 'NAS%' then SUBSTRING(cid, 4,len(cid)) -- remove 'NAS'  prefix if present
	 else cid
end as cid,
case when bdate > GETDATE() then null
	 else bdate -- Set future birhdates to null 
end bdate,
case when upper(trim(gen)) in ('F','Female') then 'Female'
	 when upper(trim(gen)) in ('M', 'Male') then 'Male'
	 else 'n/a'
end gen -- Normalize gender values and handle unknown cases
from bronze.erp_cust_az12


