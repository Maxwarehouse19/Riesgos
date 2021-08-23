DECLARE @startDate DATETIME;

SET @startDate = GetDate();

SELECT PVT.DatabaseName
    ,PVT.[0]
    ,PVT.[-1]
    ,PVT.[-2]
    ,PVT.[-3]
    ,PVT.[-4]
    ,PVT.[-5]
    ,PVT.[-6]
    ,PVT.[-7]
    ,PVT.[-8]
    ,PVT.[-9]
    ,PVT.[-10]
    ,PVT.[-11]
    ,PVT.[-12]
FROM (
    SELECT BS.database_name AS DatabaseName
        ,DATEDIFF(mm, @startDate, BS.backup_start_date) AS MonthsAgo
        ,CONVERT(NUMERIC(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
    FROM msdb.dbo.backupset AS BS
    INNER JOIN msdb.dbo.backupfile AS BF ON BS.backup_set_id = BF.backup_set_id
    WHERE BS.database_name NOT IN (
            'master'
            ,'msdb'
            ,'model'
            ,'tempdb'
            )
        AND BS.database_name IN (
            SELECT db_name(database_id)
            FROM master.SYS.DATABASES
            WHERE state_desc = 'ONLINE'
            )
        AND BF.[file_type] = 'D'
        AND BS.backup_start_date BETWEEN DATEADD(yy, - 1, @startDate)
            AND @startDate
    GROUP BY BS.database_name
        ,DATEDIFF(mm, @startDate, BS.backup_start_date)
    ) AS BCKSTAT
PIVOT(SUM(BCKSTAT.AvgSizeMB) FOR BCKSTAT.MonthsAgo IN (
            [0]
            ,[-1]
            ,[-2]
            ,[-3]
            ,[-4]
            ,[-5]
            ,[-6]
            ,[-7]
            ,[-8]
            ,[-9]
            ,[-10]
            ,[-11]
            ,[-12]
            )) AS PVT
ORDER BY PVT.DatabaseName;


/*
sELECT
    [Database] = [database_name]
    , [Month] = DATEPART(month,[backup_start_date])
    , [Backup Size MB] = AVG([backup_size]/1024/1024)
    , [Compressed Backup Size MB] = AVG([compressed_backup_size]/1024/1024)
    , [Compression Ratio] = AVG([backup_size]/[compressed_backup_size])
FROM 
    msdb.dbo.backupset
WHERE 
   -- [database_name] = N'YourDatabaseName' AND 
   [type] = 'D'
GROUP BY 
    [database_name]
    , DATEPART(mm, [backup_start_date]);
*/