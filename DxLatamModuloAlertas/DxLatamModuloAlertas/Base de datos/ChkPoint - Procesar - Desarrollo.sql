DECLARE @FechaActual INT, @HoraActual INT, @HoraUltAnalisis INT, @HoraAnalisis INT, @HoraCompleta INT

SELECT @FechaActual= 20210201--CAST(CONVERT( NVARCHAR(10), GETDATE()  , 112 ) AS INT)
SELECT @HoraActual = DATEPART(HOUR,getdate()), @HoraUltAnalisis = 0
SELECT @HoraCompleta = @HoraActual *100 +  DATEPART(MINUTE,getdate()), @HoraUltAnalisis = 0

SELECT @FechaActual FechaActual, @HoraActual HoraActual


DECLARE
 @IdChkPoint        [varchar](10)
--,@FechaVigencia 	int         ,@HoraInicial  		int          ,@Descripicion     	[varchar](30)
,@sp_Validacion     [varchar](30)
,@IdMensaje 		[varchar](10)
,@MensajeInf		[varchar](10)
,@MensajSup 		[varchar](10)
,@UniRevision 		[varchar](10)
,@Periodicidad		tinyint      
--,@Estado   			[varchar](10)
,@HoraFinal  		int          
--,@EstadoLogico      [bigint]     

DECLARE ChkPoint_cursor CURSOR  
    FOR SELECT 
	 IdChkPoint 	/*,FechaVigencia	,HoraInicial	,Descripicion */
	,sp_Validacion	,IdMensaje 		,MensajeInf		,MensajSup 	
	,UniRevision	,Periodicidad	/*,Estado   		*/
	,HoraFinal  	/*,EstadoLogico */
	FROM [ALECHKPOINT] A
WHERE A.EstadoLogico =0  AND A.Estado = 'ACTIVO'  
OPEN ChkPoint_cursor  

FETCH NEXT FROM ChkPoint_cursor
INTO  @IdChkPoint   /* ,@FechaVigencia	 ,@HoraInicial   ,@Descripicion */
	 ,@sp_Validacion ,@IdMensaje 		 ,@MensajeInf	 ,@MensajSup 	
	 ,@UniRevision 	 ,@Periodicidad 	 /*,@Estado   	 */
	 ,@HoraFinal  	 /*,@EstadoLogico */

WHILE @@FETCH_STATUS = 0  
BEGIN  

	SELECT TOP 1 @HoraUltAnalisis = HoraHasta FROM [ALBITCHKPOINT] WITH(NOLOCK)
	WHERE [EstadoLogico] = 0 AND [Fecha] = @FechaActual AND [IdChkPoint] = @IdChkPoint AND [Hora] >= 0
	ORDER BY [EstadoLogico],[Fecha],[IdChkPoint] ,[HoraHasta] DESC

	-- SI ES LA PRIMERA VEZ NO HABRÁ REGISTRO EN BITÁCORA
	SELECT @HoraUltAnalisis = ISNULL(@HoraUltAnalisis,0)
	
	-- EMPEZAR DESDE LA ÚLTIMA HORA EVALUADA
	SELECT @HoraAnalisis = @HoraUltAnalisis
	
	SELECT @HoraAnalisis HoraAnalisis , @HoraUltAnalisis HoraUltAnalisis, @HoraActual HoraActual
	
	WHILE  @HoraAnalisis <= @HoraActual
	BEGIN

		-- INSERTAR ENCABEZADO DE BITÁCORA
		INSERT INTO [dbo].[ALBITCHKPOINT](			 
				[Fecha]			,[IdChkPoint]		,[Hora] 	    	,[HoraDesde]	
			,[HoraHasta] 		,[FechaInicial]		,[HoraInicial] 		,[FechaFinal]  
			,[HoraFinal]		,[ValDifMinimo]		,[ToleranciaInf]	,[ToleranciaSup]
			,[Accion]      		
		) 
		SELECT
			@FechaActual [Fecha]		
			, [IdChkPoint]	
			,@HoraCompleta    [Hora] 	    
			,@HoraUltAnalisis [HoraDesde]	
			,@HoraAnalisis    [HoraHasta] 	
			,[FechaInicial]
			,[HoraInicial] 
			,[FechaFinal]  
			,[HoraFinal]	
			,ValorDifMinimo     [ValDifMinimo]
			,ToleranciaInferior [ToleranciaInf]
			,ToleranciaSuperior [ToleranciaSup]
			,'' [Accion]  		
	    FROM  BuscaChkPoint (@IdChkPoint, @FechaActual, @HoraAnalisis)
		
		-- EVALUANDO INFORMACIÓN
		SELECT
			  CanalyTiposOrden  
			, Fecha , Hora, Predicion , Cantidad, Diferencia, Variacion, Deteccion         
			, ValorDifMinimo, ToleranciaInferior, ToleranciaSuperior
		INTO #RESULTADO
		FROM [ChkPoint_CantidadVentas] (@IdChkPoint,@FechaActual , @HoraAnalisis) 

		-- 1. INSERTAR REQUERIMIENTO DE ALERTA		
		INSERT INTO [ALESOLICITUD](	
			[Fecha]    ,[Hora]         
			,[IdMensaje],[Criterio]     
			,[Estado]   ,[DescError]    	
		) 
		SELECT
			Fecha      
		   ,Hora       
		   ,@IdMensaje [IdMensaje]  
		   , CASE WHEN Deteccion = 'MINIMO' THEN  @MensajeInf ELSE @MensajSup END [Criterio]   
		   ,'PENDIENTE' [Estado]     
		   ,'' [DescError]  
		FROM  #RESULTADO  

		-- 2. INSERTAR DETALLE BITÁCORA
		INSERT INTO [ALBIDETCHKPOINT](			 
			 [Fecha]		    
			,[IdChkPoint]	    
			,[Hora]	        
			,[CanalyTiposOrden]
			,[Accion]		    
			,[FechaModelo]	    
			,[HoraModelo]		
			,[Prediccion]		
			,[ValorReal]		
			,[Diferencia]		
			,[Variacion]       			
		) 

		SELECT 
			 [Fecha]		    
			,@IdChkPoint   [IdChkPoint]	    
			,@HoraCompleta [Hora]	        
			,[CanalyTiposOrden]
			,Deteccion [Accion]		    
			,@FechaActual  [FechaModelo]	    
			,@HoraAnalisis [HoraModelo]		
			,Predicion     [Prediccion]		
			,Cantidad      [ValorReal]		
			,[Diferencia]		
			,[Variacion]    
		FROM  #RESULTADO 

		DROP TABLE #RESULTADO
		SELECT @HoraAnalisis = @HoraAnalisis + 1
	
	END -- WHILE

	-- ACTUALIZAR ACCIONES RALIZADAS
	UPDATE ALBITCHKPOINT SET Accion = 'ALERTA'
	from [ALBITCHKPOINT] A
	inner join [ALBIDETCHKPOINT] B
		ON B.EstadoLogico = 0
		AND B.Fecha = A.Fecha
		AND B.Hora  = A.Hora

	FETCH NEXT FROM ChkPoint_cursor
    INTO  @IdChkPoint /*,@FechaVigencia	 ,@HoraInicial   ,@Descripicion*/ 
	 ,@sp_Validacion ,@IdMensaje 		 ,@MensajeInf	 ,@MensajSup 	
	 ,@UniRevision 	 ,@Periodicidad 	 /*,@Estado   	 */
	 ,@HoraFinal  	 /*,@EstadoLogico */
END
CLOSE ChkPoint_cursor;  
DEALLOCATE ChkPoint_cursor;



