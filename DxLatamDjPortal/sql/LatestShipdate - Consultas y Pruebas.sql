select FechaInsercion , count(*)
from LatestShipDate 
group by FechaInsercion
order by FechaInsercion

--SELECT TOP 10 * FROM LatestShipDate 
--UPDATE LatestShipDate  SET FechaInsercion = SalesOrderDate

declare @p1 int
set @p1=66
exec sp_prepexec @p1 output,N'@P1 nvarchar(20),@P2 nvarchar(20)',N'SELECT [LS_DiasXMonto].[FechaIngreso], SUM([LS_DiasXMonto].[0]) AS [sum_number_0], SUM([LS_DiasXMonto].[1]) AS [sum_number_1], SUM([LS_DiasXMonto].[2]) AS [sum_number_2], SUM([LS_DiasXMonto].[3]) AS [sum_number_3], SUM([LS_DiasXMonto].[4]) AS [sum_number_4], SUM([LS_DiasXMonto].[5]) AS [sum_number_5], SUM([LS_DiasXMonto].[6]) AS [sum_number_6], SUM([LS_DiasXMonto].[7]) AS [sum_number_7], SUM([LS_DiasXMonto].[8]) AS [sum_number_8], SUM([LS_DiasXMonto].[9]) AS [sum_number_9], SUM([LS_DiasXMonto].[10]) AS [sum_number_10], SUM([LS_DiasXMonto].[11]) AS [sum_number_11] FROM [LS_DiasXMonto] WHERE [LS_DiasXMonto].[FechaIngreso] BETWEEN @P1 AND @P2 GROUP BY [LS_DiasXMonto].[FechaIngreso]',N'2021-06-22',N'2021-06-22'
select @p1

select * from [LatestshipdateSKU]

DECLARE @P1 datetime2,@P2 datetime2
SELECT @P1 = '2021-06-22 00:00:00',@P2 ='2021-06-22 23:59:59.9999990'
SELECT TOP 10 [LatestshipdateSKU].[ID], [LatestshipdateSKU].[FechaIngreso], [LatestshipdateSKU].[SKU], [LatestshipdateSKU].[Cantidad] 
FROM [LatestshipdateSKU] 
WHERE [LatestshipdateSKU].[FechaIngreso] BETWEEN @P1 AND @P2 
ORDER BY [LatestshipdateSKU].[FechaIngreso] ASC, [LatestshipdateSKU].[Cantidad] DESC

DECLARE @Fechap DATE
SELECT @Fechap = DATEADD(DAY,0,'20210501')
--SELECT @Fecha Fecha 

WHILE DATEDIFF(DAY,@Fechap,'20210625') != 0
BEGIN
	EXEC LatestShipdate_DistribucionDias @Fecha = @Fechap
	exec PROC_LatestshipdateSKU @Fecha = @Fechap
	SELECT @Fechap = DATEADD(DAY,1,@Fechap)
END 