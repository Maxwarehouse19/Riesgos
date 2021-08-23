/****** Object:  StoredProcedure [dbo].[TransfomaDatosSALESORDERS]    Script Date: 12/02/2021 09:56:52 ******/
-- EXEC [TransfomaDatosSALESORDERS]
DROP PROCEDURE [dbo].[TransfomaDatosSALESORDERS]
GO

CREATE PROCEDURE TransfomaDatosSALESORDERS
AS
begin 
	

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRANSFORMACION1]') AND type in (N'U'))
	DROP TABLE [dbo].[TRANSFORMACION1]
	
	CREATE TABLE [dbo].[TRANSFORMACION1](
		[Order Date] [varchar](19) NULL,
		[mes] [int] NULL,
		[dia] [int] NULL,
		[año] [int] NULL,
		[horaCompleta] [varchar](10) NULL,
		[hora] [int] NULL,
		[minuto] [int] NULL,
		[jornada] [varchar](2) NULL,
		[Status] [varchar](9) NULL,
		[Sales Channel] [varchar](15) NULL,
		[Sales Order Type] [varchar](28) NULL,
		[Net] [decimal](11, 2) NULL,
		[Currency] [varchar](3) NULL,
		[FechaFormato] [bigint] NULL,
		[HoraFormato] [bigint] NULL,
		[Sales Channel Items] [varchar](1500) NULL
	) ON [PRIMARY]
	
	INSERT INTO [TRANSFORMACION1] ([Order Date],mes,dia,año,horaCompleta,hora,minuto,jornada,Status,[Sales Channel],[Sales Order Type],Net,Currency,[Sales Channel Items])

	SELECT [Order Date],	   
		   CAST(RTRIM(LTRIM(substring([Order Date],1,CHARINDEX('/',[Order Date])-1))) AS INT)mes,
		   --CAST(RTRIM(LTRIM(substring([Order Date],CHARINDEX('/',[Order Date])+1, 2))) AS INT)dia,
		   CAST(RTRIM(LTRIM(substring([Order Date],CHARINDEX('/',[Order Date])+1, (CHARINDEX('/',[Order Date],CHARINDEX('/',[Order Date])+1)-1) - (CHARINDEX('/',[Order Date]))))) AS INT) dia,
		   CAST(RTRIM(LTRIM(substring([Order Date],CHARINDEX('/',[Order Date],CHARINDEX('/',[Order Date])+1)+1,4))) AS INT)año,
		   RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) horaCompleta,	   
		   CAST(SUBSTRING(RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))), 1, CHARINDEX(':',RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) , 1)-1) AS INT)hora,
		   CAST(SUBSTRING(RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))), CHARINDEX(':',RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) , 1)+1,2) AS INT)minuto,
		   SUBSTRING(RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))), CHARINDEX(' ',RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) , 1)+1,2) jornada,
		   [Status],
		   [Sales Channel],
		   [Sales Order Type],
		   CAST([Net] AS DECIMAL(11,2)) Net,
		   [Currency]
		   ,[Sales Channel Items]
	FROM [dbo].[SALEORDERS] WITH(NOLOCK)
	
	update TRANSFORMACION1 SET
		   FechaFormato = (año * 10000) + (mes*100) + dia ,
		   HoraFormato = ((
		   CASE WHEN hora = 12 AND Jornada = 'AM' THEN 0 ELSE
				CASE WHEN hora < 12 THEN CASE Jornada WHEN 'AM' THEN 0 ELSE 12 END
				ELSE CASE Jornada WHEN 'PM' THEN 0 ELSE 12 END END + hora
		   END) * 100) +   minuto 
	
	--CREATE NONCLUSTERED INDEX [TRANSFORMACION1_01] ON [dbo].[TRANSFORMACION1](
	--	[FechaFormato] ASC,		[HoraFormato] ASC,		[Sales Channel] ASC,		[Sales Order Type] ASC,		[Status] ASC
	--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	
	
	insert into DETALLE_VENTAS (Fecha	,Hora,CanalVenta	,TiposOrdenVenta	,Estado	,Año, Mes, Dia,CanalyTiposOrden, Monto, Moneda,[SKU])
	SELECT A.FechaFormato Fecha, A.HoraFormato Hora, A.[Sales Channel] CanalVenta, A.[Sales Order Type] TiposOrdenVenta,A.Status Estado
		,A.año [Año] ,
		 case A.mes when 1 then 'ENERO'
				  when 2 then 'FEBRERO'
				  when 3 then 'MARZO'
				  when 4 then 'ABRIL'
				  when 5 then 'MAYO'
				  when 6 then 'JUNIO'
				  when 7 then 'JULIO'
				  when 8 then 'AGOSTO'
				  when 9 then 'SEPTIEMBRE'
				  when 10 then 'OCTUBRE'
				  when 11 then 'NOVIEMBRE'
				  when 12 then 'DICIEMBRE'
				  else 'ERROR'
		 end
		 [Mes] ,
		 A.dia [Dia] ,
		 LTRIM(RTRIM(A.[Sales Channel])) +CASE WHEN A.[Sales Order Type] <> '' THEN '-'+ LTRIM(RTRIM(A.[Sales Order Type])) ELSE '' END CanalyTiposOrden,
		 A.Net      [Monto],
		 A.Currency [Moneda],
		 A.[Sales Channel Items]
	FROM TRANSFORMACION1 A WITH(NOLOCK)--, INDEX([TRANSFORMACION1_01]))
	LEFT JOIN DETALLE_VENTAS B ON A.FechaFormato = B.Fecha AND A.HoraFormato = B.Hora AND A.[Sales Channel] = B.CanalVenta AND A.[Sales Order Type] = B.TiposOrdenVenta
	WHERE B.Año IS NULL -- OMITIENDO DATOS REPETIDOS
	--GROUP BY  FechaFormato, año  ,mes ,dia ,[Sales Channel], [Sales Order Type],Status,Currency
	order BY  FechaFormato, año  ,mes ,dia ,[Sales Channel], [Sales Order Type],Status,Currency
		
	UPDATE DETALLE_VENTAS SET CanalyTiposOrden = CanalVenta	
	from DETALLE_VENTAS
	WHERE CanalyTiposOrden LIKE 'Amazon%'And charindex('AmazonBusiness' ,CanalyTiposOrden) <=0
	
	UPDATE DETALLE_VENTAS SET CanalyTiposOrden = CanalVenta	
	from DETALLE_VENTAS
	WHERE CanalyTiposOrden NOT LIKE 'Amazon%'
	
	UPDATE DETALLE_VENTAS SET CanalyTiposOrden = 'Amazon-AmazonBusiness'
	from DETALLE_VENTAS
	WHERE CanalyTiposOrden LIKE 'Amazon%'And charindex('AmazonBusiness' ,CanalyTiposOrden) >0

END	

-- select Año, mes, count(*) from DETALLE_VENTAS group by Año,mes

--select * from TRANSFORMACION1 WHERE [Sales Channel] Like '%SO-%'
--Amazon-AmazonBusiness
/*
select Año, Mes, COUNT(*) from TRANSFORMACION1 
GROUP BY Año, Mes
ORDER BY Año, Mes

select Año, Mes, [Sales Channel], [Sales Order Type], COUNT(*) Cantidad from TRANSFORMACION1 
GROUP BY Año, Mes,[Sales Channel], [Sales Order Type]
ORDER BY Año, Mes,[Sales Channel], [Sales Order Type]

SELECT Año, Mes,CanalyTiposOrden , COUNT(*) 
FROM DETALLE_VENTAS GROUP BY Año, Mes,CanalyTiposOrden
order BY Año, Mes,CanalyTiposOrden

SELECT CanalyTiposOrden , COUNT(*) 
FROM DETALLE_VENTAS GROUP BY CanalyTiposOrden
order BY CanalyTiposOrden

SELECT Año, Mes,COUNT(*) 
FROM DETALLE_VENTAS 
GROUP BY Año, Mes
order BY Año, Mes

select Año,Mes,CanalyTiposOrden ,count(*) Cantidad
from DETALLE_VENTAS (NOLOCK)
group by Año,Mes, CanalyTiposOrden 
order by Año,Mes, CanalyTiposOrden 

--- business (grupo b)

TRUNCATE TABLE DETALLE_VENTAS

*/



-- Amazon-AmazonBusiness

--select año , mes, count(*) from TRANSFORMACION1 group by año, mes

