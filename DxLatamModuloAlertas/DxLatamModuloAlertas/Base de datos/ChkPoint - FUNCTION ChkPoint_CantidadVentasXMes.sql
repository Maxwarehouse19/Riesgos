USE [MaxWarehouse]
GO
/****** Object:  UserDefinedFunction [dbo].[ChkPoint_CantidadVentasXMes]    Script Date: 4/22/2021 9:08:48 AM ******/
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

ALTER FUNCTION [dbo].[ChkPoint_CantidadVentasXMes](@ChkPoint varchar(10), @prFecha Int, @CanalyTiposOrden varchar(50))
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