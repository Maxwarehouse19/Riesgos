USE [MaxWarehouse]
GO
/****** Object:  StoredProcedure [dbo].[ChkPoint_Shipping]    Script Date: 6/2/2021 7:29:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM ALEMENSAJE
-- select TOP 5 * FROM ALESOLICITUD ORDER BY IdRegistro DESC
--EXEC ChkPoint_ShippingLate 50003,20210601,1234
-- DROP PROCEDURE [dbo].[ChkPoint_ShippingLate]
CREATE PROCEDURE [dbo].[ChkPoint_ShippingLate](@IdRegistro BIGINT,@FechaActual INT, @HoraCompleta INT)	
AS
BEGIN
	-- CONVERSIONES INICIALES
	DECLARE  @HoraUltAnalisis INT, @HoraAnalisis INT, @HoraActual INT, @HoraUltCheck INT
	DECLARE  @Texto varchar(100)
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

		SELECT @Texto = dbo.MensajeAmazonLate(GETDATE())		

		IF (ISNULL(@Texto,'*') = '*')
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
				,'AmazonLate'
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
				,Channel       [CanalyTiposOrden]
				,'AmazonLate' [Accion]		    
				,@FechaActual  [FechaModelo]	    
				,0 [HoraModelo]		
				,SUM(ISNULL(Tarde, 0))     [Prediccion]		
				,SUM(ISNULL(Total, 0))     [ValorReal]		
				,0 [Diferencia]		
				,0 [Variacion]    			
			from RESUMENINSIGHTLATE 
			WHERE day(FechaIngreso)	= day(getdate()) 
				 and	month(FechaIngreso) = month(getdate()) 
				 and	year(FechaIngreso)	= year(getdate())
			GROUP BY Channel

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