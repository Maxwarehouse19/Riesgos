/*
DECLARE @FechaActual INT, @HoraActual INT, @HoraUltAnalisis INT, @HoraAnalisis INT, @HoraCompleta INT

SELECT @FechaActual= 20210201--CAST(CONVERT( NVARCHAR(10), GETDATE()  , 112 ) AS INT)
SELECT @HoraActual = DATEPART(HOUR,getdate()), @HoraUltAnalisis = 0
SELECT @HoraCompleta = @HoraActual *100 +  DATEPART(MINUTE,getdate()), @HoraUltAnalisis = 0
SELECT @FechaActual FechaActual, @HoraActual HoraActual
*/
DROP PROCEDURE ChkPoint_RealizarAnalisis 
GO
CREATE PROCEDURE ChkPoint_RealizarAnalisis (@IdRegistro BIGINT,@FechaActual INT, @HoraCompleta INT)
AS
BEGIN
	-- CONVERSIONES INICIALES
	DECLARE  @HoraUltAnalisis INT, @HoraAnalisis INT, @HoraActual INT, @HoraUltCheck INT
	SELECT   @HoraActual = @HoraCompleta/100 , @HoraUltAnalisis = 0

	-- VARIABLES DE CURSOR
	DECLARE
	 @IdChkPoint        [varchar](10) ,@sp_Validacion   [varchar](30)
	,@IdMensaje 		[varchar](10) ,@MensajeInf		[varchar](10)
	,@MensajSup 		[varchar](10) ,@UniRevision 	[varchar](10)
	,@Periodicidad		tinyint       ,@HoraFinal  		int          

	-- CURSOR
	DECLARE ChkPoint_cursor CURSOR  
		FOR SELECT 
		 IdChkPoint 	,sp_Validacion	,IdMensaje 		,MensajeInf		,MensajSup 	
		,UniRevision	,Periodicidad	,HoraFinal  	
		FROM [ALECHKPOINT] A
	WHERE A.EstadoLogico =0  AND A.Estado = 'ACTIVO'  and IdRegistro = @IdRegistro
	OPEN ChkPoint_cursor  

	-- RECORRIENDO LOS PUNTOS DE VALIDACIÓN
	FETCH NEXT FROM ChkPoint_cursor
	INTO  @IdChkPoint   ,@sp_Validacion ,@IdMensaje 		 ,@MensajeInf	 ,@MensajSup 	
		 ,@UniRevision 	,@Periodicidad 	,@HoraFinal

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	    -- CUAL FUE EL ÚLTIMO REGISRO EVALUADO HOY
		SELECT TOP 1 @HoraUltAnalisis = HoraHasta , @HoraUltCheck = Hora FROM [ALBITCHKPOINT] WITH(NOLOCK)
		WHERE [EstadoLogico] = 0 AND [Fecha] = @FechaActual AND [IdChkPoint] = @IdChkPoint AND [Hora] >= 0
		ORDER BY [EstadoLogico],[Fecha],[IdChkPoint] ,[Hora] DESC

		-- Corresponde generar la información o no ha transcurrido el tiempo indicado
		IF ((@UniRevision = 'MINUTO' AND ( @HoraCompleta - @HoraUltCheck ) < @Periodicidad )
		   OR (@UniRevision = 'HORA' AND (( @HoraCompleta/100) - (@HoraUltCheck/100)) < @Periodicidad ))
		BEGIN
			SELECT 'RANGO DE TIEMPO NO ALCANZADO' Mensaje
			SELECT @FechaActual FechaActual, @IdChkPoint IdChkPoint, @HoraCompleta HoraCompleta, @HoraUltCheck HoraUltCheck, @Periodicidad Periodicidad,
			       @UniRevision UniRevision, @HoraCompleta - @HoraUltCheck TiempoTranscurrido
		END 
		ELSE
		BEGIN

			SELECT 'ANALIZANDO' Mensaje
			SELECT @FechaActual FechaActual, @IdChkPoint IdChkPoint, @HoraCompleta HoraCompleta, @HoraUltCheck HoraUltCheck, @Periodicidad Periodicidad,
			       @UniRevision UniRevision,@HoraCompleta - @HoraUltCheck TiempoTranscurrido

			-- SI ES LA PRIMERA VEZ NO HABRÁ REGISTRO EN BITÁCORA
			SELECT @HoraUltAnalisis = ISNULL(@HoraUltAnalisis,0)
	
			-- EMPEZAR DESDE LA ÚLTIMA HORA EVALUADA
			SELECT @HoraAnalisis = @HoraUltAnalisis
		
			WHILE  @HoraAnalisis <= @HoraActual
			BEGIN
				-- INSERTAR ENCABEZADO DE BITÁCORA
				INSERT INTO [dbo].[ALBITCHKPOINT](			 
					[Fecha]			,[IdChkPoint]		,[CanalyTiposOrden], [Hora]  	,[HoraDesde]	
					,[HoraHasta] 	,[FechaInicial]		,[HoraInicial] 		,[FechaFinal]  
					,[HoraFinal]	,[ValDifMinimo]		,[ToleranciaInf]	,[ToleranciaSup]
					,[Accion]      		
				) 
				SELECT 
					@FechaActual [Fecha]		
					, [IdChkPoint]	
					,[CanalyTiposOrden]
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
				SELECT CanalyTiposOrden , Fecha , Hora, Predicion , Cantidad, Diferencia, Variacion, Deteccion         
					, ValorDifMinimo, ToleranciaInferior, ToleranciaSuperior
				INTO #RESULTADO
				FROM [ChkPoint_CantidadVentas] (@IdChkPoint,@FechaActual , @HoraAnalisis) 			 

				-- INSERTAR REQUERIMIENTO DE ALERTA		
				INSERT INTO [ALESOLICITUD](	[Fecha]    ,[Hora]  ,[IdMensaje],[Criterio] ,[Estado],[Detalle],[DescError] ) 
				SELECT
					Fecha      
				   ,Hora       
				   ,@IdMensaje [IdMensaje]  
				   , CASE WHEN Deteccion = 'MINIMO' THEN  @MensajeInf ELSE @MensajSup END [Criterio]   
				   ,'PENDIENTE' [Estado] 
				   ,'Chan:' + CanalyTiposOrden +' Var:'+ CAST(Variacion*100 AS VARCHAR(10))+'% T:'+ Deteccion  [Detalle]
				   ,'' [DescError]  
				FROM  #RESULTADO  

				-- INSERTAR DETALLE BITÁCORA
				INSERT INTO [ALBIDETCHKPOINT]( [Fecha],[IdChkPoint] ,[Hora] ,[CanalyTiposOrden],[Accion]		    
					,[FechaModelo],[HoraModelo]	,[Prediccion],[ValorReal],[Diferencia],[Variacion]) 

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

				-- ELIMINANDO TABLA TEMPORAL
				DROP TABLE #RESULTADO
			
				-- SIGUIENTE HORA DE ANÁLISIS
				SELECT @HoraAnalisis = @HoraAnalisis + 1
	
			END -- WHILE

			-- ACTUALIZAR ACCIONES RALIZADAS
			UPDATE ALBITCHKPOINT SET Accion = 'ALERTA'
			from [ALBITCHKPOINT] A
			inner join [ALBIDETCHKPOINT] B
				ON B.EstadoLogico = 0
				AND B.Fecha = A.Fecha
				AND B.Hora  = A.Hora
				AND B.CanalyTiposOrden = A.CanalyTiposOrden
				AND B.HoraModelo  = A.HoraHasta
		END -- IF

		-- SIGUIENTE PUNTO DE REVISIÓN
		FETCH NEXT FROM ChkPoint_cursor
		INTO  @IdChkPoint ,@sp_Validacion ,@IdMensaje,@MensajeInf,@MensajSup 	
		 ,@UniRevision 	 ,@Periodicidad ,@HoraFinal 
	END
	-- CERRANDO Y ELIMINANDO CURSOR
	CLOSE ChkPoint_cursor;  
	DEALLOCATE ChkPoint_cursor;

END


