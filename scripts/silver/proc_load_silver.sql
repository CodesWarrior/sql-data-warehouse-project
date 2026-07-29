/*
=====================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=====================================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;

=====================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver as
BEGIN
  DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY	
		SET @batch_start_time = GETDATE();
		PRINT '==================================';
		PRINT 'LOADING SILVER LAYER';
		PRINT '==================================';

		PRINT '-----------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '-----------------------------------';

		SET @start_time = GETDATE();
        PRINT  '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT  '>> Truncating Table: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info(
        cst_id, cst_key,cst_firstname,
        cst_lastname,cst_marital_status,
        cst_gendr,cst_create_date
        )

        SELECT cst_id, cst_key,
        trim(cst_firstname) as first_name,
        trim(cst_lastname) as last_name,
        case when upper(trim(cst_marital_status)) = 'M' then 'Married'
        when upper(trim(cst_marital_status)) = 'S' then 'Single'
        else 'Unknown'
        end cst_marital_status,
        case when upper(trim(cst_gendr)) = 'F' then 'Female'
        when upper(trim(cst_gendr)) = 'M' then 'Male'
        else 'Unknown'
        end cst_gendr,
        cst_create_date
        from(
        select *,
        ROW_NUMBER() over (PARTITION BY cst_id order by cst_create_date desc) as flag_latest
        from bronze.crm_cust_info
        where cst_id IS NOT NULL
        )t where flag_latest = 1;

        	SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'
        -- silverrrr prd
        
		SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';
        WITH cleaned_products AS
        (
            SELECT -- cte
                prd_id,

                TRIM(prd_key) AS raw_prd_key, --derived columns - create new col based on calcultations or trans of new existing one, use fpr cte

                REPLACE(
                    SUBSTRING(TRIM(prd_key), 1, 5),
                    '-',
                    '_'
                ) AS cat_id,--derived columns - create new col based on calcultations or trans of new existing onem, extract cat id

                SUBSTRING(TRIM(prd_key),7,LEN(TRIM(prd_key))) AS prd_key,--derived columns - create new col based on calcultations or trans of new existing onem, extract prd key

                TRIM(prd_nm) AS prd_nm,

                COALESCE(prd_cost, 0) AS prd_cost,

                CASE UPPER(TRIM(prd_line))
                    WHEN 'M' THEN 'Mountain'
                    WHEN 'R' THEN 'Road'
                    WHEN 'S' THEN 'Other Sales'
                    WHEN 'T' THEN 'Touring'
                    ELSE 'N/A'
                END AS prd_line,-- map product line codes to descrptive rules than abbreviation

                TRY_CONVERT(DATE, NULLIF(TRIM(prd_start_dt), ''), 103
                ) AS prd_start_dt -- convert format date from nvarchat to date format

            FROM bronze.crm_prd_info
        )
        INSERT INTO silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt 
        )
        SELECT -- main query
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,

            DATEADD(
                DAY,
                -1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY raw_prd_key
                    ORDER BY prd_start_dt, prd_id
                )
            ) AS prd_end_dt -- calculate end date as one day before the next start date

        FROM cleaned_products
        ORDER BY raw_prd_key, prd_start_dt; 

              	SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'

        -- silverr sales
        
		SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        insert into silver.crm_sales_details(

        sls_order_num ,
        sls_prd_key ,
        sls_cust_id ,
        sls_order_dt ,
        sls_ship_dt ,
        sls_due_dt,
        sls_sales ,
        sls_quantity ,
        sls_price

        )
          select 
                  sls_order_num,
                  sls_prd_key,
                  sls_cust_id,

                 case when sls_order_dt = 0 or len(sls_order_dt) !=8 then Null -- handling invalid data
                    else cast(Cast(sls_order_dt as varchar) as date) -- casting date interger to date format
                    end as sls_order_dt, 

                  case when  sls_ship_dt = 0 or len( sls_ship_dt) !=8 then Null
                    else cast(Cast( sls_ship_dt as varchar) as date) -- casting date interger to date fornat
                    end as  sls_ship_dt, 

                      case when    sls_due_dt = 0 or len(   sls_due_dt) !=8 then Null
                    else cast(Cast(   sls_due_dt as varchar) as date) -- casting date interger to date fornat
                    end as    sls_due_dt, 

                 CASE
                     WHEN sls_sales IS NULL -- missing sales
                     OR sls_sales <= 0      -- zero and negative sales
                     OR sls_sales != sls_quantity * ABS(sls_price) --if sls_prce is negative it will convert to postive using th ABS
                     THEN sls_quantity * ABS(sls_price)   -- Recalculate the correct sales using quantity × positive price

                     ELSE sls_sales -- Keep the original sales kapag valid at tama ang calculation
                 END AS sls_sales,

                 case when sls_price is null or sls_price <=0  -- handling invalid data
                 THEN sls_sales / nullif(sls_quantity,0) -- deriving it to specific calculation
                 else sls_price -- derive price if original value is invalid
                 end as sls_price,
                 sls_quantity
                 from bronze.crm_sales_details;
        SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'
         -- silver erppp
         
		PRINT '-----------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '-----------------------------------';

		SET @start_time = GETDATE();
         PRINT '>> Truncating Table: silver.erp_CUST_AZ12';
        TRUNCATE TABLE silver.erp_CUST_AZ12;
        PRINT '>> Inserting Data Into: silver.erp_CUST_AZ12';
        insert into silver.erp_CUST_AZ12 (CID,BDATE,GEN)

        select
        case when CID like 'NAS%' THEN substring(CID,4,len(CID)) -- make it the same other table so ure able to join it,transform data, remove NAS
        else CID
        end cid,
        case WHEN BDATE > GETDATE() THEN NULL
        ELSE BDATE
        end as bdate,-- SET FUTIRE BDATE TO NULL
        case when upper(trim(GEN)) IN ('F','FEMALE') THEN 'Female'
         when upper(trim(GEN)) IN ('M','MALE') THEN 'Male'
         else 'N/A'
         end as Gen -- Normalize gender values and handle unknown cases  
        from bronze.erp_CUST_AZ12;
        		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'

        -- erppp loc
        SET @start_time = GETDATE();
         PRINT '>> Truncating Table: silver.erp_LOC_A101';
        TRUNCATE TABLE silver.erp_LOC_A101;
        PRINT '>> Inserting Data Into: silver.erp_LOC_A101';
        insert into silver.erp_LOC_A101 (CID,CNTRY)
        select
        REPLACE(CID,'-', '') AS cid,-- REMOVE/REPLACE '-' INTO empty string
        case when  trim(CNTRY) = 'DE' THEN 'Germany'
        when trim(CNTRY) IN('US','USA') THEN 'United States'
        WHEN trim(CNTRY) = ' ' or CNTRY is NULL then 'N/A'
        Else trim(CNTRY) -- remove unwanted spaces
        end as CNTRY -- normalize and handle missing blank	
        from bronze.erp_LOC_A101;

         SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'

        -- erpppp catt
         SET @start_time = GETDATE();
         PRINT '>> Truncating Table: silver.erp_PX_CAT_GV12';
        TRUNCATE TABLE silver.erp_PX_CAT_GV12;
        PRINT '>> Inserting Data Into: silver.erp_PX_CAT_GV12';
        insert into silver.erp_PX_CAT_GV12(
        ID,CAT,SUBCAT, MAINTENANCE)
        select ID,CAT,SUBCAT, MAINTENANCE from bronze.erp_PX_CAT_GV12;
                 SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'
        SET @batch_end_time = GETDATE();
			PRINT '============';
			PRINT 'LOADING SILVER LAYER IS COMPLETED';
			PRINT '     - TOTAL LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS	NVARCHAR) + ' seconds';
			PRINT '============';
        -- try and catch
END TRY
		BEGIN CATCH
		PRINT '===============================';
		PRINT ' ERROR DURING LOAD SILVER LAYER';
		PRINT ' ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT '===============================';
		END CATCH -- try catchhh
        
END;
