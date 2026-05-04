-- Primary Key ->> must be unique and not null
-- Check PK for Nulls or Duplication

-- check for nulls
select * 
from bronze.crm_cust_info 
where cst_id is null 
-- 4 records

-- check for duplications
select count(1), cst_id 
from bronze.crm_cust_info 
group by cst_id 
having count(1) > 1
	OR cst_id is NULL
-- 6 ids duplicated (total > 15 rows)

--------- get non duplicated values ---------
select (18494 - (15-6))
select *
from (
select *
, ROW_NUMBER() OVER 
	(PARTITION BY cst_id 
	ORDER BY cst_create_date DESC) flag_last
from bronze.crm_cust_info 
) cst_t
where flag_last = 1

-----------------------------------------------

-- check for unwanted spaces in string values 
select cst_firstname
from bronze.crm_cust_info 
where cst_firstname != TRIM(cst_firstname)

select cst_lastname
from bronze.crm_cust_info 
where cst_lastname != TRIM(cst_lastname)
-- cst_gndr >> no spaces 
select cst_marital_status
from bronze.crm_cust_info 
where cst_marital_status != TRIM(cst_marital_status)
-----------------------------------------------
--- remove unwanted spaces
select cst_t.cst_id
, cst_t.cst_key
, TRIM(cst_t.cst_firstname) as cst_firstname
, TRIM(cst_t.cst_lastname) as cst_lastname
, cst_t.cst_gndr
, cst_t.cst_marital_status
, cst_t.cst_create_date

from (
select *
, ROW_NUMBER() OVER 
	(PARTITION BY cst_id 
	ORDER BY cst_create_date DESC) flag_last
from bronze.crm_cust_info 
) cst_t
where flag_last = 1
--------------------------------------

-- check the consistency of the values in low cardinality columns
-- data Standardization & consistency

-- using meaningful values rather than abbreviated terms
-- instead of M -> Male, F -> Female
select distinct cst_gndr
from bronze.crm_cust_info 

-- instead of S -> Single, M -> Married
select distinct cst_marital_status
from bronze.crm_cust_info 

-- meaningful values

select cst_t.cst_id
, cst_t.cst_key
, TRIM(cst_t.cst_firstname) as cst_firstname
, TRIM(cst_t.cst_lastname) as cst_lastname
, case UPPER(TRIM(cst_t.cst_gndr)) -- in case letters are not Capital and have unwanted spaces
	when 'M' then 'Male'
	when 'F' then 'Female'
	else 'n/a' -- not availabe
end cst_gndr
, case UPPER(TRIM(cst_t.cst_marital_status))
	when 'S' then 'Single'
	when 'M' then 'Married'
	else 'n/a'
end cst_marital_status
, cst_t.cst_create_date

from (
select *
, ROW_NUMBER() OVER 
	(PARTITION BY cst_id 
	ORDER BY cst_create_date DESC) flag_last
from bronze.crm_cust_info 
) cst_t
where flag_last = 1

-----------------------------------------

