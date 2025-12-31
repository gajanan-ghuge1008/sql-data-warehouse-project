-- DDL Script - Create Bronze layer & insert bulk raw data into bronze layer tables

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
