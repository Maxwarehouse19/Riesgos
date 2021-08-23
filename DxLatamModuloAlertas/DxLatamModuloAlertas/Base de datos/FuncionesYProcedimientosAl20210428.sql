USE [MaxWarehouse]
GO
/****** Object:  UserDefinedFunction [dbo].[BuscaChkPoint]    Script Date: 4/28/2021 4:13:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[BuscaChkPoint] (@IdChkPoint char(10), @Fecha INT, @Hora INT)
RETURNS @tblChkPoint TABLE (
	 [IdChkPoint]          [varchar](10) not null -- [ALECHKPOINT].IdChkPoint
	,[CanalyTiposOrden]    [varchar](30) not null -- Segregando configuración por canal y tipo de venta
	,[FechaInicial]		   int           not null -- Formato CCYYMMDD
	,[HoraInicial]		   int           not null -- Formato HHMMSSMM
	,[FechaFinal]		   int           not null -- Formato CCYYMMDD	
	,[HoraFinal]		   int           not null -- Formato HHMMSSMM
	,[ValorDifMinimo]	   decimal (7,2) not null -- Mínima cantidad de diferencia antes de evaluar rango de tolerancia 
	,[ToleranciaInferior]  decimal (7,2) not null -- %diferencia inferior
	,[ToleranciaSuperior]  decimal (7,2) not null -- %diferencia superior	
	,[ValorDifMaximo]	   decimal (7,2) not null -- Máxima cantidad de diferencia antes de evaluar rango de tolerancia 
)
AS
BEGIN
	DECLARE @FechaEspecial INT	

	-- ¿Hay configuración especial para la fecha enviada?
	SELECT @FechaEspecial = COUNT(*)
		FROM [ALTCHKPOINT] WITH(NOLOCK)
		WHERE EstadoLogico = 0 AND Estado = 'ACTIVO'
		And [IdChkPoint] = @IdChkPoint
		AND (@Fecha BETWEEN FechaInicial AND FechaFinal )
		AND  (@Hora BETWEEN HoraInicial AND CASE WHEN HoraFinal = 0 THEN 23 ELSE HoraFinal END)

	INSERT INTO @tblChkPoint
	select IdChkPoint, CanalyTiposOrden, FechaInicial, 
		HoraInicial, FechaFinal,  HoraFinal, [ValorDifMinimo] , [ToleranciaInferior], [ToleranciaSuperior],[ValorDifMaximo]
	FROM (
		SELECT IdChkPoint,CanalyTiposOrden, FechaInicial, FechaFinal, 
		HoraInicial, CASE WHEN HoraFinal = 0 THEN 23 ELSE HoraFinal END HoraFinal, [ValorDifMinimo] , [ToleranciaInferior], [ToleranciaSuperior],
		[ValorDifMaximo]
		FROM [ALTCHKPOINT] WITH(NOLOCK)
		WHERE ISNULL(@FechaEspecial,0) > 0 -- FECHA CON CONDICIÓN ESPECIAL
		AND EstadoLogico = 0 AND Estado = 'ACTIVO'
		And [IdChkPoint] = @IdChkPoint
		AND (@Fecha BETWEEN FechaInicial AND FechaFinal )
		AND  (@Hora BETWEEN HoraInicial AND CASE WHEN HoraFinal = 0 THEN 23 ELSE HoraFinal END)
		UNION
		SELECT IdChkPoint, CanalyTiposOrden,FechaInicial, FechaFinal, 
		HoraInicial, CASE WHEN HoraFinal = 0 THEN 23 ELSE HoraFinal END HoraFinal, [ValorDifMinimo] , [ToleranciaInferior], [ToleranciaSuperior],
		ValorDifMaximo
		FROM [ALTCHKPOINT] WITH(NOLOCK)
		WHERE ISNULL(@FechaEspecial,0) = 0 
		AND EstadoLogico = 0 AND Estado = 'ACTIVO'
		And [IdChkPoint] = @IdChkPoint
		AND (FechaInicial = 0) -- DEFAULT
		AND  (@Hora BETWEEN HoraInicial AND CASE WHEN HoraFinal = 0 THEN 23 ELSE HoraFinal END)
	)W
RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[ChkPoint_CantidadVentas]    Script Date: 4/28/2021 4:13:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ChkPoint_CantidadVentas](@ChkPoint varchar(10), @prFecha Int, @prHora INT)
	RETURNS @Analisis TABLE (
		  CanalyTiposOrden   varchar(30)
		, Fecha              int
		, Hora               int
		, Predicion          int
		, Cantidad           int
		, Diferencia         int
		, Variacion          decimal(7,2)
	    , Deteccion          varchar(10)
		, ValorDifMinimo     decimal(7,2)
		, ToleranciaInferior decimal(7,2)
		, ToleranciaSuperior decimal(7,2)
		, ValorDifMaximo     decimal(7,2)
	)
AS
begin

	
	-- % de variación entre dos valores
	-- https://www.disfrutalasmatematicas.com/numeros/porcentaje-diferencia.html#:~:text=Respuesta%20(M%C3%A9todo%202)%3A,decir%20un%20aumento%20de%2020%25.

	INSERT INTO @Analisis

	SELECT X.CanalyTiposOrden, Fecha, Hora, Predicion, Cantidad, Diferencia, Variacion
	    , CASE WHEN Variacion < 0 THEN 'MINIMO' ELSE 'MAXIMO' END Deteccion
		, ValorDifMinimo,ToleranciaInferior, ToleranciaSuperior, ValorDifMaximo
	FROM (	   
		SELECT  P.CanalyTiposOrden, P.date Fecha, P.hour Hora, P.prediction  Predicion, isnull(Sum(Cantidad),0) Cantidad, 
		isnull(Sum(Cantidad),0) - CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END  Diferencia
		, CASE WHEN CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END = 0 THEN 1.00 
		ELSE  round( (isnull(Sum(Cantidad),0)  - CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END)/CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END, 2) END Variacion
		FROM PREDICCION P with(nolock)
		LEFT JOIN (
					SELECT CanalyTiposOrden, Fecha, Hora/100 Hora, Count(*) Cantidad
					FROM ALEORDENVENTA with(nolock)
					WHERE EstadoLogico = 0
					AND Fecha = @prFecha
					AND Hora/100 = @prHora 
					--AND Hora/100 BETWEEN @prHora AND @prHoraFin
					group by CanalyTiposOrden, Fecha, Hora/100
			)R
			ON   P.date = R.Fecha
			and  P.hour = R.Hora		
			AND  P.CanalyTiposOrden = R.CanalyTiposOrden	
		WHERE P.date = @prFecha
			AND P.EstadoLogico = 0
			--AND P.hour BETWEEN @prHora AND @prHoraFin
			AND P.hour = @prHora 
		GROUP BY P.CanalyTiposOrden, P.date, P.hour, P.prediction		
	)X
	INNER JOIN BuscaChkPoint (@ChkPoint, @prFecha, @prHora)
		W ON X.Hora  BETWEEN W.HoraInicial And W.HoraFinal	
	AND (( Variacion < 0 AND ToleranciaInferior < ABS(Variacion) AND ABS(Diferencia) >  ValorDifMinimo ) 
			OR ( Variacion >= 0 AND ToleranciaSuperior < ABS(Variacion) AND ABS(Diferencia) >  ValorDifMaximo ))	
	AND X.CanalyTiposOrden = W.CanalyTiposOrden
	ORDER BY CanalyTiposOrden, Fecha, Hora, Predicion
	RETURN
end

GO
/****** Object:  UserDefinedFunction [dbo].[ChkPoint_CantidadVentas2]    Script Date: 4/28/2021 4:13:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
INSERT INTO ALEORDENVENTA(Fecha,Hora,CanalVenta,TiposOrdenVenta,CanalyTiposOrden,Estado,Moneda,Monto,Año,Mes,Dia,SKU,EstadoLogico)
SELECT Fecha + 200 ,Hora,CanalVenta,TiposOrdenVenta,CanalyTiposOrden,Estado,Moneda,Monto,Año, 'ABRIL' Mes,Dia, 'PRUEBAS' SKU,EstadoLogico
FROM ALEORDENVENTA with(nolock) WHERE EstadoLogico = 0 AND Fecha = 20210215 AND Hora BETWEEN 801 AND 900

--select * FROM ALECHKPOINT
--select * FROM ALTCHKPOINT WHERE EstadoLogico = 0
--select CanalyTiposOrden  FROM PREDICCION  WHERE EstadoLogico = 0 GROUP BY CanalyTiposOrden 

SELECT date, Variacion,  varToleranciaInferior * -1 varToleranciaInferior, varToleranciaSuperior FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210202,'Amazon') order by Hora

select * from ALEBITACORA
select * from ALBITCHKPOINT
select * from ALBIDETCHKPOINT

select * from ALEBITACORA

select Fecha, IdMensaje,Criterio, Estado , count(*) cantidad
from ALESOLICITUD with(nolock) 
where EstadoLogico = 0 AND Fecha = 20210201
group by Fecha, IdMensaje,Criterio, Estado


select *  FROM PREDICCION  WHERE EstadoLogico = 0 and date = 20210413
SELECT CanalyTiposOrden , date, Prediccion, ToleranciaInferior ['Tolerancia Inferior'], ToleranciaSuperior ['Tolerancia Superior']
, Cantidad REAL FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'Amazon-AmazonBusiness') order by Hora

SELECT  Deteccion category, sum(Cantidad) cantidad FROM ( SELECT Deteccion, Cantidad FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'Amazon-AmazonBusiness') UNION SELECT 'MAXIMO' Deteccion, 0 UNION	SELECT 'MINIMO' Deteccion, 0 UNION SELECT 'OK' Deteccion, 0 )X GROUP BY Deteccion 

SELECT category, OK, MAXIMO, MINIMO
FROM (	SELECT CanalyTiposOrden category, Deteccion, Cantidad FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'Amazon') 	
) AS SourceTable PIVOT(  SUM(Cantidad) FOR Deteccion IN ([OK], [MAXIMO], [MINIMO])) AS PivotTable

SELECT CanalyTiposOrden category, Deteccion, Sum(Cantidad) Cantidad
FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'') 
group by CanalyTiposOrden,Deteccion
order by CanalyTiposOrden,Deteccion

SELECT CanalyTiposOrden , date, Diferencia, ValorDifMaximo DifMaxSup, ValorDifMinimo*-1 DifMaxInf FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'Amazon-AmazonBusiness') order by Hora
*/



/****** Object:  Table [dbo].[CantidadVentasXDia]    Script Date: 4/19/2021 10:14:40 AM ******/




CREATE FUNCTION [dbo].[ChkPoint_CantidadVentas2](@ChkPoint varchar(10), @prFecha Int, @CanalyTiposOrden varchar(50))
	RETURNS @Analisis TABLE (
		  CanalyTiposOrden   varchar(50)
		, Fecha              int
		, Hora               int
		, Prediccion         int
		, Cantidad           int
		, Diferencia         int
		, Variacion          decimal(7,2)
	    , Deteccion          varchar(10)
		, ValorDifMinimo     int
		, ToleranciaInferior decimal(7,2)
		, ToleranciaSuperior decimal(7,2)
		, date               varchar(20)
		, varToleranciaInferior decimal(5,2)
		, varToleranciaSuperior decimal(5,2)
		, ValorDifMaximo     int
	)
AS
begin

	
	-- % de variación entre dos valores
	-- https://www.disfrutalasmatematicas.com/numeros/porcentaje-diferencia.html#:~:text=Respuesta%20(M%C3%A9todo%202)%3A,decir%20un%20aumento%20de%2020%25.

	DECLARE @prHora INT
	SELECT @prHora = 0
	
	WHILE  @prHora < 24
	BEGIN

		INSERT INTO @Analisis

		SELECT X.CanalyTiposOrden, Fecha, Hora, Prediccion, Cantidad, CASE WHEN Cantidad <=0 THEN 0 ELSE Diferencia END Diferencia, CASE WHEN Cantidad <=0 THEN 0.01 ELSE Variacion END Variacion
			/*, CASE WHEN ABS(Diferencia) > ValorDifMinimo THEN
				  CASE WHEN Variacion < 0 AND ABS(Variacion) > ToleranciaInferior THEN 'MINIMO' 
				  ELSE CASE WHEN Variacion > 0 AND ABS(Variacion) > ToleranciaSuperior THEN 'MAXIMO' 
					   ELSE 'OK'
					   END
				  END
			  ELSE
					'OK'
			  END Deteccion*/
			
			, CASE WHEN Variacion < 0 AND ABS(Variacion) > ToleranciaInferior  AND ABS(Diferencia) > ValorDifMinimo THEN 'MINIMO' 
			  ELSE CASE WHEN Variacion > 0 AND ABS(Variacion) > ToleranciaSuperior AND ABS(Diferencia) > ValorDifMaximo THEN 'MAXIMO' 
				   ELSE 'OK' END 
			  END  Deteccion
			 
			, ValorDifMinimo
			--, Prediccion * (1-ToleranciaInferior) ToleranciaInferior
			, case when Prediccion < ValorDifMinimo then 0 else 			
				case when (Prediccion - (Prediccion * (1-ToleranciaInferior))) < ValorDifMinimo then Prediccion - ValorDifMinimo else 
					(Prediccion * (1-ToleranciaInferior)) end end ToleranciaInferior

			--, (Prediccion * (1+ToleranciaSuperior))ToleranciaSuperior
			, case when ((Prediccion * (1+ToleranciaSuperior)) - Prediccion) < ValorDifMaximo then Prediccion + ValorDifMaximo else 
				(Prediccion * (1+ToleranciaSuperior)) end ToleranciaSuperior

			,LTRIM(RTRIM(STR(Fecha/10000)+'-'+
					RIGHT('00'+LTRIM(RTRIM(STR((Fecha%10000)/100))),2)+'-'+
					RIGHT('00'+LTRIM(RTRIM(STR((Fecha%100)))),2)+
					SPACE(1)+
					RIGHT('00'+LTRIM(RTRIM(STR(Hora))),2))) date
			, ToleranciaInferior varToleranciaInferior
			, ToleranciaSuperior varToleranciaSuperior
			, ValorDifMaximo
		FROM (	   
			SELECT  P.CanalyTiposOrden, P.date Fecha, P.hour Hora, CASE WHEN P.prediction <0 THEN 0 ELSE P.prediction END Prediccion, isnull(Sum(Cantidad),0) Cantidad, 
			isnull(Sum(Cantidad),0) - CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END  Diferencia
			, CASE WHEN CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END = 0 THEN 1.00 
			ELSE  round( (isnull(Sum(Cantidad),0)  - CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END)/CASE WHEN P.prediction < 0 THEN 0 ELSE P.prediction END, 2) END Variacion
			FROM PREDICCION P with(nolock)
			LEFT JOIN (
						SELECT CanalyTiposOrden, Fecha, Hora/100 Hora, Count(*) Cantidad
						FROM ALEORDENVENTA with(nolock)
						WHERE EstadoLogico = 0
						AND Fecha = @prFecha
						AND Hora/100 = @prHora 						
						--AND Hora/100 BETWEEN @prHora AND @prHoraFin
						group by CanalyTiposOrden, Fecha, Hora/100
				)R
				ON   P.date = R.Fecha
				and  P.hour = R.Hora		
				AND  P.CanalyTiposOrden = R.CanalyTiposOrden	
			WHERE P.date = @prFecha
				AND P.EstadoLogico = 0
				--AND P.hour BETWEEN @prHora AND @prHoraFin
				AND P.hour = @prHora
				AND (@CanalyTiposOrden = '' OR P.CanalyTiposOrden = @CanalyTiposOrden )
			GROUP BY P.CanalyTiposOrden, P.date, P.hour, P.prediction		
		)X
		INNER JOIN BuscaChkPoint (@ChkPoint, @prFecha, @prHora)
			W ON X.Hora  BETWEEN W.HoraInicial And W.HoraFinal
		--AND ABS(Diferencia) >=  ValorDifMinimo 
		--AND (( Variacion < 0 AND ToleranciaInferior <= ABS(Variacion))  OR ( Variacion >= 0 AND ToleranciaSuperior <= ABS(Variacion)))	
		AND X.CanalyTiposOrden = W.CanalyTiposOrden
		ORDER BY CanalyTiposOrden, Fecha, Hora, Prediccion

		SELECT @prHora = @prHora + 1

	END
	RETURN
end

GO
/****** Object:  UserDefinedFunction [dbo].[ChkPoint_CantidadVentasXMes]    Script Date: 4/28/2021 4:13:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CantidadVentasXDia]') AND type in (N'U'))
DROP TABLE [dbo].[CantidadVentasXDia]
GO

CREATE TABLE [dbo].[CantidadVentasXDia](
	[category] [varchar](50) NULL,
	[Fecha] [int] NULL,
	[Deteccion] [varchar](10) NULL,
	[Cantidad] [int] NULL
) ON [PRIMARY]
GO

DECLARE @DIA AS INT, @MES AS INT, @ANIO AS INT
SELECT  @DIA = 1, @MES = 2, @ANIO = 2021

SELECT @DIA =  CASE WHEN @MES = 2 THEN	CASE WHEN  @ANIO%100 != 0 AND  @ANIO % 4 = 0 THEN 29 ELSE 28	END
	   ELSE CASE WHEN @MES IN (1,3,5,7,8,10,12) THEN 31 ELSE 30	END	END

while @DIA > 0
BEGIN
	INSERT INTO [CantidadVentasXDia] (category, Fecha, Deteccion, Cantidad )
	SELECT CanalyTiposOrden category, Fecha, Deteccion, Cantidad 	
	FROM [ChkPoint_CantidadVentas2] ('CANTORD', @ANIO*10000 + @MES*100+@DIA ,'Amazon') 		
	SELECT @DIA = @DIA -1
END

*/
/*
SELECT Fecha, OK, ISNULL(MAXIMO,0) MAXIMO, ISNULL(MINIMO,0)MINIMO FROM (SELECT category, Fecha, Deteccion, Cantidad FROM [ChkPoint_CantidadVentasXMes]('CANTORD', 20210210 ,'Amazon') ) AS SourceTable PIVOT(  SUM(Cantidad) FOR Deteccion IN ([OK], [MAXIMO], [MINIMO])) AS PivotTable ORDER BY Fecha

DECLARE @DIA AS INT, @MES AS INT, @ANIO AS INT, @prFecha INT
SELECT @prFecha = 20210410
SELECT  @DIA = 1, @MES = (@prFecha/100)%100  , @ANIO = @prFecha/10000

SELECT @DIA =  CASE WHEN @MES = 2 THEN	CASE WHEN  @ANIO%100 != 0 AND  @ANIO % 4 = 0 THEN 29 ELSE 28	END
		   ELSE CASE WHEN @MES IN (1,3,5,7,8,10,12) THEN 31 ELSE 30	END	END

SELECT  @DIA, @MES, @ANIO

SELECT DiaMes, Fecha, OK, ISNULL(MAXIMO,0) MAXIMO, ISNULL(MINIMO,0)MINIMO FROM (SELECT category, DiaMes, Fecha, Deteccion, Cantidad FROM [ChkPoint_CantidadVentasXMes]('CANTORD', 20210210,'Amazon') ) AS SourceTable PIVOT(  SUM(Cantidad) FOR Deteccion IN ([OK], [MAXIMO], [MINIMO])) AS PivotTable ORDER BY Fecha

*/

CREATE FUNCTION [dbo].[ChkPoint_CantidadVentasXMes](@ChkPoint varchar(10), @prFecha Int, @CanalyTiposOrden varchar(50))
RETURNS @CantidadVentasXMes TABLE (
	[category] [varchar](50) NULL,
	[Fecha] [int] NULL,
	[DiaMes] [varchar](6) NULL,
	[Deteccion] [varchar](10) NULL,
	[Cantidad] [int] NULL
)
AS
begin

	DECLARE @DIA AS INT, @MES AS INT, @ANIO AS INT
	SELECT  @DIA = 1, @MES = (@prFecha/100)%100  , @ANIO = @prFecha /10000	

	SELECT @DIA =  CASE WHEN @MES = 2 THEN	CASE WHEN  @ANIO%100 != 0 AND  @ANIO % 4 = 0 THEN 29 ELSE 28	END
		   ELSE CASE WHEN @MES IN (1,3,5,7,8,10,12) THEN 31 ELSE 30	END	END

	while @DIA > 0
	BEGIN
		INSERT INTO @CantidadVentasXMes (category, Fecha, DiaMes, Deteccion, Cantidad )
		SELECT CanalyTiposOrden category, Fecha, LTRIM(RTRIM(str(@DIA)))+'-'+LTRIM(RTRIM(str(@MES))) DiaMes, Deteccion, Cantidad 	
		FROM [ChkPoint_CantidadVentas2] ('CANTORD', @ANIO*10000 + @MES*100+@DIA ,@CanalyTiposOrden) 		
		SELECT @DIA = @DIA -1
	END

	RETURN
end
GO
/****** Object:  StoredProcedure [dbo].[ChkPoint_RealizarAnalisis]    Script Date: 4/28/2021 4:13:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ChkPoint_RealizarAnalisis] (@FechaActual INT, @HoraCompleta INT)
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
	WHERE A.EstadoLogico =0  AND A.Estado = 'ACTIVO'  
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


GO
/****** Object:  StoredProcedure [dbo].[TransfomaDatosALEORDENVENTA]    Script Date: 4/28/2021 4:13:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TransfomaDatosALEORDENVENTA]
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

/*
SELECT CanalyTiposOrden , COUNT(*) 
FROM ALEORDENVENTA GROUP BY CanalyTiposOrden
order BY CanalyTiposOrden

SELECT Fecha, Hora/100 SoloHora, CanalyTiposOrden , COUNT(*) Cantidad
FROM ALEORDENVENTA 
GROUP BY Fecha, CanalyTiposOrden, Hora/100 
order BY Fecha, CanalyTiposOrden, Hora/100

SELECT Fecha, CanalyTiposOrden , COUNT(*) Cantidad, Min(Hora) Hora_Min, Max(Hora) Hora_Max
FROM ALEORDENVENTA 
GROUP BY Fecha, CanalyTiposOrden 
order BY Fecha, CanalyTiposOrden

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
GO
/****** Object:  StoredProcedure [dbo].[TransfomaDatosSALESORDERS]    Script Date: 4/28/2021 4:13:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TransfomaDatosSALESORDERS]
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

--ALTER TABLE [SALEORDERS2] ALTER COLUMN [Sales Channel Items] VARCHAR (1500);
--ALTER TABLE [DETALLE_VENTAS] ALTER COLUMN [SKU] VARCHAR (1500);

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
--UPDATE DETALLE_VENTAS SET CanalyTiposOrden = CanalVenta
from DETALLE_VENTAS
WHERE --CanalyTiposOrden NOT LIKE 'Amazon%'And 
charindex('-' ,CanalyTiposOrden) >0
group by Año,Mes, CanalyTiposOrden 
order by Año,Mes, CanalyTiposOrden 

--- business (grupo b)

select * 
from DETALLE_VENTAS
-- DELETE FROM DETALLE_VENTAS 
WHERE CanalyTiposOrden IN (
'SO-202493213-A-2.6','SO-202493239-A-2.5','SO-202497980-A-2.1'
)


TRUNCATE TABLE DETALLE_VENTAS

*/



-- Amazon-AmazonBusiness

--select año , mes, count(*) from TRANSFORMACION1 group by año, mes

GO
