USE [MaxWarehouse]
GO
/****** Object:  UserDefinedFunction [dbo].[MensajeAmazonLate]    Script Date: 6/10/2021 12:01:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT dbo.MensajeAmazonLate(GETDATE()) 
--SELECT dbo.MensajeAmazonLate(dateadd(day, 0, GETDATE())) 
--GO

ALTER FUNCTION [dbo].[MensajeAmazonLate] (@DATE datetime)
RETURNS VARCHAR(120)
/*When you send a SMS message over 160 characters, the message will be split.
  Large messages are segmented into 153 character segments and sent individually, 
  then rebuilt by the recipient's device. For example, a 161-character message 
  will be sent as two messages, one with 153 characters and the second with 8 
  characters.*/
AS
BEGIN
	DECLARE
	 @Channel      [varchar](20) 	,@Total		   int 
	,@Tarde   	   int   			,@Porcentaje   decimal(8,4)
	,@Parte      Varchar(50) ,@Mensaje      Varchar(120)

	select @Total = SUM(ISNULL(Total, 0)) , @Tarde = SUM(ISNULL(Tarde, 0)) , @Porcentaje = cast(((SUM(CAST(ISNULL(Tarde, 0.0)AS DECIMAL(11,2))) /SUM(ISNULL(Total, 1.0)) * 100)) as decimal(8,4))  
	from RESUMENINSIGHTLATE 
	WHERE day(FechaIngreso)	= day(@DATE) 
		 and	month(FechaIngreso) = month(@DATE) 
		 and	year(FechaIngreso)	= year(@DATE)
	
	IF @Total = 0 
	BEGIN
		RETURN NULL
	END

	SET @Mensaje = '<Late Delivery>'+ltrim(rtrim(str(@Tarde)))+'/'
	+ltrim(rtrim(str(@Total)))+'='+ltrim(rtrim(str(@Porcentaje)))+'% '

	DECLARE ChkPoint_AmazonLate CURSOR  
		FOR select Channel, ISNULL(Total, 0) Total, ISNULL(Tarde, 0) Tarde,  cast(((CAST(ISNULL(Tarde, 0.0)AS DECIMAL(11,2)) /ISNULL(Total, 1.0)) * 100) as decimal(8,4))  Porcentaje
	from RESUMENINSIGHTLATE 
	WHERE day(FechaIngreso)	= day(@DATE) 
		 and	month(FechaIngreso) = month(@DATE) 
		 and	year(FechaIngreso)	= year(@DATE)
	
	OPEN ChkPoint_AmazonLate  

  	-- RECORRIENDO PUNTOS DE AMAZON LATE
	FETCH NEXT FROM ChkPoint_AmazonLate
	INTO  @Channel   ,@Total ,@Tarde ,@Porcentaje
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		
		SET @Parte = @Channel +':'+ltrim(rtrim(str(@Tarde)))+'/'+ltrim(rtrim(str(@Total))) +'='+ltrim(rtrim(str(@Porcentaje))) +'% '
		
		FETCH NEXT FROM ChkPoint_AmazonLate
		INTO  @Channel   ,@Total ,@Tarde ,@Porcentaje

		--SELECT @Parte Parte

		SET @Mensaje = CONCAT(@Mensaje , @Parte)
	END

	-- CERRANDO Y ELIMINANDO CURSOR
	CLOSE ChkPoint_AmazonLate;  
	DEALLOCATE ChkPoint_AmazonLate;

	RETURN @Mensaje 
END