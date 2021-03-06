USE [MaxWarehouse]
GO
/****** Object:  UserDefinedFunction [dbo].[ChkPoint_CantidadVentas]    Script Date: 4/30/2021 8:15:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[ChkPoint_CantidadVentas](@ChkPoint varchar(10), @prFecha Int, @prHora INT)
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

	DECLARE @NumRegsHoy BIGINT

	SELECT  @NumRegsHoy = Count(*) 
	FROM ALEORDENVENTA with(nolock)
	WHERE EstadoLogico = 0
	AND Fecha = @prFecha
	
	IF (@NumRegsHoy IS NULL OR @NumRegsHoy = 0) 
	BEGIN
		RETURN -- Sino hay registros pera hoy no hay nada que hacer
	END

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

