-- exec [ChkPoint_CantidadVentas] 'CANTORD',20210202 , 11, 16
-- select * FROM [ChkPoint_CantidadVentas] ('CANTORD',20210201 , 2)
-- select * FROM [ChkPoint_CantidadVentas] ('CANTORD',20210201 , 3 )
-- select * FROM [ChkPoint_CantidadVentas] ('CANTORD',20210202 , 11)
-- select * FROM [ChkPoint_CantidadVentas] ('CANTORD',20210202 , 16)

DROP FUNCTION  [dbo].[ChkPoint_CantidadVentas]
GO

CREATE FUNCTION ChkPoint_CantidadVentas(@ChkPoint varchar(10), @prFecha Int, @prHora INT)
	RETURNS @Analisis TABLE (
		  CanalyTiposOrden   varchar(30)
		, Fecha              int
		, Hora               int
		, Predicion          int
		, Cantidad           int
		, Diferencia         int
		, Variacion          decimal(7,2)
	    , Deteccion          varchar(10)
		, ValorDifMinimo     int
		, ToleranciaInferior decimal(7,2)
		, ToleranciaSuperior decimal(7,2)
	)
AS
begin

	
	-- % de variación entre dos valores
	-- https://www.disfrutalasmatematicas.com/numeros/porcentaje-diferencia.html#:~:text=Respuesta%20(M%C3%A9todo%202)%3A,decir%20un%20aumento%20de%2020%25.

	INSERT INTO @Analisis

	SELECT CanalyTiposOrden, Fecha, Hora, Predicion, Cantidad, Diferencia, Variacion
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
	AND ABS(Diferencia) >=  ValorDifMinimo 
	AND (( Variacion < 0 AND ToleranciaInferior <= ABS(Variacion))  OR ( Variacion >= 0 AND ToleranciaSuperior <= ABS(Variacion)))	
	ORDER BY CanalyTiposOrden, Fecha, Hora, Predicion
	RETURN
end

-- select * from SALEORDERS