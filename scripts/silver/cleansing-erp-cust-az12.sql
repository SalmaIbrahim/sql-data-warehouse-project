--------- cust_az12 Cleansing
---- select distinct cid from bronze.erp_cust_az12 --18484
---- where case when cid like 'NAS%' then SUBSTRING(cid, 4, len(cid)) else cid end not in (
---- select cst_key from silver.crm_cust_info) -- 18485
---- --11042
---- --select * from silver.crm_cust_info where cst_key like '%AW00019784%'
---- --NASAW00019784 = NAS+cst_key
-- --------------------
--select 
-- CASE 
--	WHEN cid like 'NAS%' 
--	THEN SUBSTRING(cid, 4, len(cid)) 
--	ELSE cid 
--END cid
-- , CASE
--	WHEN bdate > GETDATE() 
--	THEN NULL
--	ELSE bdate
-- END bdate
-- , gen
--from bronze.erp_cust_az12
--where bdate < '1924-01-01'	-- older than 100
--OR bdate > GETDATE()		-- in the future
--order by bdate desc
------
--select distinct gen from bronze.erp_cust_az12 -- NULL, F, blank, Male, Female, M
----
with cte as (
select 
 CASE 
	WHEN cid like 'NAS%' 
	THEN SUBSTRING(cid, 4, len(cid)) 
	ELSE cid 
END cid
 , CASE
	WHEN bdate > GETDATE() 
	THEN NULL
	ELSE bdate
 END bdate 
 , CASE
	WHEN UPPER(TRIM(gen)) in ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) in ('M', 'MALE') THEN 'Male'
	ELSE 'n/a'
 END gen
from bronze.erp_cust_az12
)

-- select distinct gen from cte -- (DONE)
select * from cte
-- no ddl changed