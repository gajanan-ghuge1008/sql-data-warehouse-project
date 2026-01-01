
-- DDL Script: Create Gold Views

-- -- Create Dimension: gold.dim_customers

create view gold.dim_customers as 
select 
	ROW_NUMBER() over(order by cust_id) AS customer_Key,
	ci.cust_id as customer_id,
	ci.cut_key as customer_number, 
	ci.cust_firstname as first_name,
	ci.cust_lastname as last_name, 
	la.cntry as country,
	ci.cust_marital_status as marital_status,
	case when ci.cust_gndr != 'n/a' then cust_gndr -- CRM is the master for gender
		 else coalesce(ca.gen,'n/a') 
	end as gender,
	ca.bdate as birthdate,
	ci.cust_createt_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on		ci.cut_key = ca.cid
left join silver.erp_loc_a101 la
on		ci.cut_key = la.cid

--select * from gold.dim_customers

-- -- Create Dimension: gold.dim_Product

create view gold.dim_product as 
select 
	ROW_NUMBER() over(order by pn.prd_start_dt, pn.prd_key) As product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintenance,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date	
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt is null -- filterout all historical data

-- select * from gold.dim_product

-- -- Create Fact Table : gold.fact_sales
  
create view gold.fact_sales as
select 
	sd.sls_ord_num as order_number,
	pr.product_key,
	cu.customer_Key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_date as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_product pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id
