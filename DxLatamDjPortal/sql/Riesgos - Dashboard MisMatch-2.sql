-- select * from Rep_DiffQuantity
USE [MaxWarehouse]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Rep_DiffQuantity]') AND type in (N'U'))
DROP TABLE [dbo].[Rep_DiffQuantity]
GO

create table Rep_DiffQuantity (
	[IdRegistro] [bigint]   IDENTITY(1,1) NOT NULL,
	[FechaIngreso]          date not null,
	[Sku]                   varchar(100) null,
	[SKU Status]            varchar(100) null,
	[Listing]               varchar(100) null,
	[Listing Status]        varchar(100) null,
	[AmazonUomQuantity]     float null,
	[PublicationMode]       varchar(200) null,
	[Review State]          varchar(200) null,
	[AvailabilityMode]      varchar(200) null,
	[Number Of Items]       float null,
	[Item Package Quantity] varchar(200) null,
	[ASIN]                  varchar(200) null,
)

insert into Rep_DiffQuantity (
 [FechaIngreso]          ,[Sku]                   ,[SKU Status]            ,[Listing]               
,[Listing Status]        ,[AmazonUomQuantity]     ,[PublicationMode]       ,[Review State]          
,[AvailabilityMode]      ,[Number Of Items]       ,[Item Package Quantity] ,[ASIN]                  
)

select 
  GETDATE() [FechaIngreso]
, [Sku]                   
,[SKU Status]            
,[Listing]               
,[Listing Status]        
,CAST(AmazonUomQuantity AS float)[AmazonUomQuantity]     
,[PublicationMode]       
,[Review State]          
,[AvailabilityMode]      
,[Number Of Items]       
,CAST([Item Package Quantity] AS float)[Item Package Quantity] 
,[ASIN]                  
from CRCAMAZON WITH(NOLOCK)
WHERE [SKU Status] ='Active' AND [Listing Status] = 'Existing' 
AND PublicationMode in('PriceAvailability','Full') AND [Review State] ='Verified'
AND CAST(AmazonUomQuantity AS float) !=  CAST([Item Package Quantity] AS float)

select count(*) from Rep_DiffQuantity where [AmazonUomQuantity] = 0
select count(*) from Rep_DiffQuantity where [AmazonUomQuantity] > 0
select count(*) from Rep_DiffQuantity where [Item Package Quantity] = 0
select count(*) from Rep_DiffQuantity where [Item Package Quantity] > 0
select [Listing Status] from Rep_DiffQuantity group by [Listing Status]
select [PublicationMode] from Rep_DiffQuantity group by [PublicationMode]
select [Review State] from Rep_DiffQuantity group by [Review State]
select [AvailabilityMode] from Rep_DiffQuantity group by [AvailabilityMode]
select [SKU Status] from Rep_DiffQuantity group by [SKU Status] 

