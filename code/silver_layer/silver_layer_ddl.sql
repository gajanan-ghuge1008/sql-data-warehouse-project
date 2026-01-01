-- Create tables into Silver layer from source file

-- create cust_info tabe
create table silver.crm_cust_info(
cust_id				int,
cut_key				nvarchar(50),
cust_firstname		nvarchar(50),
cust_lastname		nvarchar(50),
cust_marital_status nvarchar(50),
cust_gndr			nvarchar(50),
cust_createt_date	date
);

-- create prd_info table
create table silver.crm_prd_info(
pri_Id int,
prd_key		nvarchar(50),
prd_nm		nvarchar(50),
prd_cost	int,
prd_line	nvarchar(50),
prd_start_dt datetime,
prd_end_dt	datetime
);

-- create sales_details table
create table silver.crm_sales_details (
sls_ord_num		nvarchar(50),
sls_prd_key		nvarchar(50),
sls_cust_id		int,
sls_order_dt	int,
sls_ship_dt		int,
sls_due_dt		int,
sls_sales		int,
sls_quntity		int,
sls_price		int
);
 

 -- create erp tables
create table silver.erp_loc_a101(
cid		nvarchar(50),
cntry	nvarchar(50)
);

create table silver.erp_cust_az12(
cid		nvarchar(50),
bdate	date,
gen		nvarchar(50)
)

create table silver.erp_px_cat_g1v2(
id			nvarchar(50),
cat			nvarchar(50),
subcat		nvarchar(50),
maintenance	nvarchar(50)
)
