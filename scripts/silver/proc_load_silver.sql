/* 
============================================================================
Procedure: silver.load_silver
============================================================================

Script and Purpose:
	This stored procedure loads data into the 'silver' layer tables 
	from the source bronze layer. 

	It performs the following key data transformation tasks:
		• Data Cleaning – removing invalid, duplicate, or null records.
		• Data Standardization – converting codes and formats into consistent, readable values.
		• Data Normalization – ensuring uniform representation of categorical data (e.g., gender, marital status).
		• Derived Columns – calculating additional columns such as product end dates.
		• Data Enrichment – enhancing datasets by combining, validating, and correcting related information.

WARNING:
	Make sure file paths are correct and accessible to SQL Server.
	Running this procedure will truncate existing data in the silver tables.

*/
GO

CREATE OR ALTER PROCEDURE silver.load_sliver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME ,@batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT('=================================================================================================================');
		PRINT('Loading Silver Layer');
		PRINT('=================================================================================================================');

		SET @start_time = GETDATE();
		PRINT('------------------------------------------------------------------------------------------------------------------');
		PRINT('Loading CRM Tables');
		PRINT('------------------------------------------------------------------------------------------------------------------');

		--Load CRM Customer Info
		PRINT('>>>>Truncating Table silver.crm_cust_info');
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT('>>>>Inserting Data Into:silver.crm_cust_info');
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)

		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname),--Removing unnessasary whitespaces in customer first name
			TRIM(cst_lastname), --Removing unnessasary whitespaces in customer last name
				CASE WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Single' --Normalizing marital status values to readable format
				 WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'n/a' 
			END cst_marital_status,
			CASE WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
				 WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'n/a' --Normalizing customer gender values to readable format
			END cst_gndr,
			cst_create_date
	
		FROM(
			SELECT *,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL) s

		WHERE flag_last = 1; -- selecting the most recent record per customer

		SET @end_time = GETDATE();
		PRINT('Load Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds' );

		-- Load CRM Product details
		SET @batch_start_time = GETDATE();
		PRINT('>>>>Truncating Table silver.crm_prd_info');
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT('>>>>Inserting Data Into:silver.crm_prd_info');

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

		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, --Extracting Category ID
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key, --Extracting Product id
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost, --Repalcing nulls with 0
			CASE TRIM(UPPER(prd_line)) --Normalizing product line valuse into readable format
				WHEN 'M' THEN 'Mountain'
					WHEN 'S' THEN 'Other Sales'
					WHEN 'R' THEN 'Road'
					WHEN 'T' THEN 'Touring'
					ELSE 'n/a'
			   END AS prd_line,
			CAST(prd_start_dt AS DATE), 
			CAST(DATEADD(DAY,-1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS DATE) prd_end_dt --Caculating end date as the start date before the next strat date

		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE();
		PRINT('Load Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) +'Seconds');
	
		--Load CRM Sales Details
		SET @start_time = GETDATE() 
		PRINT('>>>>Truncating Table silver.crm_sales_details');
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT('>>>>Inserting Data Into:silver.crm_sales_details');

		INSERT INTO  silver.crm_sales_details(
			sls_ord_num		,
			sls_prd_key		,
			sls_cust_id		,
			sls_order_dt	,
			sls_ship_dt		,
			sls_due_dt		,
			sls_sales		,
			sls_quantity	,
			sls_price		

		)

		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt =0 OR LEN(sls_order_dt)!= 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END sls_order_dt,
			CASE WHEN sls_ship_dt =0 OR LEN(sls_ship_dt)!= 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END sls_ship_dt,
			CASE WHEN sls_due_dt =0 OR LEN(sls_due_dt)!= 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END sls_due_dt,
			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != (sls_quantity * ABS(sls_price))
			THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price IS NULL or sls_price <= 0 THEN (sls_sales / NULLIF(sls_quantity,0))
			ELSE sls_price
			END AS sls_price

		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE()
		PRINT('Load Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) +'Seconds');
	
		PRINT('------------------------------------------------------------------------------------------------------------------');
		PRINT('Loading ERP Tables');
		PRINT('------------------------------------------------------------------------------------------------------------------');

		--Load ERP customer details 
		SET @start_time = GETDATE();
		PRINT('>>>>Truncating Table silver.erp_cust_az12');
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT('>>>>Inserting Data Into:silver.erp_cust_az12');

		INSERT INTO silver.erp_cust_az12(
			cid	,
			bdate,
			gen				

		)

		SELECT 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) --Remove Pre 'NAS' if present 
			ELSE cid 
			END cid,
			CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate -- set future bithdates so null
			END bdate,
			CASE WHEN TRIM(UPPER(gen)) IN ('F','FEMALE') THEN 'Female'
			WHEN TRIM(UPPER(gen)) IN ('M','MALE') THEN 'Male'	--Normalize gender values and handle unknown cases
			ELSE 'n/a'  END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();
		PRINT('Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds');

		--Load ERP customer Location Details
		SET @start_time = GETDATE();
		PRINT('>>>>Truncating Table silver.erp_loc_a101');
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT('>>>>Inserting Data Into:silver.erp_loc_a101');

		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry

		)

		SELECT 
			REPLACE(cid,'-','') AS cid,
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('United States','USA','US') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a' --Normalize and Handle missing or balnk country codes
				 ELSE cntry
			 END  AS cntry 

		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();
		PRINT('Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds');
	
		--Load ERP Product Category Details
		SET @start_time = GETDATE();
		PRINT('>>>>Truncating Table silver.erp_px_cat_g1v2');
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT('>>>>Inserting Data Into:silver.erp_px_cat_g1v2');
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance)

		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT('Load Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds');

		PRINT('=================================================================================================================');
		PRINT('Silver Layer Load Completed Successfully');
		PRINT('=================================================================================================================');

END TRY

	BEGIN CATCH
		PRINT('================================================================================================================================================================')
		PRINT('ERROR OCCURRED DURING LOADING SILVER LAYER');
		PRINT('Error Message: '+ CAST(ERROR_MESSAGE() AS NVARCHAR));
		PRINT('Error Line: '+ CAST(ERROR_LINE() AS NVARCHAR));
		PRINT('Error state: '+ CAST(ERROR_STATE() AS NVARCHAR));
		PRINT('================================================================================================================================================================')
	END CATCH
	SET @batch_end_time = GETDATE();
	PRINT('Total Load Duration '+ CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) +'Seconds')
END;
GO
