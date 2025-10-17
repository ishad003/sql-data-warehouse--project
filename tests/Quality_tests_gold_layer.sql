/*
====================================================================
DATA QUALITY VALIDATION: GOLD LAYER DIMENSIONS & FACTS
====================================================================

Purpose:
This script performs comprehensive data quality checks on the Gold Layer views (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`) and their upstream Silver Layer sources. It ensures clean, consistent, and reliable data for analytical use.

Scope:
✔️ Validates primary key uniqueness  
✔️ Standardizes gender data using CRM as the master source  
✔️ Checks for historical completeness in product lifecycle  
✔️ Confirms referential integrity between dimension and fact tables  
✔️ Performs final audits on Gold Layer views

Tables Involved:
- `silver.crm_cust_info`, `silver.erp_cust_az12`, `silver.erp_loc_a101`
- `silver.crm_prd_info`, `silver.erp_px_cat_g1v2`
- `gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`*/

------------------------------------------------------------------------------------
SELECT 
		ci.cst_id ,
		ci.cst_key,
		ci.cst_firstname ,
		ci.cst_lastname ,
		la.cntry ,
		ci.cst_marital_status ,
		ci.cst_gndr, 
		ca.gen,
		ca.bdate ,
		ci.cst_create_date 

	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid


--Compare gender values between CRM and ERP sources to identify inconsistencies
SELECT DISTINCT 
	ci.cst_gndr, 
	ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid


--Gender Standardization Logic
-- Purpose: Use CRM as the master source; fill missing or 'n/a' gender values using ERP reference.SELECT DISTINCT
	ci.cst_gndr, 
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --condidering crm_cust_info as the master table for gender data 
		 ELSE ca.gen END AS new_gender

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid

--Primary Key Uniqueness Check (Gold Layer)
SELECT customer_key,
		   COUNT(*)
FROM gold.dim_customers
GROUP BY customer_num
HAVING COUNT(*) >1

--Gender Value Review (Gold Layer)
SELECT DISTINCT gender
FROM gold.dim_customers


--Final Audit: `gold.dim_customers`
SELECT *
FROM gold.dim_customers

--------------------------------------------------------------------------------------------------

--testing the quality gold.dim_products

--Primary Key Uniqueness Check: `gold.dim_products`
SELECT product_key,
		   COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) >1

--Final Audit: `gold.dim_products`
SELECT *
FROM gold.dim_products

----------------------------------------------------------------------------------------------------

--Final Audit: `gold.fact_sales`
SELECT *
FROM gold.fact_sales

--Referential Integrity Check: Fact vs Dimension Tables
SELECT *
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
	ON S.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key

