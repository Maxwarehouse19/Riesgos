USE [MaxWarehouse]
GO
/****** Object:  UserDefinedFunction [dbo].[ChkPoint_CantidadVentas2]    Script Date: 4/22/2021 9:04:59 AM ******/
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
, Cantidad REAL 
, CASE WHEN Deteccion = 'MAXIMO' then  Cantidad else 0 END Maximo
, CASE WHEN Deteccion = 'MINIMO' then  Cantidad else 0 END Maximo
FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210411,'Amazon') order by Hora

SELECT  Deteccion category, sum(Cantidad) cantidad FROM ( SELECT Deteccion, Cantidad FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'Amazon-AmazonBusiness') UNION SELECT 'MAXIMO' Deteccion, 0 UNION	SELECT 'MINIMO' Deteccion, 0 UNION SELECT 'OK' Deteccion, 0 )X GROUP BY Deteccion 

SELECT category, OK, MAXIMO, MINIMO
FROM (	SELECT CanalyTiposOrden category, Deteccion, Cantidad FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'Amazon') 	
) AS SourceTable PIVOT(  SUM(Cantidad) FOR Deteccion IN ([OK], [MAXIMO], [MINIMO])) AS PivotTable

SELECT CanalyTiposOrden category, Deteccion, Sum(Cantidad) Cantidad
FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'') 
group by CanalyTiposOrden,Deteccion
order by CanalyTiposOrden,Deteccion

SELECT CanalyTiposOrden , date, Diferencia, ValorDifMaximo DifMaxSup, ValorDifMinimo*-1 DifMaxInf FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210401,'Walmart') order by Hora
*/



/****** Object:  Table [dbo].[CantidadVentasXDia]    Script Date: 4/19/2021 10:14:40 AM ******/




ALTER FUNCTION [dbo].[ChkPoint_CantidadVentas2](@ChkPoint varchar(10), @prFecha Int, @CanalyTiposOrden varchar(50))
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

