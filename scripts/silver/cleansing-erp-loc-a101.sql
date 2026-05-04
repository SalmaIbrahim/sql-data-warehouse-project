with cte as 
(
select 
REPLACE(TRIM(cid), '-', '') cid
, CASE
	WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
	WHEN TRIM(cntry) in ('DE', 'Germany') THEN 'Germany'
	WHEN TRIM(cntry) in ('United States', 'US', 'USA') THEN 'United States'
	ELSE TRIM(cntry)
END cntry
from bronze.erp_loc_a101)

select * from cte;
--------
-- cid is related with the cst_key in cust_info tab;e
-- (compare) -> cid contains dashes -- Solved -- with Replace function
-- where cid not in (select cst_key from silver.crm_cust_info) -- No result (perfect)
--------
--now Check for the country name (to standarized values)

--select distinct cntry 
--, CASE
--	WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
--	WHEN TRIM(cntry) in ('DE', 'Germany') THEN 'Germany'
--	WHEN TRIM(cntry) in ('United States', 'US', 'USA') THEN 'United States'
--	ELSE TRIM(cntry)
--END country
--from cte order by cntry;

--- Solved