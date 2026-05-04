--- check each column quality
with cte as (
select 
id
, cat
, subcat
, maintenance
from bronze.erp_px_cat_g1v2
)
--select distinct id from cte 
---- 1st check
---- no duplication id & no null values
----------
---- 2nd 
---- it is related with the prod info table with the cat_id
---- CO_PD (has no products)
--where id not in ( select distinct cat_id from silver.crm_prd_info)
---- has nothing to change
----------
-- 3rd
-- cat name 
-- check for (nulls, unwanted spaces, duplicated names, need to be normalized)
-- select distinct cat from cte  --  no need to normalization
--select distinct cat from cte where cat != trim(cat) --  no unwanted spaces
--select * from cte where cat is null --  no null values
--select count(1), id, cat from cte group by id, cat having count(1) > 1 -- no duplications 

---------
-- 4th
-- the same with (sbcat,maintenance)
--select distinct subcat from cte -- no need to normalize
--select distinct maintenance from cte -- no need to normalize
--where subcat != TRIM(subcat) OR maintenance != TRIM(maintenance) -- no unwanted spaces
--WHERE subcat is null OR maintenance is null -- no null values
--select count(1), id, cat, subcat from cte group by id, cat, subcat having count(1) > 1 -- no duplication
--select count(1), id, cat, subcat, maintenance from cte group by id, cat, subcat, maintenance having count(1) > 1 -- no duplication
----------------------

----- nothing have to be cleaned here ----------