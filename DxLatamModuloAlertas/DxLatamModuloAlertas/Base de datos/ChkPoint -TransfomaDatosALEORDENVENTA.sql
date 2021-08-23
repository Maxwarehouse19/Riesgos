-- truncate table ALEORDENVENTA
/*
SELECT * 
FROM ALEORDENVENTA
-- DELETE FROM ALEORDENVENTA
 WHERE Fecha/100 = 202102
 
select [EstadoLogico],	[CanalyTiposOrden]	,[Fecha],[Hora]	 , count(*) 
from ALEORDENVENTA 
group by [EstadoLogico],	[CanalyTiposOrden]	,[Fecha],[Hora]	 
having count(*) >2
order by [EstadoLogico],	[CanalyTiposOrden]	,[Fecha],[Hora]	 
*/

DROP PROCEDURE [dbo].[TransfomaDatosALEORDENVENTA]
GO

CREATE PROCEDURE TransfomaDatosALEORDENVENTA
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
	

	insert into ALEORDENVENTA (Fecha	,Hora,CanalVenta	,TiposOrdenVenta	,Estado	,Año, Mes, Dia,CanalyTiposOrden, Monto, Moneda,[SKU])
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
	FROM TRANSFORMACION1 A WITH(NOLOCK)
	LEFT JOIN ALEORDENVENTA B ON A.FechaFormato = B.Fecha AND A.HoraFormato = B.Hora AND A.[Sales Channel] = B.CanalVenta AND A.[Sales Order Type] = B.TiposOrdenVenta
	WHERE B.Año IS NULL -- OMITIENDO DATOS REPETIDOS		
	order BY  FechaFormato, año  ,mes ,dia ,[Sales Channel], [Sales Order Type],Status,Currency

	UPDATE ALEORDENVENTA SET CanalyTiposOrden = CanalVenta	
	from ALEORDENVENTA
	WHERE CanalyTiposOrden LIKE 'Amazon%'And charindex('AmazonBusiness' ,CanalyTiposOrden) <=0
	
	UPDATE ALEORDENVENTA SET CanalyTiposOrden = CanalVenta	
	from ALEORDENVENTA
	WHERE CanalyTiposOrden NOT LIKE 'Amazon%'
	
	UPDATE ALEORDENVENTA SET CanalyTiposOrden = 'Amazon-AmazonBusiness'
	from ALEORDENVENTA
	WHERE CanalyTiposOrden LIKE 'Amazon%'And charindex('AmazonBusiness' ,CanalyTiposOrden) >0
END

SELECT Fecha/100 Mes, CanalyTiposOrden , COUNT(*) Cantidad, Min(Hora) Hora_Min, Max(Hora) Hora_Max
FROM ALEORDENVENTA nolock
GROUP BY Fecha/100, CanalyTiposOrden
order BY Fecha/100, CanalyTiposOrden

SELECT Fecha/100 Mes,  COUNT(*) Cantidad, Min(Hora) Hora_Min, Max(Hora) Hora_Max
FROM ALEORDENVENTA nolock
GROUP BY Fecha/100
order BY Fecha/100


/*
SELECT CanalyTiposOrden , COUNT(*) 
FROM ALEORDENVENTA GROUP BY CanalyTiposOrden
order BY CanalyTiposOrden

SELECT Fecha, Hora/100 SoloHora, CanalyTiposOrden , COUNT(*) Cantidad
FROM ALEORDENVENTA 
GROUP BY Fecha, CanalyTiposOrden, Hora/100 
order BY Fecha, CanalyTiposOrden, Hora/100

SELECT Fecha/100 Mes, CanalyTiposOrden , COUNT(*) Cantidad, Min(Hora) Hora_Min, Max(Hora) Hora_Max
FROM ALEORDENVENTA nolock
GROUP BY Fecha/100, CanalyTiposOrden
order BY Fecha/100, CanalyTiposOrden


01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24

1. Obtener hora de la última lectura
2. A partir de esa hora en adelante validar casos
     . si es menor a lo esperado ver si la hora ha terminado (ya que se validará cada 15 mins)	      
		  - ya estamos en la siguiente hora 
		         > se llegó a un monto menor al rango de tolerancia inferior?
				       SI : ALERTA MINIMO
					   
	 . si es mayor a lo esperado + valor de tolerancia superior?
	       -      SI : ALERTA MÁXIMO 

*/
--DROP TABLE ORDENVENTA_REAL
/*
SELECT Fecha, Hora/100 SoloHora, CanalyTiposOrden , COUNT(*) Cantidad
INTO ORDENVENTA_REAL
FROM ALEORDENVENTA 
GROUP BY Fecha, CanalyTiposOrden, Hora/100 
order BY Fecha, CanalyTiposOrden, Hora/100

select fecha, count(*) from ORDENVENTA_REAL group by fecha order by fecha
select date, count(*) from PREDICCION group by date order by date

select fecha, * from ORDENVENTA_REAL a order by a.fecha
select date,  * from PREDICCION  a order by a.date


*/

/*
 -- REAL --
CanalyTiposOrden	(No column name)
Amazon	                1283
Amazon-AmazonBusiness	1073
eBay	                1252
Etail	                474
Google_Shopping	        57
Quokka	                1
Shopify	                1261
Walmart	                1265

-- PREDICCION --
CanalyTiposOrden	(No column name)
Amazon	8016
Amazon-AmazonBusiness	8016
eBay	8016
Etail	8016
Google_Shopping	8016
Shopify	8016
Walmart	8016

*/
/*
select * from ALEORDENVENTA

select * 
from PREDICCION
-- UPDATE PREDICCION SET CanalyTiposOrden = 'Google_Shopping'--'Amazon-AmazonBusiness'
WHERE EstadoLogico = 0 AND CanalyTiposOrden = 'GoogleShopping'--'AmazonBusiness'

select CanalyTiposOrden, count(*)
FROM PREDICCION P
WHERE EstadoLogico = 0 
group by CanalyTiposOrden
order by CanalyTiposOrden

select CanalyTiposOrden, count(*)
FROM ORDENVENTA_REAL P
group by CanalyTiposOrden
order by CanalyTiposOrden

select CanalyTiposOrden, count(*)
FROM ALEORDENVENTA P
WHERE EstadoLogico = 0 
group by CanalyTiposOrden
order by CanalyTiposOrden




SELECT P.CanalyTiposOrden, P.date, R.CanalyTiposOrden, R.Fecha, R.SoloHora, R.Cantidad, P.prediction,  P.prediction - R.Cantidad Diferencia
FROM PREDICCION P
INNER JOIN ORDENVENTA_REAL R
	ON   P.EstadoLogico = 0
	AND  P.date = R.Fecha
	and  P.hour = R.SoloHora
	--and  P.CanalyTiposOrden = 'Amazon'
	AND  P.CanalyTiposOrden = R.CanalyTiposOrden
--where R.CanalyTiposOrden = 'Amazon'
ORDER BY R.CanalyTiposOrden, R.Fecha, R.SoloHora

SELECT  R.CanalyTiposOrden,  R.SoloHora, COUNT(*) Cantidad
FROM PREDICCION P
INNER JOIN ORDENVENTA_REAL R
	ON   P.EstadoLogico = 0
	AND  P.date = R.Fecha
	and  P.hour = R.SoloHora
	--and  P.CanalyTiposOrden = 'Amazon'
	AND  P.CanalyTiposOrden = R.CanalyTiposOrden
--where R.CanalyTiposOrden = 'Amazon'
GROUP BY R.CanalyTiposOrden,  R.SoloHora
ORDER BY R.CanalyTiposOrden,  R.SoloHora
*/
--SELECT (30.00 - 100.00) /100.00, (30.00 - 100.00) /30.00
--SELECT (50.00 - 150.00) /150.00, (50.00 - 150.00) /50.00
--SELECT 150.00 * -0.66666666, 50 * -2.0000000
--SELECT 100 * 0.7 , 30 * -2.3333333 