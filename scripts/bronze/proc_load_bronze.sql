CREATE OR ALTER PROCEDURE sp_load_bronze as
BEGIN
declare @b_start_time datetime,@b_end_time datetime;
set @b_start_time = getdate()

declare @start_time datetime,@end_time datetime;
begin try
print '======================================================================================='
print '                                loading bronze layer'
print '======================================================================================='
print '---------------------------------------------------------------------------------------'
print '                                loading crm tables'
print '---------------------------------------------------------------------------------------'

set @start_time = getdate()
truncate table bronze.crm_cust_info

bulk insert bronze.crm_cust_info
from  'C:\Users\chava\OneDrive\Desktop\DesIDEA\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
with(
firstrow = 2,
fieldterminator = ',',
tablock
);
set @end_time = getdate()
print '>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'sec'


set @start_time = getdate()

truncate table bronze.crm_prd_info
bulk insert bronze.crm_prd_info
from  'C:\Users\chava\OneDrive\Desktop\DesIDEA\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
with(
firstrow = 2,
fieldterminator = ',',
tablock
);
set @end_time = getdate()
print '>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'sec'



set @start_time = getdate()

truncate table bronze.crm_sales_details
bulk insert bronze.crm_sales_details
from  'C:\Users\chava\OneDrive\Desktop\DesIDEA\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
with(
firstrow = 2,
fieldterminator = ',',
tablock
);
set @end_time = getdate()
print '>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'sec'


print '---------------------------------------------------------------------------------------'
print '                                loading erp tables'
print '---------------------------------------------------------------------------------------'


----------------erp
set @start_time = getdate()

truncate table bronze.erp_cat_g1v2
bulk insert bronze.CUST_AZ12
from  'C:\Users\chava\OneDrive\Desktop\DesIDEA\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
with(
firstrow = 2,
fieldterminator = ',',
tablock
);
set @end_time = getdate()
print '>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'sec'


set @start_time = getdate()

truncate table bronze.erp_cat_g1v2
bulk insert bronze.LOC_A101
from  'C:\Users\chava\OneDrive\Desktop\DesIDEA\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
with(
firstrow = 2,
fieldterminator = ',',
tablock
);
set @end_time = getdate()
print '>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'sec'


set @start_time = getdate()

truncate table bronze.erp_cat_g1v2
bulk insert bronze.PX_CAT_G1V2
from  'C:\Users\chava\OneDrive\Desktop\DesIDEA\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
with(
firstrow = 2,
fieldterminator = ',',
tablock
);
set @end_time = getdate()
print '>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'sec'

set @b_end_time = getdate()
print '>> load duration of total bronze layer:' + cast(datediff(second,@b_start_time,@b_end_time) as nvarchar)+'sec'

end try


begin catch 
   print '=========================================';
   print'error occured during loading bronze layer'
   print 'error message' + error_message();
   print '=========================================';

end catch 

END



-- exec sp_load_bronze
