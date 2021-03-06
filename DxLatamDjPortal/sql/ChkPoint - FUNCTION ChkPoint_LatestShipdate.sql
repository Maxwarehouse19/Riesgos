USE [MaxWarehouse]
GO
/****** Object:  StoredProcedure [dbo].[ChkPoint_ShippingLate]    Script Date: 6/11/2021 9:24:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM ALEMENSAJE
-- SELECT * FROM ALECHKPOINT
-- select TOP 5 * FROM ALESOLICITUD ORDER BY IdRegistro DESC
--EXEC ChkPoint_LatestShipdate 9,20210625,1244
-- DROP PROCEDURE [dbo].[ChkPoint_LatestShipdate]
ALTER PROCEDURE [dbo].[ChkPoint_LatestShipdate](@IdRegistro BIGINT,@FechaActual INT, @HoraCompleta INT)	
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
	,@CountSKUant INT

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
		SELECT TOP 1 @HoraUltAnalisis = HoraHasta , @HoraUltCheck = Hora , @CountSKUant = ValDifMinimo FROM [ALBITCHKPOINT] WITH(NOLOCK)
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
			
			DECLARE @strFechaActual varchar(8), @datFechaActual date, @RepConfig INT
			select @strFechaActual=ltrim(rtrim(str(@FechaActual)))
			select @datFechaActual =CAST(dateadd(day,0, @strFechaActual)AS DATE)
			
			EXEC LatestShipdate_DistribucionDias @Fecha = @datFechaActual
			exec PROC_LatestshipdateSKU @Fecha = @datFechaActual
		
			select @RepConfig = valint from home_staticparams where modulo = 'LShipdate' and nombre = 'MaxSKU'
		
			DECLARE @CountSKU INT, @MaxSKUCode VARCHAR(30), @MaxSKUQuantity INT, @Texto VARCHAR(150)

			--<Latest Shipdate>: 63 SKU 'EJD-4839262' (63)
			SELECT @CountSKU = count(*) FROM LatestshipdateSKU 
			WHERE DATEDIFF(DAY, FechaIngreso, @datFechaActual) = 0 and Cantidad > @RepConfig
		
			SELECT top 1 @MaxSKUCode  = SKU,  @MaxSKUQuantity = Cantidad
			FROM LatestshipdateSKU WHERE DATEDIFF(DAY, FechaIngreso, @datFechaActual) = 0
			ORDER BY Cantidad DESC

			IF @CountSKU = @CountSKUant 
			BEGIN 
				SELECT 'SIN CAMBIOS' Mensaje	
			END
			ELSE
			BEGIN
				SELECT 'ANALIZANDO' Mensaje	
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
					,'LatestShipdate'
					,@HoraCompleta    [Hora] 	    
					,0  [HoraDesde]	
					,0  [HoraHasta] 	
					,0  [FechaInicial]
					,0  [HoraInicial] 
					,0  [FechaFinal]  
					,0  [HoraFinal]	
					,@CountSKU  [ValDifMinimo]
					,0  [ToleranciaInf]
					,0  [ToleranciaSup]
					,'' [Accion]  

				SELECT @Texto = '<Latest Shipdate>:'+LTRIM(RTRIM(STR(@CountSKU)))+' SKU con mas de '+LTRIM(RTRIM(@RepConfig))+' repeticiones. El mas repetido es: '+LTRIM(RTRIM(@MaxSKUCode))+' con '+LTRIM(RTRIM(STR(@MaxSKUQuantity)))+' repeticiones'
				-- INSERTAR REQUERIMIENTO DE ALERTA		
				INSERT INTO [ALESOLICITUD](	[Fecha]    ,[Hora]  ,[IdMensaje],[Criterio] ,[Estado],[Detalle],[DescError] ) 
				SELECT
					@FechaActual   [Fecha]      
					,@HoraCompleta [Hora]       
					,@IdMensaje    [IdMensaje]  
					, @MensajeInf  [Criterio]   
					,'PENDIENTE'   [Estado] 
					,@Texto	 	   [Detalle]
					,'' [DescError]  
            
				-- INSERTAR DETALLE BITÁCORA
				INSERT INTO [ALBIDETCHKPOINT]( [Fecha],[IdChkPoint] ,[Hora] ,[CanalyTiposOrden],[Accion]		    
					,[FechaModelo],[HoraModelo]	,[Prediccion],[ValorReal],[Diferencia],[Variacion]) 

				SELECT 
					@FechaActual		    
					,@IdChkPoint   [IdChkPoint]	    
					,@HoraCompleta [Hora]	        
					,'LatestShipdate' [CanalyTiposOrden]
					,'' [Accion]		    
					,@FechaActual  [FechaModelo]	    
					,0 [HoraModelo]		
					,0 [Prediccion]		
					,@CountSKU [ValorReal]		
					,0 [Diferencia]		
					,0 [Variacion]    					

				-- ACTUALIZAR ACCIONES RALIZADAS
				UPDATE ALBITCHKPOINT SET Accion = 'ALERTA'
				from [ALBITCHKPOINT] A
				inner join [ALBIDETCHKPOINT] B
					ON B.EstadoLogico = 0
					AND B.Fecha = A.Fecha
					AND B.Hora  = A.Hora
					AND B.CanalyTiposOrden = A.CanalyTiposOrden
					AND B.HoraModelo  = A.HoraHasta
				where A.Fecha =	@FechaActual   
				AND   A.Hora  = @HoraCompleta 
				AND   A.CanalyTiposOrden = 'LatestShipdate'
				--------------------
			END
		END
	END	
END