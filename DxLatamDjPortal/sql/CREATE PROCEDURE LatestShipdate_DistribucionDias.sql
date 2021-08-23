--DROP TABLE LS_DiasXCantidad
--DROP TABLE LS_DiasXMonto
/*
CREATE TABLE LS_DiasXCantidad(
	id bigint identity(1,1),
	 FechaIngreso date,
	 StateCode varchar(10) null,
	 fulfillmentlocationname varchar(50) null,
	 [0]  int null,	 [1]  int null, 
	 [2]  int null,	 [3]  int null, 
	 [4]  int null,	 [5]  int null, 
	 [6]  int null,	 [7]  int null, 
	 [8]  int null,	 [9]  int null, 
	 [10] int null,	 [11] int null
	 , Latency int null
)
GO
CREATE TABLE LS_DiasXMonto(
	 id bigint identity(1,1),
	 FechaIngreso date,
	 StateCode varchar(10) null, 
	 fulfillmentlocationname varchar(50) null,
	 [0]  decimal(11,2) null,	 [1]  decimal(11,2) null, 
	 [2]  decimal(11,2) null,	 [3]  decimal(11,2) null, 
	 [4]  decimal(11,2) null,	 [5]  decimal(11,2) null, 
	 [6]  decimal(11,2) null,	 [7]  decimal(11,2) null, 
	 [8]  decimal(11,2) null,	 [9]  decimal(11,2) null, 
	 [10] decimal(11,2) null,	 [11] decimal(11,2) null
	 , Latency int null
)
GO
*/

-- EXEC LatestShipdate_DistribucionDias @Fecha = '20210623'
-- select * from LS_DiasXCantidad
-- select * from LS_DiasXMonto
-- select StateCode, Max(latency)latency, count(*) cnt from LocationLatency group by StateCode
-- drop procedure LatestShipdate_DistribucionDias
ALTER PROCEDURE LatestShipdate_DistribucionDias (@Fecha Date)
AS
BEGIN

	DELETE FROM LS_DiasXCantidad WHERE DATEDIFF(DAY,FechaIngreso,@Fecha)=0
	DELETE FROM LS_DiasXMonto WHERE DATEDIFF(DAY,FechaIngreso,@Fecha)=0
	
	insert into LS_DiasXCantidad (
		FechaIngreso ,	 StateCode ,  fulfillmentlocationname ,
		 [0]  ,	 [1]  , [2]  , [3]  , 
		 [4]  ,	 [5]  , [6]  , [7]  , 
		 [8]  ,	 [9]  , [10] , [11], Latency
	 )
	SELECT @Fecha,
	 StateCode,
	 fulfillmentlocationname,
	 ISNULL([0] ,0) [0]  ,
	 ISNULL([1] ,0) [1]  , ISNULL([2] ,0)[2] 
	,ISNULL([3] ,0) [3]  , ISNULL([4] ,0)[4] 
	,ISNULL([5] ,0) [5]  , ISNULL([6] ,0)[6] 
	,ISNULL([7] ,0) [7]  , ISNULL([8] ,0)[8] 
	,ISNULL([9] ,0) [9]  , ISNULL([10],0)[10]
	,ISNULL([11],0)	[11]
	,Latency
	FROM(
 		SELECT b.StateCode, LTRIM(RTRIM(a.fulfillmentlocationname)) fulfillmentlocationname,a.Latency,
			  CASE WHEN [DiasSinFin] < 11 THEN ISNULL([DiasSinFin],0) ELSE 11 END Dias,
			  count(*) CantPO
		  FROM [dbo].[LatestShipDate] a
		  left join  LocationLatency b on a.FulfillmentLocationName = b.Location
		  where datediff(day ,FechaInsercion , @Fecha) =0
		  group by  b.StateCode, LTRIM(RTRIM(a.fulfillmentlocationname)),a.Latency, [DiasSinFin]
	) AS SourceTable PIVOT( SUM(CantPO) FOR Dias IN ([0],[1], [2], [3],[4], [5], [6],[7], [8], [9],[10], [11])) AS PivotTable
	ORDER BY StateCode

	insert into LS_DiasXMonto (
		FechaIngreso ,	 StateCode ,  fulfillmentlocationname ,
		 [0]  ,	 [1]  , [2]  , [3]  , 
		 [4]  ,	 [5]  , [6]  , [7]  , 
		 [8]  ,	 [9]  , [10] , [11], Latency
	 )
	SELECT @Fecha,
	 StateCode
	,fulfillmentlocationname 
	,ISNULL([0] ,0) [0]  
	,ISNULL([1] ,0) [1]  , ISNULL([2] ,0)[2] 
	,ISNULL([3] ,0) [3]  , ISNULL([4] ,0)[4] 
	,ISNULL([5] ,0) [5]  , ISNULL([6] ,0)[6] 
	,ISNULL([7] ,0) [7]  , ISNULL([8] ,0)[8] 
	,ISNULL([9] ,0) [9]  , ISNULL([10],0)[10]
	,ISNULL([11],0)	[11]
	,Latency
	FROM(
 		SELECT b.StateCode,LTRIM(RTRIM(a.fulfillmentlocationname)) fulfillmentlocationname,a.Latency,
			  CASE WHEN [DiasSinFin] < 11 THEN ISNULL([DiasSinFin],0) ELSE 11 END Dias,
			  CAST(SUM([TotalSales]) AS DECIMAL(11,2) )TOTAL
		  FROM [dbo].[LatestShipDate] a
		  left join  LocationLatency b on a.FulfillmentLocationName = b.Location
		  where datediff(day ,FechaInsercion , @Fecha) =0
		  group by  b.StateCode, LTRIM(RTRIM(a.fulfillmentlocationname)),a.Latency, [DiasSinFin]
	) AS SourceTable PIVOT( SUM(TOTAL) FOR Dias IN ([0],[1], [2], [3],[4], [5], [6],[7], [8], [9],[10], [11])) AS PivotTable
	ORDER BY StateCode
END