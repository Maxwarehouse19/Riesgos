-- truncate table [ALBITCHKPOINT]
-- truncate table [ALBIDETCHKPOINT]
/*
SELECT * FROM [ALBITCHKPOINT] 
where EstadoLogico = 0 
--and Fecha = 20210201
order by IdRegistro
SELECT * FROM [ALBIDETCHKPOINT]

select A.*, B.*
from [ALBITCHKPOINT] A
inner join [ALBIDETCHKPOINT] B
	ON B.EstadoLogico = 0
	AND B.Fecha = A.Fecha
	AND B.Hora  = A.Hora
	AND B.HoraModelo = A.HoraHasta

	SELECT TOP 1 HoraHasta FROM [ALBITCHKPOINT] WITH(NOLOCK)
	WHERE [EstadoLogico] = 0 AND [Fecha] = 20210201 AND [IdChkPoint] = 'CANTORD' AND [Hora] >= 0
	ORDER BY [EstadoLogico],[Fecha],[IdChkPoint] ,[Hora] DESC

*/
-- SELECT * FROM BuscaChkPoint ('CANTORD', 20210401, 0)
-- SELECT * FROM BuscaChkPoint ('CANTORD', 20210221, 0)
DROP FUNCTION  [dbo].[BuscaChkPoint]
GO

CREATE FUNCTION BuscaChkPoint (@IdChkPoint char(10), @Fecha INT, @Hora INT)
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