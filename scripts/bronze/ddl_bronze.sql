 create database dwh_project;
go

use dwh_project;
go

create schema bronze;
create schema silver;
create schema gold;

if object_id('bronze.crm_cust_info','U') is not null
drop table bronze.crm_cust_info;


create table bronze.crm_cust_info(
cust_id int,
cust_key nvarchar(50),
cust_firstname nvarchar(50),
cust_lastname nvarchar(50),
cust_material_status nvarchar(50),
cust_gndr nvarchar(50),
cust_create_date date
 
);


if object_id('bronze.crm_prd_info','U') is not null
drop table bronze.crm_prd_info;
create table bronze.crm_prd_info(
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_dt datetime,
prd_end_dt datetime

);


if object_id('bronze.crm_sales_details','U') is not null
drop table bronze.bronze.crm_sales_details
create table bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
);

drop table bronze.crm_sales_details

create table bronze.LOC_A101(
cid nvarchar(50),
cntry nvarchar(50)
)

create table bronze.CUST_AZ12(
cid nvarchar(50),
bdate date,
gen nvarchar(50)
)

create table bronze.PX_CAT_G1V2(
id nvarchar(50),
cat nvarchar(50),
subcat nvarchar(50),
mainteneance nvarchar(50)
)
