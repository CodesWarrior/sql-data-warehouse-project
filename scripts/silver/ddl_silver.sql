/*
==================================================================
DDL Script: Create Silver Tables
==================================================================

Script Purpose:
	This script creates in the 'silver' schema, dropping existing tables if the already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
==================================================================
*/

--TSQL SCRIPT
	IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gendr NVARCHAR(50),
cst_create_date NVARCHAR (50),
dwh_create_date DATETIME2 DEFAULT GETDATE()

);
	IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR (50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt NVARCHAR (50),
prd_end_dt NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()

);
	IF OBJECT_ID ('crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
sls_order_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt date,
sls_ship_dt date,
sls_due_dt date,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);
	IF OBJECT_ID ('silver.erp_CUST_AZ12', 'U') IS NOT NULL
	DROP TABLE silver.erp_CUST_AZ12;
CREATE TABLE silver.erp_CUST_AZ12(
CID NVARCHAR(50),
BDATE DATE,
GEN NVARCHAR (50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

	IF OBJECT_ID ('silver.erp_LOC_A101', 'U') IS NOT NULL
	DROP TABLE silver.erp_LOC_A101;
CREATE TABLE  silver.erp_LOC_A101(
CID NVARCHAR(50),
CNTRY NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);
	IF OBJECT_ID ('silver.erp_PX_CAT_GV12', 'U') IS NOT NULL
	DROP TABLE silver.erp_PX_CAT_GV12;
CREATE TABLE silver.erp_PX_CAT_GV12(
ID NVARCHAR (50),
CAT NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);
