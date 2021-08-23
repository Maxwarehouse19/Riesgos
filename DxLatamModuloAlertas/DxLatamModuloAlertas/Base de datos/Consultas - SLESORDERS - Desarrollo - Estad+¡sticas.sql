-----------------------------------------------------------------------------------------------------------------------------------------------------
--
--    ANÁLISIS ESTADÍSTICO
--
-----------------------------------------------------------------------------------------------------------------------------------------------------

/*
select AÑO, Mes, COUNT(*) from DETALLE_VENTAS GROUP BY AÑO, Mes
SELECT count(*) FROM [DETALLE_VENTAS] WHERE Fecha = 20210102 ORDER BY Fecha, Estado, CanalyTiposOrden

SELECT  Mes,Estado, CanalyTiposOrden, Count(*) Cantidad, sum(Monto) Sum_Monto, avg(Monto) Prom_Monto, max(Monto) Max_Monto, min(Monto) Min_Monto,
 ROUND(ISNULL(VAR(Monto) ,0) ,2) Monto_Varianza, ROUND(ISNULL(STDEVP(Monto) ,0),2) Monto_DesEst
FROM [DETALLE_VENTAS]
GROUP BY Mes,CanalyTiposOrden, Estado
ORDER BY Mes,CanalyTiposOrden, Estado
*/

---------------- SEPARANDO EN RANGOS DE 15 MINUTOS ---------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RES_VENTASXRANGO]') AND type in (N'U'))
	DROP TABLE RES_VENTASXRANGO

select  Fecha, Año, Mes, CanalyTiposOrden, Estado,  H.HoraInicial, SUM(Monto) Monto_SUM, AVG(Monto) Monto_AVG, COUNT(*) Cantidad, ISNULL(VAR(Monto) ,0) Monto_Varianza, ISNULL(STDEVP(Monto) ,0) Monto_DesEst
,DATEPART(WEEKDAY,cast(V.Fecha as varchar (8))) DiaSemanaNum
,DATEPART(WEEKDAY,cast(V.Fecha as varchar (8)))* 10000 + H.HoraInicial  DiaHoraNum
,CASE DATEPART(WEEKDAY,cast(V.Fecha as varchar (8))) 
		WHEN 1 THEN 'DOMINGO'
		WHEN 2 THEN 'LUNES'
		WHEN 3 THEN 'MARTES'
		WHEN 4 THEN 'MIÉRCOLES'
		WHEN 5 THEN 'JUEVES'
		WHEN 6 THEN 'VIERNES'
		WHEN 7 THEN 'SÁBADO'
	END DiaSemana
into RES_VENTASXRANGO
from DETALLE_VENTAS V
INNER JOIN RANGOS_Hora H ON V.Hora BETWEEN H.HoraInicial AND HoraFinal
GROUP BY Fecha,Año,Mes, Estado,CanalyTiposOrden,  H.HoraInicial
ORDER BY Fecha,Año,Mes, Estado,CanalyTiposOrden,  H.HoraInicial

SELECT Año, Mes , COUNT(*) FROM RES_VENTASXRANGO GROUP BY Año, Mes

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DET_VENTASXRANGO]') AND type in (N'U'))
	DROP TABLE DET_VENTASXRANGO

select  V.* 
	,DATEPART(WEEKDAY,cast(V.Fecha as varchar (8))) DiaSemanaNum
	,DATEPART(WEEKDAY,cast(V.Fecha as varchar (8)))* 10000 + H.HoraInicial  DiaHoraNum
	,CASE DATEPART(WEEKDAY,cast(V.Fecha as varchar (8))) 
		WHEN 1 THEN 'DOMINGO'		WHEN 2 THEN 'LUNES'
		WHEN 3 THEN 'MARTES'		WHEN 4 THEN 'MIÉRCOLES'
		WHEN 5 THEN 'JUEVES'		WHEN 6 THEN 'VIERNES'
		WHEN 7 THEN 'SÁBADO'
	END DiaSemana
,   H.HoraInicial, H.HoraFinal
into DET_VENTASXRANGO
from DETALLE_VENTAS V
INNER JOIN RANGOS_Hora H ON V.Hora BETWEEN H.HoraInicial AND HoraFinal
ORDER BY Fecha,Estado,CanalyTiposOrden,  H.HoraInicial

SELECT Año, Mes , COUNT(*) FROM DET_VENTASXRANGO GROUP BY Año, Mes

-------------------------- VARIANZA ---------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RES_VARIANZA]') AND type in (N'U'))
	DROP TABLE RES_VARIANZA

select Año, Mes, CanalyTiposOrden, Estado,  HoraInicial, SUM(Cantidad) Cantidad, ROUND(ISNULL(Var(Cantidad) ,0) , 2) Var_Cantidad, ROUND(ISNULL(STDEVP(Cantidad) ,0) , 2)cantidad_DesEst,0 Monto_SUM, 0 Monto_Varianza, 0 Monto_AVG, 0 Monto_DesEst
into RES_VARIANZA
--SELECT *
from RES_VENTASXRANGO V
--WHERE /*Fecha between  20210101  and 20210110 AND*/ CanalyTiposOrden = 'Amazon' AND Estado = 'Fulfilled'
GROUP BY Año, Mes,Estado,CanalyTiposOrden,  HoraInicial
ORDER BY Año, Mes,Estado,CanalyTiposOrden,  HoraInicial

UPDATE RES_VARIANZA SET 
 Monto_SUM      = ISNULL(X.Monto_SUM,0), 
 Monto_AVG      = ISNULL(X.Monto_AVG,0),  
 Monto_Varianza = ISNULL(X.Monto_Varianza,0) , 
 Monto_DesEst   = ISNULL(X.Monto_DesEst,0)   
--SELECT *
FROM RES_VARIANZA A
INNER JOIN (
	select  Año,  Mes, CanalyTiposOrden, Estado, HoraInicial, SUM(Monto) Monto_SUM, ROUND( AVG(Monto),2) Monto_AVG, ROUND(ISNULL(VAR(Monto) ,0) ,2) Monto_Varianza, ROUND(ISNULL(STDEVP(Monto) ,0),2) Monto_DesEst
	from DETALLE_VENTAS V
	INNER JOIN RANGOS_Hora H ON V.Hora BETWEEN H.HoraInicial AND HoraFinal
	--WHERE /*Fecha between  20210101  and 20210110 AND*/ CanalyTiposOrden = 'Amazon' AND Estado = 'Fulfilled'
	GROUP BY Año,Mes,Estado,CanalyTiposOrden,  HoraInicial
	--ORDER BY Estado,CanalyTiposOrden,  HoraInicial
)X
ON   X.Año             = A.Año 
AND  X.Mes             = A.Mes
AND  X.Estado          = A.Estado
AND  X.CanalyTiposOrden= A.CanalyTiposOrden
AND	 X.HoraInicial     = A.HoraInicial

/*
SELECT * FROM RES_VENTASXRANGO 
-- UPDATE RES_VENTASXRANGO  SET HoraInicial = HoraInicial - 2400
WHERE HoraInicial BETWEEN 2400 AND 2459


SELECT * FROM DET_VENTASXRANGO 
-- UPDATE DET_VENTASXRANGO  SET HoraInicial = HoraInicial - 2400
WHERE HoraInicial BETWEEN 2400 AND 2459
*/

/*
SELECT * FROM RES_VARIANZA
WHERE CanalyTiposOrden = 'Amazon' AND Estado = 'Fulfilled'
order by Mes, Estado, CanalyTiposOrden,HoraInicial
--ORDER BY  Mes, HoraInicial

select * from DET_VENTASXRANGO
*/

-------------------- media movil --------------------------------
/*
select  CanalyTiposOrden, Estado,  H.HoraInicial, AVG(Monto) Monto_AVG, COUNT(*) Cantidad
from DETALLE_VENTAS V
INNER JOIN RANGOS_Hora H ON V.Hora BETWEEN H.HoraInicial AND HoraFinal
GROUP BY Estado,CanalyTiposOrden,  H.HoraInicial
ORDER BY Estado,CanalyTiposOrden,  H.HoraInicial

*/
-------------------- cuartiles y percentiles --------------------------------
/*
SELECT DISTINCT Fecha, Estado, CanalyTiposOrden,
       --COUNT(*) AS Cantidad,
       PERCENTILE_CONT(0.25) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Fecha, Estado) AS [25%],
       PERCENTILE_CONT(0.5) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Fecha, Estado) AS [50%],
       PERCENTILE_CONT(0.75) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Fecha, Estado) AS [75%]
FROM [DETALLE_VENTAS]
--WHERE       
--GROUP BY CanalyTiposOrden, Fecha, Estado


SELECT DISTINCT  Estado, CanalyTiposOrden, --min(Fecha) Fecha_Min, max(Fecha) FechaMax,
       --COUNT(*) AS Cantidad,
       PERCENTILE_CONT(0.25) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [25%],
       PERCENTILE_CONT(0.5) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [50%],
       PERCENTILE_CONT(0.75) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [75%]
FROM [DETALLE_VENTAS]
--group by Estado, CanalyTiposOrden
order by Estado, CanalyTiposOrden
*/

/*
PERCENTILE_CONT returns the appropriate value, even if it doesn't exist in the data set.
PERCENTILE_DISC returns an actual set value.
*/

/*
SELECT DISTINCT  Estado, CanalyTiposOrden, --min(Fecha) Fecha_Min, max(Fecha) FechaMax,       
       PERCENTILE_CONT(0.25) 
           WITHIN GROUP(ORDER BY Cantidad) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [Cantidad 25%],
       PERCENTILE_CONT(0.5) 
           WITHIN GROUP(ORDER BY Cantidad) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [Cantidad 50%],
       PERCENTILE_CONT(0.75) 
           WITHIN GROUP(ORDER BY Cantidad) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [Cantidad 75%]	   
--select *
FROM [RESUMEN_VENTAS]
--group by Estado, CanalyTiposOrden
order by Estado, CanalyTiposOrden

SELECT DISTINCT  Estado, CanalyTiposOrden, --min(Fecha) Fecha_Min, max(Fecha) FechaMax,       
       PERCENTILE_CONT(0.25) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [Monto 25%],
       PERCENTILE_CONT(0.5) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [Monto 50%],
       PERCENTILE_CONT(0.75) 
           WITHIN GROUP(ORDER BY Monto) OVER (PARTITION BY CanalyTiposOrden, Estado) AS [Monto 75%]	   
FROM [RESUMEN_VENTAS]
order by Estado, CanalyTiposOrden
*/

--select * from DET_VENTASXRANGO