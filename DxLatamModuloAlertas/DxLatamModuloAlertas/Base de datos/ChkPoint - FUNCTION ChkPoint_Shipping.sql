USE [MaxWarehouse]
GO
/****** Object:  StoredProcedure [dbo].[ChkPoint_Shipping]    Script Date: 6/2/2021 7:29:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM ALECHKPOINT WHERE 

--SELECT * FROM [ALBITCHKPOINT] ORDER BY IdRegistro DESC
--SELECT * FROM ALBIDETCHKPOINT ORDER BY IdRegistro DESC

--SELECT * FROM ALESOLICITUD ORDER BY IdRegistro DESC

/*
SELECT * FROM ALBIDETCHKPOINT 
-- UPDATE ALBIDETCHKPOINT SET EstadoLogico = IdRegistro
where EstadoLogico = 0 AND IdChkPoint = 'SHIPING'

SELECT * FROM ALBITCHKPOINT 
-- UPDATE ALBITCHKPOINT SET EstadoLogico = IdRegistro
where EstadoLogico = 0 AND IdChkPoint = 'SHIPING'

*/
--EXEC ChkPoint_Shipping 40004,20210514,1234

ALTER PROCEDURE [dbo].[ChkPoint_Shipping](@IdRegistro BIGINT,@FechaActual INT, @HoraCompleta INT)	
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
	,@FechaReporte      datetime

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

	-- CERRANDO Y ELIMINANDO CURSOR
	CLOSE ChkPoint_cursor;  
	DEALLOCATE ChkPoint_cursor;


	IF @@FETCH_STATUS = 0  
	BEGIN  		

	    -- CUAL FUE EL ÚLTIMO REGISRO EVALUADO HOY
		SELECT TOP 1 @HoraUltAnalisis = HoraHasta , @HoraUltCheck = Hora FROM [ALBITCHKPOINT] WITH(NOLOCK)
		WHERE [EstadoLogico] = 0 AND [Fecha] = @FechaActual AND [IdChkPoint] = @IdChkPoint AND [Hora] >= 0
		ORDER BY [EstadoLogico],[Fecha],[IdChkPoint] ,[Hora] DESC

		SELECT TOP 1 @FechaReporte = FechaInsercion
		FROM ReporteInconsistenciasCarrier			
		WHERE CAST(CONVERT(varchar,FechaInsercion,112) AS INT) = @FechaActual		

		IF (ISNULL(@FechaReporte,-1) < 0)
		BEGIN
			SELECT 'NO SE ENCONTRÓ INFORMACIÓN' Mensaje		
		END
		-- Corresponde generar la información o no ha transcurrido el tiempo indicado
		ELSE IF (ISNULL(@HoraUltCheck,-1) > 0)
		BEGIN
			SELECT 'PROCESO YA FUE EJECUTADO' Mensaje		
		END 
		ELSE
		BEGIN
		    SELECT 'EJECUCIÓN ÚNICA' Mensaje		

			-- INSERTAR ENCABEZADO DE BITÁCORA
			INSERT INTO [dbo].[ALBITCHKPOINT](			 
				[Fecha]			,[IdChkPoint]		,[CanalyTiposOrden], [Hora]  	,[HoraDesde]	
				,[HoraHasta] 	,[FechaInicial]		,[HoraInicial] 		,[FechaFinal]  
				,[HoraFinal]	,[ValDifMinimo]		,[ToleranciaInf]	,[ToleranciaSup]
				,[Accion]      		
			) 
			SELECT 
				@FechaActual [Fecha]		
				,@IdChkPoint	
				,'RepReqVsActual'
				,@HoraCompleta    [Hora] 	    
				,0  [HoraDesde]	
				,0  [HoraHasta] 	
				,0  [FechaInicial]
				,0  [HoraInicial] 
				,0  [FechaFinal]  
				,0  [HoraFinal]	
				,0  [ValDifMinimo]
				,0  [ToleranciaInf]
				,0  [ToleranciaSup]
				,'' [Accion]  		

			SELECT 
			 'RepReqVsActual'	CanalyTiposOrden  
			, @FechaActual			Fecha             
			, @HoraCompleta			Hora              
			, 0					Predicion         
			, COUNT(*)			Cantidad          
			, SUM(CASE WHEN ISNULL(EsNuevo,4) = 0 THEN 1 ELSE 0 END )	Diferencia        
			, 0					Variacion         
			, CambioServicio	Deteccion         
			, 0                 ValorDifMinimo    
			, 0                 ToleranciaInferior
			, 0                 ToleranciaSuperior
			, 0                 ValorDifMaximo    
			INTO #RESULTADO
			--select * 
			FROM ReporteInconsistenciasCarrier			
			WHERE CAST(CONVERT(varchar,FechaInsercion,112) AS INT) = @FechaActual
			GROUP BY CambioServicio
			HAVING COUNT(*) > 0

			-- INSERTAR REQUERIMIENTO DE ALERTA		
			INSERT INTO [ALESOLICITUD](	[Fecha]    ,[Hora]  ,[IdMensaje],[Criterio] ,[Estado],[Detalle],[DescError] ) 
			SELECT
				Fecha      
				,Hora       
				,@IdMensaje   [IdMensaje]  
				, @MensajeInf [Criterio]   
				,'PENDIENTE'  [Estado] 
				,'Alertas MaxWarehouse: Service Level Mismatch: '+ CAST(Cantidad AS VARCHAR(10))
				+' Nuevos: '+ CAST(Diferencia AS VARCHAR(10)) [Detalle]
				,'' [DescError]  
            -- SELECT *
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
				,0 [HoraModelo]		
				,Predicion     [Prediccion]		
				,Cantidad      [ValorReal]		
				,[Diferencia]		
				,[Variacion]    
			FROM  #RESULTADO 

			-- ELIMINANDO TABLA TEMPORAL
			DROP TABLE #RESULTADO
			
			-- ACTUALIZAR ACCIONES RALIZADAS
			UPDATE ALBITCHKPOINT SET Accion = 'ALERTA'
			from [ALBITCHKPOINT] A
			inner join [ALBIDETCHKPOINT] B
				ON B.EstadoLogico = 0
				AND B.Fecha = A.Fecha
				AND B.Hora  = A.Hora
				AND B.CanalyTiposOrden = A.CanalyTiposOrden
				AND B.HoraModelo  = A.HoraHasta
			--------------------
		END	
	END
END