/*
==================================================================================================
Quality Checks
==================================================================================================
Script Purpose:
	This script performs quality checks to validate the integrity, consistency,
	and accuracy of the Gold layer. These checks ensure:
	- uniqueness of surrogate keys in dimension tables.
	- Referential integrity between fact and dimension tables.
	- Validation of relationships in teh data model for analytical purpose.

Usage Notes:
	 - Run these checks after data loading silver layer.
	 - Investigate and resolve any discrepancies found during the checks
*/


-- =============================================================================
-- Checking 'gold.dim_customers'
-- =============================================================================
-- Checking for uniqueness of Customer key in gold.dim_customers
-- Expectation: No results

SELECT cst_id, COUNT(*) FROM
	(SELECT 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_material_status,
		ci.cst_gndr,
		ca.bdate,
		ca.gen,
		la.cntry
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON		ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON		ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1
----------------------------------------------------------------


SELECT * FROM gold.dim_customers

-- ===============================================================
-- Checking 'gold.product_key'
-- ===============================================================

SELECT prd_key, COUNT(*) FROM (
SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_giv2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out all historial data
)t GROUP BY prd_key
HAVING COUNT(*) > 1

---------------------------------------------------------------------------

SELECT * FROM gold.dim_products


-- =======================================================================
-- Checking 'gold.fact_sales'
-- =======================================================================
-- Check if all dimension table can successfully join to the fact table
-- Foreign key Integrity (Dimensions)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.Customer_Keys = f.Customer_Keys
WHERE c.Customer_Keys IS NULL



SELECT * FROM gold.fact_sales
