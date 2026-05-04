
-- Check PK nulls or dupli
select count(1), prd_id
from bronze.crm_prd_info
group by prd_id
having count(1) > 1
OR prd_id is null

-- nothing
--------------
select prd_key
from bronze.crm_prd_info
where prd_key != trim(prd_key)
--------------
-- prd_kry = concat( cat_id , id)
-- split prd_key
select 
	prd_id
	, prd_key
	, REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') as cat_id
	, SUBSTRING(TRIM(prd_key), 7, LEN(prd_key)) as prd_key
	, prd_nm
	, prd_cost
	, prd_line
	, prd_start_dt
	, prd_end_dt
from bronze.crm_prd_info
-- where REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') not in (select distinct TRIM(id) from bronze.erp_px_cat_g1v2 )--37
---- one Category not exits
where SUBSTRING(TRIM(prd_key), 7, LEN(prd_key)) NOT IN ( select distinct TRIM(sls_prd_key) from bronze.crm_sales_details)
-- 220 products with no orders!

--------------
select prd_nm
from bronze.crm_prd_info
where prd_nm != trim(prd_nm)
--------------
--check numbers (nulls, negative values)
select 
	prd_key, prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null
-- no -ve, 2 nulls
-- replace nulls with a determined or chosen value by the Client
-- here we will replace it with Zero

select 
	prd_id
	, prd_key
	, REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') as cat_id
	, SUBSTRING(TRIM(prd_key), 7, LEN(prd_key)) as prd_key
	, prd_nm
	, ISNULL(prd_cost, 0)
	, prd_line
	, prd_start_dt
	, prd_end_dt
from bronze.crm_prd_info
---------------

-- check values for prd line
-- select distinct prd_line from bronze.crm_prd_info
-- M, R, S, T, NULL
-- ask the Client for the whole word of the abbreviated values


select 
	prd_id
	, prd_key
	, REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') as cat_id
	, SUBSTRING(TRIM(prd_key), 7, LEN(prd_key)) as prd_key
	, prd_nm
	, ISNULL(prd_cost, 0)
	, CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END prd_cost
	, prd_start_dt
	, prd_end_dt
from bronze.crm_prd_info
-----

-- check for the quality of start and end date
-- end !< start 
-- historical rows 
	-- (end for eariler is the start of the next)
	-- (each record must have a Start date)
	-- (end date for the last record maybe null)
select * from bronze.crm_prd_info where prd_start_dt > prd_end_dt 
	-- to solve the problem of start > end
	-- ignore the end date and derive it from the next start date end_date = DATEADD(DAY, -1, lead(start_date))

-------

select 
	prd_id
	, prd_key
	, REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') as cat_id
	, SUBSTRING(TRIM(prd_key), 7, LEN(prd_key)) as prd_key
	, prd_nm
	, ISNULL(prd_cost, 0) as prd_cost
	, CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END as prd_line
	, CAST( prd_start_dt AS DATE) prd_start_dt
	, CAST( DATEADD(DAY, -1, lead(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) prd_end_dt
from bronze.crm_prd_info
where prd_key IN ('AC-HE-HL-U509-R')