/*
====================
DDL Script: Create Gold Views
====================
Script Purpose:
This Script creates views for the Gold Layer in the data warehouse.
The Gold layer represents the final dimension and fact tables(Star Schema)
 Each view performs transformations and combines data from the silver layer to produce a clean, enriched, and business ready dataset.

Usage:
 - These Views can be queried directly for analytics and reporting.
*/

===================================
--CREATE DIMENSION: gold.dim_customers
==========================================

IF OBJECT_ID('gold.dim_customer', 'V') is not null
Drop View gold.dim_customr	
CREATE VIEW gold.dim_customer AS 

select
	ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_key, -- surrogate key
ci.cst_id As Customer_id,
	ci.cst_key as Customer_number,
	ci.cst_firstname AS Firstname,
	ci.cst_lastname as Lastname,
	ci.cst_marital_status AS Status,
	case when ci.cst_gendr != 'n/a' then ci.cst_gendr -- CRM  IS THE MASTER FOR GENDER INFO
	else coalesce (ca.gen, 'n/a')
  end as Gender,
  	ca.BDATE as Birthday,
	la.CNTRY as Country,
	ci.cst_create_date as Create_Date
	from silver.crm_cust_info ci
	left join silver.erp_CUST_AZ12 ca
	on ci.cst_key = ca.CID
	left join silver.erp_LOC_A101 la
	on ci.cst_key = la.CID;
	

	-- prd gold

	IF OBJECT_ID('gold.dim_products', 'V') is not null
Drop View  gold.dim_products
CREATE VIEW gold.dim_products AS 
	--SElect prd_key, count(*) from ( check if theres duplicate
	SELECT 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) AS Product_Key, -- surrogate key
	pn.prd_id as Product_id,
	pn.cat_id as Category_id,
	pn.prd_key as Product_number,
	pn.prd_nm as Product_name, 
	pn.prd_cost as Cost,
	pn.prd_line as Product_line,
    pc.CAT as Category, 
		pc.SUBCAT as Subcategory,
	pc.MAINTENANCE as Maintenance, 
	pn.prd_start_dt as Start_date
	from silver.crm_prd_info pn
	left join silver.erp_PX_CAT_GV12 pc
	on pn.cat_id = pc.ID
	where prd_end_dt is null; --)t -- filter out all historical data
	--GROUP BY prd_key check if theres duplicate
	--having count(*) > 1 ,check if theres duplicate

	-- sales


		IF OBJECT_ID('gold.fact_sales', 'V') is not null
Drop View gold.fact_sales
	Create View gold.fact_sales as
	select
	sd.sls_order_num as Order_number,
    pr.Product_Key,
	cm.Customer_key,
	sd.sls_order_dt as Order_date,
	sd.sls_ship_dt as Ship_date,
	sd.sls_due_dt as Due_date,
	sd.sls_sales as Sales,
	sd.sls_quantity as Quantity,
	sd.sls_price as Price
	from silver.crm_sales_details sd
	left join gold.dim_products pr
	on sd.sls_prd_key = pr.Product_number
	left join gold.dim_customer cm
	on sd.sls_cust_id = cm.Customer_id
	;
