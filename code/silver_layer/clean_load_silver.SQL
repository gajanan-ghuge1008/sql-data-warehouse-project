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
