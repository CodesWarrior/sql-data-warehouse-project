/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
        - Truncates the bronze tables before loading data.
        - Uses the `BULK INSERT` command to load data from CSV Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

EXEC bronze.load_bronze;
GO
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

  DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY	
		SET @batch_start_time = GETDATE();
		PRINT '==================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '==================================';

		PRINT '-----------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '-----------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		truncate table bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		from 'C:\Users\eneng\Documents\PROJECTFILES_SQL\datasets\source_crm\cust_info.csv'
		with (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'
		 /* SELECT * FROM bronze.crm_cust_info;
		  select count(*) from bronze.crm_cust_info;*/
 
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		truncate table bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		from 'C:\Users\eneng\Documents\PROJECTFILES_SQL\datasets\source_crm\prd_info.csv'
		with (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		truncate table bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		from 'C:\Users\eneng\Documents\PROJECTFILES_SQL\datasets\source_crm\sales_details.csv'
		with (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK);

		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'


		PRINT '-----------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '-----------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_CUST_AZ12';
		truncate table bronze.erp_CUST_AZ12;

		PRINT '>> Inserting Data Into: bronze.erp_CUST_AZ12'
		BULK INSERT bronze.erp_CUST_AZ12
		from 'C:\Users\eneng\Documents\PROJECTFILES_SQL\datasets\source_erp\CUST_AZ12.csv'
		with (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_LOC_A101';
		truncate table bronze.erp_LOC_A101;

		PRINT '>> Inserting Data Into: bronze.erp_LOC_A101';
		BULK INSERT bronze.erp_LOC_A101
		from 'C:\Users\eneng\Documents\PROJECTFILES_SQL\datasets\source_erp\LOC_A101.csv'
		with (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK );
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_PX_CAT_GV12';
		truncate table bronze.erp_PX_CAT_GV12;

		PRINT '>> Inserting Data Into: bronze.erp_PX_CAT_GV12';
		BULK INSERT bronze.erp_PX_CAT_GV12
		FROM 'C:\Users\eneng\Documents\PROJECTFILES_SQL\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '============';

			SET @batch_end_time = GETDATE();
			PRINT '============';
			PRINT 'LOADING BRONZE LAYER IS COMPLETED';
			PRINT '     - TOTAL LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS	NVARCHAR) + ' seconds';
			PRINT '============';
		END TRY
		BEGIN CATCH
		PRINT '===============================';
		PRINT ' ERROR DURING LOAD BRONZE LAYER';
		PRINT ' ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT '===============================';
		END CATCH
END;
