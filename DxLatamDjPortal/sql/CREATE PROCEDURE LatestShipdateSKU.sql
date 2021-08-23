
--select top 100 * from Latestshipdate ORDER BY id DESC
/*
SELECT * FROM Latestshipdate WHERE SKU LIKE '%ACE-1204296%' AND DATEDIFF(DAY, '20210621', FechaInsercion) =0
SELECT * FROM Latestshipdate WHERE SKU LIKE '%JEN-1406-8852%' AND DATEDIFF(DAY, '20210621', FechaInsercion) =0
SELECT * FROM Latestshipdate WHERE SKU LIKE '%EJD-6575344%' AND DATEDIFF(DAY, '20210621', FechaInsercion) =0

SELECT * FROM Latestshipdate WHERE SKU LIKE '%,%' AND DATEDIFF(DAY, '20210621', FechaInsercion) =0

SELECT PO, COUNT(*) FROM Latestshipdate 
WHERE DATEDIFF(DAY, '20210621', FechaInsercion) =0
GROUP BY PO HAVING COUNT(*) > 1
*/
--EJD-6575401,EJD-6575591,EJD-6575344

--exec PROC_LatestshipdateSKU @Fecha = '20210621'
--SELECT * FROM LatestshipdateSKU
--, @CantRepite = 10
/*
DROP TABLE LatestshipdateSKU
CREATE TABLE LatestshipdateSKU(
	ID			 BIGINT IDENTITY(1,1),
	FechaIngreso DATETIME, 
	SKU          VARCHAR(20), 
	Cantidad     INT
)
*/


DROP PROCEDURE PROC_LatestshipdateSKU 
GO

CREATE PROCEDURE PROC_LatestshipdateSKU ( @Fecha DATE)
AS
BEGIN
    DELETE FROM LatestshipdateSKU WHERE DATEDIFF(DAY, FechaIngreso , @Fecha) = 0

	INSERT INTO LatestshipdateSKU (FechaIngreso, SKU, Cantidad)
	SELECT @Fecha FechaIngreso, SKU, COUNT(*) Cantidad
	FROM (
		SELECT 	LTRIM(RTRIM(CASE WHEN (CHARINDEX('[',value,1) > 0 AND CHARINDEX('(',value,1) > 0 ) THEN
					   CASE WHEN CHARINDEX('(',value,1) < CHARINDEX('[',value,1) THEN SUBSTRING(value, 1, CHARINDEX('(',value,1)-1)
					   ELSE SUBSTRING(value, 1, CHARINDEX('[',value,1)-1)   END
				 WHEN CHARINDEX('(',value,1) > 0 THEN SUBSTRING(value, 1, CHARINDEX('(',value,1)-1)
				 WHEN CHARINDEX('[',value,1) > 0 THEN SUBSTRING(value, 1, CHARINDEX('[',value,1)-1) 
				 ELSE value
			END ))SKU
		FROM (
			SELECT SKU
			FROM Latestshipdate
			WHERE datediff(DAY, FechaInsercion, @Fecha) =0 
		)X
		CROSS APPLY string_split (X.SKU,',')
	)Y
	GROUP BY SKU
	--HAVING count(*) >= @CantRepite
	order by COUNT(*) desc
END