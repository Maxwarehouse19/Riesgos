USE [MaxWarehouse]
GO

DELETE from [home_category] where [code] = 'MOD001' and parent_id is null

INSERT INTO [dbo].[home_category]
           ([title]
           ,[parent_id]
           ,[code])
VALUES
           ('Modulo de Parámetros'
           ,null
           ,'MOD001')

GO

DECLARE @MOD001id INT

SELECT  @MOD001id = id from [home_category] where [code] = 'MOD001' and parent_id is null

--SELECT  @USA001id 


INSERT INTO [dbo].[home_category]
           ([title]
           ,[parent_id]
           ,[code])

SELECT descripcion, @MOD001id , Res
FROM (
	select 'Latest Shipdate' descripcion , 'LShipdate' Res
)X