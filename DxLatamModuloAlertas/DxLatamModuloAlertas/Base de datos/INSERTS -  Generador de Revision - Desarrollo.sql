-- TRUNCATE TABLE ALECHKPOINT
insert into  [ALECHKPOINT](	
	 [IdChkPoint]      
	,[FechaVigencia] 	
	,[HoraInicial]		
	,[Descripicion]    
	,[sp_Validacion]   
	,[IdMensaje]		
	,[MensajeInf]		
	,[MensajSup]		
	,[UniRevision]		
	,[Periodicidad]		
	,[Estado]			
	,[HoraFinal]  			
) 
     
SELECT 
	 'CANTORD'                [IdChkPoint]      
	,20210101                 [FechaVigencia] 	
	,0                        [HoraInicial]		
	,'Cantidad de Ventas'     [Descripicion]    
	,'ChkPoint_RealizarAnalisis'[sp_Validacion]   
	,'CANTORDEN'              [IdMensaje]		
	,'MINORDEN'               [MensajeInf]		
	,'MAXORDEN'               [MensajSup]		
	,'MINUTO'                 [UniRevision]		
	, 15                      [Periodicidad]		
	,'ACTIVO'                 [Estado]			
	,2359                     [HoraFinal]  	

-- truncate table [ALTCHKPOINT]	
INSERT INTO [ALTCHKPOINT](	
	 [IdChkPoint]    
	,[CanalyTiposOrden]    --** personalización por canal de venta
	,[FechaInicial]		   
	,[HoraInicial]		   
	,[FechaFinal]		   
	,[HoraFinal]		   
	,[ValorDifMinimo]	   
	,[ToleranciaInferior]  
	,[ToleranciaSuperior]  	 
	,[Estado]              --** personalización por canal de venta
) 
SELECT 	 'CANTORD' [IdChkPoint]  
    ,[CanalyTiposOrden] -- para todos
	,0 [FechaInicial]		   
	,0 [HoraInicial]		   
	,0 [FechaFinal]		   
	,23[HoraFinal]		   
	,5 [ValorDifMinimo]	   
	,0.40 [ToleranciaInferior]  
	,0.40[ToleranciaSuperior]  	 
	,'ACTIVO'  [Estado]
FROM (
	select CanalyTiposOrden from PREDICCION group by CanalyTiposOrden
)X
UNION
SELECT 	 'CANTORD' [IdChkPoint]        
    ,[CanalyTiposOrden] -- para todos
	,20210202 [FechaInicial]		   
	,0 [HoraInicial]		   
	,20210202 [FechaFinal]		   
	,12[HoraFinal]		   
	,3 [ValorDifMinimo]	   
	,0.10 [ToleranciaInferior]  
	,0.10[ToleranciaSuperior]  	 
	,'ACTIVO'  [Estado]
FROM (
	select CanalyTiposOrden from PREDICCION group by CanalyTiposOrden
)X
UNION
SELECT 	 'CANTORD' [IdChkPoint]   
    ,[CanalyTiposOrden] -- para todos
	,20210202 [FechaInicial]		   
	,13 [HoraInicial]		   
	,20210202 [FechaFinal]		   
	,23[HoraFinal]		   
	,7 [ValorDifMinimo]	   
	,0.2 [ToleranciaInferior]  
	,0.2[ToleranciaSuperior]
	,'ACTIVO'  [Estado]
FROM (
	select CanalyTiposOrden from PREDICCION group by CanalyTiposOrden
)X
union
SELECT 	 'CANTORD' [IdChkPoint]        
    ,[CanalyTiposOrden] -- para todos
	,20210203 [FechaInicial]		   
	,0 [HoraInicial]		   
	,20210203 [FechaFinal]		   
	,12[HoraFinal]		   
	,9 [ValorDifMinimo]	   
	,0.15 [ToleranciaInferior]  
	,0.15[ToleranciaSuperior] 
	,'ACTIVO'  [Estado]
FROM (
	select CanalyTiposOrden from PREDICCION group by CanalyTiposOrden
)X

	
	--DECLARE @ValorDifMinimo DECIMAL(7,2), @ToleranciaInferior DECIMAL(7,2), @ToleranciaSuperior DECIMAL(7,2)
	select *
	from (
		SELECT FechaInicial, HoraInicial, HoraFinal,  [ValorDifMinimo] , [ToleranciaInferior], [ToleranciaSuperior]
		FROM [ALTCHKPOINT] WITH(NOLOCK)
		WHERE EstadoLogico = 0 And [IdChkPoint] = 'CANTORD' 
		AND ((FechaInicial =  0 and HoraInicial >= 0 and HoraFinal >= 0)
			 OR (20210201 BETWEEN FechaInicial AND FechaFinal )--and (HoraInicial <= 11) and (HoraFinal >= 11))
		)
	) x
	--where 11 between HoraInicial and HoraFinal
	
	
-- -> leer SALEORDERS -> TABLA (DTS) 
-- -> Correr sp ->si corresponde insertar en tabla ALERTAS<-- BDD
-- -> ALERTA (.NET) Leer tabla requerimientos 

-- --> Conocer el último registro validado y apartir de ahí volver a validar.
-- --> manejo de excepciones TRY CATCH
/*
--ALECHKPOINT -- Maestro de checkpoint -- pantalla
IdChkPoint  Nombre                sp_Validacion             IdMensaje     MensajeInf  MensajSup   UniRevision  Periodicidad  Estado    FechaVigencia  HoraInicial   HoraFinal
'CANTORD'   'Cantidad de Ventas'  'ChkPoint_CantidadVentas' 'CANTORDEN'  'MINORDEN'   'MAXORDEN'   'MINUTO'        15         'ACTIVO'   20210101        0000          2359

--ALTCHKPOINT -- Detalle de checkpoint -- pantalla -- poder callar la alerta
IdChkPoint  FechaInicial   FechaFinal     HoraInicial  HoraFinal ValorDifMinimo   ToleranciaInferior  ToleranciaSuperior 
'CANTORD'    0               0             0            23              10                0.4               0.4             -- << DEFAULT
'CANTORD'    20210214       20210214       0            23               5                0.3               0.6             -- << fecha especial todo el día
'CANTORD'    20210405       20210412       0            23               2                0.2               0.6             -- << fecha especial todo el día
'CANTORD'    20210704       20210704       14           14               2                0.2               0.6             -- << fecha especial hora específica

--ALBITCHKPOINT -- Bitácora de checkpoint -- reporte
Fecha      IdChkPoint HoraLectura  HoraDesde  HoraHasta    FechaInicial   FechaFinal     HoraInicial  HoraFinal ValDifMinimo ToleranciaInf ToleranciaSup  Accion
20210201    'CANTORD' 1100           0100        1045         0               0             0            23            10        0.4           0.4        'MAXIMO'  <-- alerta por max
20210201    'CANTORD' 1100           0100        1045         0               0             0            23            10        0.4           0.4        'MÍNIMO'  <-- alerta por min
20210201    'CANTORD' 1100           0100        1045         0               0             0            23            10        0.4           0.4        'NINGUNO' <-- sin alerta

--ALBIDETCHKPOINT - Detalle de bitácora  -- reporte
 Fecha      IdChkPoint  HoraLectura  Accion     CanalyTiposOrden  FechaModelo HoraModelo  Prediccion  ValorReal	Diferencia	Variacion
 20210201    'CANTORD'    1100       'MAXIMO'   'Amazon'     	  20210201	   10	       125.00       186 	   61.00	   0.430
 20210201    'CANTORD'    1100       'MÍNIMO'   'Amazon'     	  20210201	   11	       198.00	    137	      -61.00	  -0.410
 --20210201   1100  'CANTORD'   'NINGUNO'    'Amazon'     	  20210201	       11	     135.00	       133	     - 2.00	      -0.015  -- << Guardar solo los que generan mensaje?

--ALEULTCHEQUEO
IdChkPoint  Fecha     Hora  UltFecha  UltHora UltEstado   Cantidad
 'CANTORD'  20210101  1110  20210101  1030    'PROCESADO'    0
 */
	select *
	from (
		SELECT  P.CanalyTiposOrden, P.date Fecha, P.hour Hora, P.prediction  Predicion, isnull(Sum(Cantidad),0) Cantidad, isnull(Sum(Cantidad),0) - P.prediction Diferencia, CASE WHEN P.prediction = 0 THEN 1.00 ELSE  round( (isnull(Sum(Cantidad),0)  - P.prediction)/P.prediction, 2) END Variacion
		FROM PREDICCION P with(nolock)
		LEFT JOIN (
					SELECT CanalyTiposOrden, Fecha, Hora/100 Hora, Count(*) Cantidad
					FROM ALEORDENVENTA with(nolock)
					WHERE EstadoLogico = 0
					AND Fecha = 20210201
					--AND Hora/100 = 11 
					--AND Hora/100 BETWEEN @prHora AND @prHoraFin
					group by CanalyTiposOrden, Fecha, Hora/100
			)R
			ON   P.date = R.Fecha
			and  P.hour = R.Hora		
			AND  P.CanalyTiposOrden = R.CanalyTiposOrden	
		WHERE P.date = 20210201
			AND P.EstadoLogico = 0		
			--AND P.hour BETWEEN @prHora AND @prHoraFin
			--AND P.hour = 11 
		GROUP BY P.CanalyTiposOrden, P.date, P.hour, P.prediction		
	)X
	where Variacion <0
	order BY CanalyTiposOrden, Fecha, Hora, Predicion	




-- select * from [ALTCHKPOINT]