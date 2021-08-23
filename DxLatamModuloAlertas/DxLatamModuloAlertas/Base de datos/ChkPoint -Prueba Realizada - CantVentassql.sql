-- TRUNCATE TABLE [ALBITCHKPOINT]
-- TRUNCATE TABLE [ALESOLICITUD]
-- TRUNCATE TABLE [ALBIDETCHKPOINT]

SELECT * FROM ALEALECHKPOINT WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO'  AND FechaVigencia <= 20210311

SELECT 'CONFIGURACION CHECK POINT'

SELECT * FROM ALECHKPOINT WHERE EstadoLogico = 0 
SELECT * FROM ALTCHKPOINT WHERE EstadoLogico = 0 
--AND FechaInicial = 0--20210203 
ORDER BY CanalyTiposOrden, HoraInicial

SELECT  *
FROM ALECHKPOINT
 --update  ALECHKPOINT set Estado = 'ACTIVO'
WHERE EstadoLogico = 0 AND Estado != 'ACTIVO'
--WHERE EstadoLogico = 0 AND FechaInicial = 0
ORDER BY Estado,CanalyTiposOrden, FechaInicial, HoraInicial 
-- UPDATE ALTCHKPOINT SET Estado = 'INACTIVO' WHERE EstadoLogico = 0 AND CanalyTiposOrden IN ('GoogleShopping','Google_Shopping', 'Shopify','Etail')
-- UPDATE ALTCHKPOINT SET EstadoLogico = IdRegistro WHERE EstadoLogico = 0 AND CanalyTiposOrden IN ('GoogleShopping','AmazonBusiness')

/*
SELECT CanalVenta, Hora/100 Hora, Count(*) FROM ALEORDENVENTA WHERE EstadoLogico = 0 AND Fecha = 20210202-- @FechaActual
GROUP BY CanalVenta, Hora/100 
ORDER BY CanalVenta, Hora/100 

SELECT CanalyTiposOrden, hour, prediction FROM PREDICCION WHERE EstadoLogico = 0 --AND date = @FechaActual
ORDER BY CanalyTiposOrden, hour
*/

SELECT ' - PRUEBA - '
DECLARE @FechaActual INT,  @HoraCompleta INT

SELECT @FechaActual= 20210201--CAST(CONVERT( NVARCHAR(10), GETDATE()  , 112 ) AS INT)
SELECT @HoraCompleta = DATEPART(HOUR,getdate()) *100 +  DATEPART(MINUTE,getdate())
SELECT @FechaActual FechaActual, @HoraCompleta HoraCompleta

SELECT 'EJECUCIÓN'
--EXEC ChkPoint_RealizarAnalisis @FechaActual , @HoraCompleta 

SELECT 'RESULTADOS'
select'ALBIDETCHKPOINT'
SELECT * 
FROM [ALBIDETCHKPOINT] WHERE EstadoLogico = 0 AND Fecha = @FechaActual 
ORDER BY Fecha, CanalyTiposOrden, Hora, HoraModelo, Accion

SELECT Fecha, CanalyTiposOrden, Accion, Count(*) 
FROM ALBIDETCHKPOINT WITH(NOLOCK) 
WHERE EstadoLogico = 0 AND Fecha = 20210201
GROUP BY Fecha,CanalyTiposOrden, Accion
ORDER BY Fecha,CanalyTiposOrden, Accion

SELECT Fecha, CanalyTiposOrden, HoraModelo , Prediccion, ValorReal
FROM ALBIDETCHKPOINT WITH(NOLOCK) 
WHERE EstadoLogico = 0 AND Fecha = 20210201
order by Fecha, CanalyTiposOrden, HoraModelo

SELECT Fecha, CanalVenta, Hora/100 Hora, COUNT(*) Cantidad 
FROM ALEORDENVENTA WHERE EstadoLogico = 0 AND Fecha = 20210201
group by Fecha, CanalVenta, Hora/100 
order by Fecha, CanalVenta, Hora/100 

Select date, hour, CanalyTiposOrden, prediction  
from PREDICCION
where EstadoLogico = 0 and date = 20210201


select'ALBITCHKPOINT'
SELECT * FROM [ALBITCHKPOINT] WHERE EstadoLogico = 0 AND Fecha = @FechaActual
ORDER BY Fecha, CanalyTiposOrden, Hora, HoraHasta, Accion

select'ALESOLICITUD'
SELECT * FROM [ALESOLICITUD]    WHERE EstadoLogico = 0 AND Fecha = @FechaActual
-- update [ALESOLICITUD] SET Estado = 'PENDIENTE'    WHERE EstadoLogico = 0 AND Fecha =20210202

/*
SELECT  date, hour, CanalyTiposOrden, prediction
FROM PREDICCION WHERE EstadoLogico = 0 
AND date = @FechaActual
ORDER BY CanalyTiposOrden,date


--SELECT * FROM ALEORDENVENTA WHERE EstadoLogico = 0 AND Fecha = @FechaActual
SELECT CanalyTiposOrden, Fecha, Hora/100 Hora, Count(*) Cantidad
FROM ALEORDENVENTA with(nolock)
WHERE EstadoLogico = 0
AND Fecha = @FechaActual
group by CanalyTiposOrden, Fecha, Hora/100
order by CanalyTiposOrden, Fecha, Hora/100

SELECT  date/100 Mes,CanalyTiposOrden, count(*) Horas,  count(*) /24 Dias
FROM PREDICCION WHERE EstadoLogico = 0 
--AND date = @FechaActual
GROUP BY date/100 ,CanalyTiposOrden
ORDER BY date/100 ,CanalyTiposOrden

*/

SELECT * FROM ALEORDENVENTA WHERE EstadoLogico = 0 AND Fecha = @FechaActual
SELECT * FROM PREDICCION WHERE EstadoLogico = 0 AND date = @FechaActual

SELECT  P.CanalyTiposOrden, P.date Fecha, P.hour Hora, P.prediction  Predicion, isnull(Sum(Cantidad),0) Cantidad, isnull(Sum(Cantidad),0) - P.prediction Diferencia, CASE WHEN P.prediction = 0 THEN 1.00 ELSE  round( (isnull(Sum(Cantidad),0)  - P.prediction)/P.prediction, 2) END Variacion
FROM PREDICCION P with(nolock)
LEFT JOIN (
		SELECT CanalyTiposOrden, Fecha, Hora/100 Hora, Count(*) Cantidad
		FROM ALEORDENVENTA with(nolock)
		WHERE EstadoLogico = 0
		AND Fecha = @FechaActual
	    group by CanalyTiposOrden, Fecha, Hora/100
)R
ON   P.date = R.Fecha
	AND  P.hour = R.Hora		
	AND  P.CanalyTiposOrden = R.CanalyTiposOrden	
WHERE P.date = @FechaActual
	AND P.EstadoLogico = 0
GROUP BY P.CanalyTiposOrden, P.date, P.hour, P.prediction

SELECT 'CORRER PROCEDIMIENTO'

go
/*
IdRegistro	IdChkPoint	CanalyTiposOrden	FechaInicial	HoraInicial	FechaFinal	HoraFinal	ValorDifMinimo	ToleranciaInferior	ToleranciaSuperior	Estado	EstadoLogico
1	CANTORD		0	0	0	23	5.00	0.40	0.40	ACTIVO	0
2	CANTORD		20210202	0	20210202	12	3.00	0.10	0.10	ACTIVO	0
3	CANTORD		20210202	13	20210202	23	7.00	0.20	0.20	ACTIVO	0
4	CANTORD		20210203	0	20210203	12	9.00	0.15	0.15	ACTIVO	0
5	CANTORD	Amazon	0	0	0	23	5.00	0.25	0.25	ACTIVO	0
6	CANTORD	Walmart	20210202	13	20210202	23	7.00	0.60	0.60	ACTIVO	0
*//*
DECLARE @prFecha INT,  @prHora INT

SELECT @prFecha= 20210201--CAST(CONVERT( NVARCHAR(10), GETDATE()  , 112 ) AS INT)
SELECT @prHora = DATEPART(HOUR,getdate()) --*100 +  DATEPART(MINUTE,getdate())

SELECT X.CanalyTiposOrden, Fecha, Hora, Predicion, Cantidad, Diferencia, Variacion
	    , CASE WHEN Variacion < 0 THEN 'MINIMO' ELSE 'MAXIMO' END Deteccion
		, ValorDifMinimo,ToleranciaInferior, ToleranciaSuperior
	FROM (	   
		SELECT  P.CanalyTiposOrden, P.date Fecha, P.hour Hora, P.prediction  Predicion, isnull(Sum(Cantidad),0) Cantidad, isnull(Sum(Cantidad),0) - P.prediction Diferencia, CASE WHEN P.prediction = 0 THEN 1.00 ELSE  round( (isnull(Sum(Cantidad),0)  - P.prediction)/P.prediction, 2) END Variacion
		FROM PREDICCION P with(nolock)
		LEFT JOIN (
					SELECT CanalyTiposOrden, Fecha, Hora/100 Hora, Count(*) Cantidad
					FROM ALEORDENVENTA with(nolock)
					WHERE EstadoLogico = 0
					AND Fecha = @prFecha
					--AND Hora/100 = @prHora 
					--AND Hora/100 BETWEEN @prHora AND @prHoraFin
					group by CanalyTiposOrden, Fecha, Hora/100
			)R
			ON   P.date = R.Fecha
			and  P.hour = R.Hora		
			AND  P.CanalyTiposOrden = R.CanalyTiposOrden	
		WHERE P.date = @prFecha
			AND P.EstadoLogico = 0
			--AND P.hour BETWEEN @prHora AND @prHoraFin
			--AND P.hour = @prHora 
		GROUP BY P.CanalyTiposOrden, P.date, P.hour, P.prediction		
	)X
	INNER JOIN BuscaChkPoint ('CANTORD', @prFecha, @prHora)
		W ON X.Hora  BETWEEN W.HoraInicial And W.HoraFinal
	AND ABS(Diferencia) >=  ValorDifMinimo 
	AND (( Variacion < 0 AND ToleranciaInferior <= ABS(Variacion))  OR ( Variacion >= 0 AND ToleranciaSuperior <= ABS(Variacion)))	
	AND ( X.CanalyTiposOrden = W.CanalyTiposOrden)-- OR  W.CanalyTiposOrden = ''  )
	ORDER BY CanalyTiposOrden, Fecha, Hora, Predicion
	*/