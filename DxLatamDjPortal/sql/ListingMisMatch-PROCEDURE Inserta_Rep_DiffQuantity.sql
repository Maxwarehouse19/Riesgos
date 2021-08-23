--SELECT * FROM CRCAMAZON (NOLOCK)
/*	select count(*) from Rep_DiffQuantity where [AmazonUomQuantity] = 0
	select count(*) from Rep_DiffQuantity where [AmazonUomQuantity] > 0
	select count(*) from Rep_DiffQuantity where [Item Package Quantity] = 0
	select count(*) from Rep_DiffQuantity where [Item Package Quantity] > 0
	select [Listing Status] from Rep_DiffQuantity group by [Listing Status]
	select [PublicationMode] from Rep_DiffQuantity group by [PublicationMode]
	select [Review State] from Rep_DiffQuantity group by [Review State]
	select [AvailabilityMode] from Rep_DiffQuantity group by [AvailabilityMode]
	select [SKU Status] from Rep_DiffQuantity group by [SKU Status] */

execute Inserta_Rep_DiffQuantity

ALTER PROCEDURE Inserta_Rep_DiffQuantity
AS
BEGIN
	
	-- Borrar registros anteriores
	DELETE FROM Rep_DiffQuantity WHERE  DATEDIFF(day, FechaIngreso , GETDATE()) = 0 

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
END
GO

