-- DDL Script - Create Bronze layer & insert bulk raw data into bronze layer tables
-- Create tables into bronze layer from source file

-- create cust_info tabe
create table bronze.crm_cust_info(
cust_id				int,
cut_key				nvarchar(50),
cust_firstname		nvarchar(50),
cust_lastname		nvarchar(50),
cust_marital_status nvarchar(50),
cust_gndr			nvarchar(50),
cust_createt_date	date
);

-- create prd_info table
create table bronze.crm_prd_info(
pri_Id int,
prd_key		nvarchar(50),
prd_nm		nvarchar(50),
prd_cost	int,
prd_line	nvarchar(50),
prd_start_dt datetime,
prd_end_dt	datetime
);

-- create sales_details table
create table bronze.crm_sales_details (
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
create table bronze.erp_loc_a101(
cid		nvarchar(50),
cntry	nvarchar(50)
);

create table bronze.erp_cust_az12(
cid		nvarchar(50),
bdate	date,
gen		nvarchar(50)
)

create table bronze.erp_px_cat_g1v2(
id			nvarchar(50),
cat			nvarchar(50),
subcat		nvarchar(50),
maintenance	nvarchar(50)
)

-- create procedure to load data
create or alter procedure bronze.load_bronze as 
BEGIN

	declare @start_time datetime, @end_time datetime;

	set @start_time = GETDATE()
	print'***************************************';
	print' Loading bronze layer';
	print'***************************************';


	print'-----------------------------------------';
	print' Loading CRM Tables';
	print'-----------------------------------------';
	truncate table bronze.crm_cust_info; -- to make table empty

	BULK INSERT bronze.crm_cust_info
	from "C:\Users\gajan\Downloads\SQLwarehouse\source_crm\cust_info.csv"
	with ( 
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	-- load bronze.crm_prd_info
	truncate table bronze.crm_prd_info;
	BULK INSERT bronze.crm_prd_info
	from "C:\Users\gajan\Downloads\SQLwarehouse\source_crm\prd_info.csv"
	with ( 
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- load bronze.crm_sales_details
	truncate table bronze.crm_sales_details;

	BULK INSERT bronze.crm_sales_details
	from "C:\Users\gajan\Downloads\SQLwarehouse\source_crm\sales_details.csv"
	with ( 
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	print'-----------------------------------------';
	print' Loading CRM Tables';
	print'-----------------------------------------';
	-- load bronze.erp_cust_az12
	truncate table bronze.erp_cust_az12;

	BULK INSERT bronze.erp_cust_az12
	from "C:\Users\gajan\Downloads\SQLwarehouse\source_erp\CUST_AZ12.csv"
	with ( 
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- load bronze.erp_loc_a101
	truncate table bronze.erp_loc_a101;

	BULK INSERT bronze.erp_loc_a101
	from "C:\Users\gajan\Downloads\SQLwarehouse\source_erp\LOC_A101.csv"
	with ( 
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- load bronze.erp_px_cat_g1v2
	truncate table bronze.erp_px_cat_g1v2;

	BULK INSERT bronze.erp_px_cat_g1v2 
	from "C:\Users\gajan\Downloads\SQLwarehouse\source_erp\PX_CAT_G1V2.csv"
	with ( 
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	set @end_time= getdate()
	print ' >> loading bronze layer is completed & time to load bronze layer ' + cast (datediff(second, @start_time, @end_time) as nvarchar ) + ' seconds' ;
END

-- make sure inserted data is complete

-- select COUNT(*) from bronze.crm_cust_info;
-- select COUNT(*) from bronze.crm_prd_info;;
-- select COUNT(*) from bronze.crm_sales_details;

-- select COUNT(*) from bronze.erp_cust_az12;
-- select COUNT(*) from bronze.erp_loc_a101;
-- select COUNT(*) from bronze.erp_px_cat_g1v2 ;

-- Execute Stored Procudure
EXEC bronze.load_bronze
