/*
====================================================================
DATA QUATILY TEST SUITE: CRM & ERP Validation 
====================================================================
Purpose:
This script performs comprehensive data validation checks across multiple layers of the data warehouse (Bronze and Silver ) 
focusing on CRM customer info, product details, sales transactions, and ERP product categorization.

Scope:
✔️ Detects whitespace issues, nulls, and duplicates in key fields  
✔️ Validates business logic for dates, prices, quantities, and sales amounts  
✔️ Reviews categorical consistency and controlled vocabulary usage  
✔️ Confirms transformation integrity between Bronze and Silver layers

====================================================================
*/
*/


------------------------------------------------------------------------
/* Data Quality Check: CRM Customer Info

  Tests Included:
  1. Check for unwanted leading/trailing spaces in:
     - `cst_firstname`
     - `cst_lastname`
     - `cst_material_status`
     - `cst_gndr`
  2. Review distinct values for:
     - `cst_marital_status`
     - `cst_gndr`
   */
------------------------------------------------------------------------

SELECT cst_firstname --exists
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname--exists
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_material_status -- no results
FROM silver.crm_cust_info
WHERE cst_material_status != TRIM(cst_material_status)

SELECT DISTINCT cst_marital_status --S,NULL,M
FROM silver.crm_cust_info

SELECT cst_gndr --no results
FROM silver.crm_cust_info
where cst_gndr != TRIM(cst_gndr)

--Data Standardization & Consistency
SELECT DISTINCT cst_gndr --NULL,F,M
FROM silver.crm_cust_info

select *
from silver.crm_cust_info

------------------------------------------------------------------------
/* Data Quality Validation: CRM Product Info

  Tests Included:
  1. Primary Key Validation:
     - Detects any duplicate or null values in `prd_id`, which should be a unique identifier for each product.

  2. Whitespace Check:
     - Identifies product names (`prd_nm`) with leading or trailing spaces that may affect joins or reporting.

  3.Date Logic Validation:
     - Flags records where `prd_end_dt` is earlier than `prd_start_dt`, which may indicate incorrect lifecycle data.
   */
------------------------------------------------------------------------
--Checking any nulls or duplicates in the primary key
SELECT prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) >1 or prd_id IS NULL 

--Checking if there any unneccsaary white spaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm

--Checking for invalid order dates
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt > prd_start_dt

------------------------------------------------------------------------
/* Data Quality Validation: CRM Sales Details

  Tests Included:

  1. Order Date Validation:
     - Flags records where `sls_order_dt` is later than `sls_ship_dt` or `sls_due_dt`, which may indicate incorrect sequencing.

  2. Sales, Price, and Quantity Validation:
     - Detects rows with null, negative, or mismatched values between `sls_sales`, `sls_quantity`, and `sls_price`.
     - Recalculates expected values using business logic to highlight discrepancies.

  3. Invalid Price Check:
     - Identifies records with negative `sls_price`, which may violate pricing rules.

  4. Silver Layer Consistency:
     - Repeats key validations on the `silver.crm_sales_details` table to ensure data remains clean after transformation.
   */
------------------------------------------------------------------------
	--Check for invalid order dates
	SELECT *
	FROM bronze.crm_sales_details
	WHERE sls_order_dt > sls_ship_dt 
		OR sls_order_dt > sls_ship_dt
		OR sls_order_dt > sls_due_dt

	
--Checking for invaild sales, prices and quantities
SELECT DISTINCT 
	sls_sales AS OLD,
	sls_quantity,
	sls_price AS older_price,

CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != (sls_quantity * ABS(sls_price))
	THEN sls_quantity * ABS(sls_price)
ELSE sls_sales END sls_sales,

CASE WHEN sls_price IS NULL or sls_price <= 0 THEN (sls_sales / NULLIF(sls_quantity,0))
ELSE sls_price
END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != (sls_quantity*sls_price)
OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
OR  sls_price <0 OR sls_quantity <0 OR sls_sales <0
ORDER by sls_sales,sls_quantity,sls_price

--checking for invaid prices
SELECT sls_price
FROM bronze.crm_sales_details
WHERE sls_price <0

SELECT*
FROM  silver.crm_sales_details

--checking the data consistency between order date,shipping date and sales due date
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt> sls_ship_dt OR sls_order_dt > sls_due_dt

--checking the data consistency between sales,slaes quantity,sales price

SELECT *
FROM silver.crm_sales_details
WHERE sls_sales != (sls_quantity*sls_price)
OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
OR  sls_price <0 OR sls_quantity <0 OR sls_sales <0
ORDER by sls_sales,sls_quantity,sls_price

------------------------------------------------------------------------
/* Data Quality Validation: ERP Product Category Mapping

  Tests Included:

 Tests Included:

  1. Whitespace Check:
     - Detects leading or trailing spaces in key categorical fields:
       - `cat` (Category)
       - `subcat` (Subcategory)
       - `maintenance` (Maintenance flag)

  2. Standardization & Consistency Review:
     - Extracts distinct values from `cat`, `subcat`, and `maintenance` to assess:
       - Controlled vocabulary usage
       - Unexpected variations or typos
       - Readiness for dimension mapping

  3. Silver Layer Consistency:
     - Retrieves all records from `silver.erp_px_cat_g1v2` to verify transformation quality and confirm that Bronze-level issues have been resolved.
   */
------------------------------------------------------------------------

--checking for unnessary white spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
	OR subcat != TRIM(subcat)
	OR maintenance != TRIM(maintenance)

--checking for data standardization & Consistency
SELECT DISTINCT cat	
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2

SELECT *
FROM silver.erp_px_cat_g1v2
