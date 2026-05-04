----- Sales Details Cleansing
--USE DataWarehouse
---- select * from bronze.crm_sales_details

----- from the Data Integration Model (created with draw.io)
---- Sales Details related with Cust Info (sls_cust_id), prod info (sls_prd_key)
--select 
--sls_ord_num
--, sls_prd_key
--, sls_cust_id
--, NULLIF(sls_order_dt, 0) sls_order_dt
--, sls_ship_dt
--, sls_due_dt
--, sls_sales
--, sls_quantity
--, sls_price
--from bronze.crm_sales_details
-------
-- ---------------- check for each column ----------------
-------
------ *sls_prd_key* check integrity prod not in prod info
----where sls_prd_key NOT IN (select distinct prd_key from silver.crm_prd_info) -- none
-------
------ *sls_cust_id* integrity with cust info
---- where sls_cust_id NOT IN (select distinct cst_id from silver.crm_cust_info) -- none
-------
------ *sls_order_dt*, *sls_ship_dt*, *sls_due_dt*
------ check for (values, format & datatype, due date !< shiped date !< order date )

---- ****** Sol--> NULLIF ******
--WHERE sls_order_dt <= 0 -- 17
--AND LEN(sls_order_dt) != 8 -- yyyymmdd -- 2
--OR sls_order_dt > 20500101 -- long future -- NONE
--OR sls_order_dt < 19000101 -- long past	  -- NONE
-------
----
with cte as (
select 
sls_ord_num
, sls_prd_key
, sls_cust_id
, CASE 
	WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST (CAST(sls_order_dt AS NVARCHAR) AS DATE)
END AS sls_order_dt
, CASE 
	WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
	ELSE CAST (CAST(sls_ship_dt AS NVARCHAR) AS DATE)
END AS sls_ship_dt
, CASE 
	WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST (CAST(sls_due_dt AS NVARCHAR) AS DATE)
END AS sls_due_dt
, CASE
	WHEN sls_sales IS NULL 
		OR sls_sales <= 0 
		OR sls_sales != (sls_quantity * ABS(sls_price))
	THEN (sls_quantity * ABS(sls_price))
	ELSE sls_sales
END sls_sales
, sls_quantity
, CASE
	WHEN sls_price IS NULL
		OR sls_price <= 0 
	THEN (sls_sales / NULLIF(sls_quantity, 0))
	ELSE sls_price
END sls_price
from bronze.crm_sales_details
)
-------- Check for date sequence ----------
-- where sls_order_dt > sls_ship_dt -- NONE
-- where sls_ship_dt > sls_due_dt -- NONE
-- where sls_order_dt > sls_due_dt -- NONE
-------------------------------------------
-------------- Business Rules -----------------
-- Sales = Qty * Price
-- No (-ve, Zeros, nulls)
-------------------------------------------
--select * from cte
--where sls_sales != (sls_quantity * sls_price)
--OR sls_sales IS NULL	OR sls_sales <= 0
--OR sls_quantity IS NULL OR sls_quantity <= 0
--OR sls_price IS NULL	OR sls_price <= 0
--ORDER BY sls_sales

--------------------
--- from the order date to ship date (7 Days), from the ship date to due date (5 Days)
select
sls_ord_num
, sls_prd_key
, sls_cust_id
, ISNULL(sls_order_dt, DATEADD(DAY, -7, sls_ship_dt)) sls_order_dt
, sls_ship_dt
, sls_due_dt
, sls_sales
, sls_quantity
, sls_price
from cte 
