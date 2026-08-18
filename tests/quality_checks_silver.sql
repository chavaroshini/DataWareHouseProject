--exec load_silver

create or alter procedure load_silver as
begin
declare @start_time datetime , @end_time datetime,@batch_start_time datetime ,@batch_end_time datetime ;
begin try
set @batch_start_time  = getdate();
print'========================================================================'
print'==========================loading silver layer=========================='
print'========================================================================'

print'------------------------------------------------------------------------'
print'==========================loading crm tables============================'
print'-------------------------------------------------------------------------'

--Transforming the bronze layer data of crm_cust_info to silver layer data
set @start_time = GETDATE();
truncate table silver.crm_cust_info
INSERT INTO silver.crm_cust_info
(
    cust_id,
    cust_key,
    cust_firstname,
    cust_lastname,
    cust_material_status,
    cust_gndr,
    cust_create_date,
    dwh_create_date
)
SELECT
    cust_id,
    cust_key,
    TRIM(cust_firstname) AS cust_firstname,
    TRIM(cust_lastname) AS cust_lastname,

    CASE
        WHEN UPPER(TRIM(cust_material_status)) = 'S' THEN 'SINGLE'
        WHEN UPPER(TRIM(cust_material_status)) = 'M' THEN 'MARRIED'
        ELSE 'N/A'
    END AS cust_material_status,

    CASE
        WHEN UPPER(TRIM(cust_gndr)) = 'F' THEN 'FEMALE'
        WHEN UPPER(TRIM(cust_gndr)) = 'M' THEN 'MALE'
        ELSE 'N/A'
    END AS cust_gndr,

    cust_create_date,
    GETDATE() AS dwh_create_date

FROM
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cust_id
               ORDER BY cust_create_date
           ) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1;
set @end_time = GETDATE();
print'>> load duration' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
print'***************************************************************************************************************'


--Transforming the bronze layer data of crm_prd_info to silver layer data 
set @start_time = GETDATE();

    truncate table silver.crm_prd_info
insert into silver.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_num,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
select 
prd_id ,
replace(substring(prd_key,1,5),'-','_') as cat_id,
substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm ,
isnull(prd_cost ,0) as prd_cost,
case when upper(trim(prd_line)) = 'M' then 'MOUNTAIN' 
when upper(trim(prd_line)) = 'R' then 'ROAD'
when upper(trim(prd_line)) = 'S' then 'Other Sales'
when upper(trim(prd_line)) = 'T' then 'TTOURING'
else 'N/A'
end as prd_line,
cast(prd_start_dt as date) as prd_start_dt,
cast(lead(prd_start_dt) over (Partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
 from bronze.crm_prd_info
 set @end_time = GETDATE();
print'>> load duration' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
print'***************************************************************************************************************'


 --Transforming the bronze layer data of crm_sales_details to silver layer data 
 set @start_time = GETDATE();

 truncate table silver.crm_sales_details
 insert into silver.crm_sales_details(
 sls_ord_num ,
sls_prd_key ,
sls_cust_id ,
sls_order_dt ,
sls_ship_dt ,
sls_due_dt ,
sls_sales ,
sls_quantity ,
sls_price 
 )
select 
sls_ord_num ,
sls_prd_key ,
sls_cust_id ,
case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,

case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt,

case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null else cast(cast(sls_due_dt as varchar) as date)
end as sls_due_dt,


case when sls_sales is null or sls_sales <= 0 or sls_sales!= sls_quantity * abs(sls_price)
then sls_quantity * abs(sls_price)
else sls_sales
end sls_sales,

sls_quantity ,

case when sls_sales is null or sls_price <= 0
then sls_sales / nullif(sls_quantity,0)
else sls_sales
end as sls_price
from bronze.crm_sales_details
set @end_time = GETDATE();
print'>> load duration' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
print'***************************************************************************************************************'

print'------------------------------------------------------------------------'
print'==========================loading erp tables============================'
print'-------------------------------------------------------------------------'

 --Transforming the bronze layer data of erp__cust_az12 to silver layer data 
 set @start_time = GETDATE();

 truncate table silver.CUST_AZ12
 insert into silver.CUST_AZ12(
 cid ,
bdate,
gen )
 select 
 case when cid like 'NAS%' then substring(cid,4,len(cid))
 else cid
 end as cid,
 case when bdate > getdate() then null else bdate
 end as bdate,
 case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
 when upper(trim(gen)) in ('M','MALE') then 'Male'
 else 'N/A'
 end as gen
 from bronze.CUST_AZ12
 set @end_time = GETDATE();
print'>> load duration' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
print'***************************************************************************************************************'



--Transforming the bronze layer data of erp__cust_a101 to silver layer data
set @start_time = GETDATE();

truncate table silver.LOC_A101
insert into silver.LOC_A101(
cid ,
cntry
)
select replace (cid,'-','_') as cid,
case 
when trim(cntry)= 'DE' then 'Germany'
when trim(cntry) in ('US','USA') then 'unites states'
when trim(cntry) = '' or cntry is null then 'N/A'
else trim(cntry)
end as cntry
from bronze.loc_a101
set @end_time = GETDATE();
print'>> load duration' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
print'***************************************************************************************************************'



--Transforming the bronze layer data of erp__PX_CAT_G1V2 to silver layer data 
set @start_time = GETDATE();

truncate table silver.PX_CAT_G1V2
insert into silver.PX_CAT_G1V2(
id,
cat ,
subcat ,
mainteneance 
)
select id,cat,subcat,mainteneance from bronze.PX_CAT_G1V2
set @start_time = GETDATE();
print'>> load duration' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
print'***************************************************************************************************************'
set @batch_end_time  = getdate();
print'>> load duration' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+'seconds'
print'***************************************************************************************************************';
end try

begin catch
print'error occured during loading of bronze layer'
end catch
end

