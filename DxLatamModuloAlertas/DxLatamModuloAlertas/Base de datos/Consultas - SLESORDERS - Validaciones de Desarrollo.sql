
	SELECT [Order Date]	   
	,
	case when CHARINDEX('/',[Order Date]) <= 0 then  
		CAST(RTRIM(LTRIM(substring([Order Date],1,CHARINDEX('-',[Order Date])-1))) AS INT)
	else  
		CAST(RTRIM(LTRIM(substring([Order Date],1,CHARINDEX('/',[Order Date])-1))) AS INT)
	end mes		   
		   --,CAST(RTRIM(LTRIM(substring([Order Date],CHARINDEX('/',[Order Date])+1, (CHARINDEX('/',[Order Date],CHARINDEX('/',[Order Date])+1)-1) - (CHARINDEX('/',[Order Date]))))) AS INT) dia
		   --,CAST(RTRIM(LTRIM(substring([Order Date],CHARINDEX('/',[Order Date],CHARINDEX('/',[Order Date])+1)+1,4))) AS INT)año,
		   --,RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) horaCompleta,	   
		   --,CAST(SUBSTRING(RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))), 1, CHARINDEX(':',RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) , 1)-1) AS INT)hora,
		   --,CAST(SUBSTRING(RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))), CHARINDEX(':',RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) , 1)+1,2) AS INT)minuto,
		   --,SUBSTRING(RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))), CHARINDEX(' ',RTRIM(LTRIM(substring([Order Date],CHARINDEX(' ',[Order Date])+1,10))) , 1)+1,2) jornada,
		   --,[Status],
		   --,[Sales Channel],
		   --,[Sales Order Type],
		   --,CAST([Net] AS DECIMAL(11,2)) Net,
		   --,[Currency]
		   --,[Sales Channel Items]

	
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
	


	SELECT *
	FROM [dbo].[SALEORDERS] WITH(NOLOCK)
	WHERE CHARINDEX('.',[Order Date])>0


	select  Mes, (Hora/100) Hora , COUNT(*) 
	-- DELETE
	from DETALLE_VENTAS where Año = 2020  and Mes IN ('DICIEMBRE','NOVIEMBRE','OCTUBRE')
	GROUP BY Mes, (Hora/100) 
	order BY Mes, (Hora/100) 