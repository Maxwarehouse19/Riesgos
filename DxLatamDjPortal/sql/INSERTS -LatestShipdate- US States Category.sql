USE [MaxWarehouse]
GO

DELETE from [home_category] where [code] = 'USA001' and parent_id is null

INSERT INTO [dbo].[home_category]
           ([title]
           ,[parent_id]
           ,[code])
VALUES
           ('State Abbreviations'
           ,null
           ,'USA001')

GO

DECLARE @USA001id INT

SELECT  @USA001id = id from [home_category] where [code] = 'USA001' and parent_id is null

--SELECT  @USA001id 


INSERT INTO [dbo].[home_category]
           ([title]
           ,[parent_id]
           ,[code])

SELECT descripcion, @USA001id , Res
FROM (
select 'Desconocido' descripcion , '??' Res UNION ALL
select 'ALABAMA' descripcion , 'AL' Res UNION ALL
select 'ALASKA' descripcion , 'AK' Res UNION ALL
select 'AMERICAN SAMOA' descripcion , 'AS' Res UNION ALL
select 'ARIZONA' descripcion , 'AZ' Res UNION ALL
select 'ARKANSAS' descripcion , 'AR' Res UNION ALL
select 'CALIFORNIA' descripcion , 'CA' Res UNION ALL
select 'COLORADO' descripcion , 'CO' Res UNION ALL
select 'CONNECTICUT' descripcion , 'CT' Res UNION ALL
select 'DELAWARE' descripcion , 'DE' Res UNION ALL
select 'DISTRICT OF COLUMBIA' descripcion , 'DC' Res UNION ALL
select 'FLORIDA' descripcion , 'FL' Res UNION ALL
select 'GEORGIA' descripcion , 'GA' Res UNION ALL
select 'GUAM' descripcion , 'GU' Res UNION ALL
select 'HAWAII' descripcion , 'HI' Res UNION ALL
select 'IDAHO' descripcion , 'ID' Res UNION ALL
select 'ILLINOIS' descripcion , 'IL' Res UNION ALL
select 'INDIANA' descripcion , 'IN' Res UNION ALL
select 'IOWA' descripcion , 'IA' Res UNION ALL
select 'KANSAS' descripcion , 'KS' Res UNION ALL
select 'KENTUCKY' descripcion , 'KY' Res UNION ALL
select 'LOUISIANA' descripcion , 'LA' Res UNION ALL
select 'MAINE' descripcion , 'ME' Res UNION ALL
select 'MARYLAND' descripcion , 'MD' Res UNION ALL
select 'MASSACHUSETTS' descripcion , 'MA' Res UNION ALL
select 'MICHIGAN' descripcion , 'MI' Res UNION ALL
select 'MINNESOTA' descripcion , 'MN' Res UNION ALL
select 'MISSISSIPPI' descripcion , 'MS' Res UNION ALL
select 'MISSOURI' descripcion , 'MO' Res UNION ALL
select 'MONTANA' descripcion , 'MT' Res UNION ALL
select 'NEBRASKA' descripcion , 'NE' Res UNION ALL
select 'NEVADA' descripcion , 'NV' Res UNION ALL
select 'NEW HAMPSHIRE' descripcion , 'NH' Res UNION ALL
select 'NEW JERSEY' descripcion , 'NJ' Res UNION ALL
select 'NEW MEXICO' descripcion , 'NM' Res UNION ALL
select 'NEW YORK' descripcion , 'NY' Res UNION ALL
select 'NORTH CAROLINA' descripcion , 'NC' Res UNION ALL
select 'NORTH DAKOTA' descripcion , 'ND' Res UNION ALL
select 'NORTHERN MARIANA IS' descripcion , 'MP' Res UNION ALL
select 'OHIO' descripcion , 'OH' Res UNION ALL
select 'OKLAHOMA' descripcion , 'OK' Res UNION ALL
select 'OREGON' descripcion , 'OR' Res UNION ALL
select 'PENNSYLVANIA' descripcion , 'PA' Res UNION ALL
select 'PUERTO RICO' descripcion , 'PR' Res UNION ALL
select 'RHODE ISLAND' descripcion , 'RI' Res UNION ALL
select 'SOUTH CAROLINA' descripcion , 'SC' Res UNION ALL
select 'SOUTH DAKOTA' descripcion , 'SD' Res UNION ALL
select 'TENNESSEE' descripcion , 'TN' Res UNION ALL
select 'TEXAS' descripcion , 'TX' Res UNION ALL
select 'UTAH' descripcion , 'UT' Res UNION ALL
select 'VERMONT' descripcion , 'VT' Res UNION ALL
select 'VIRGINIA' descripcion , 'VA' Res UNION ALL
select 'VIRGIN ISLANDS' descripcion , 'VI' Res UNION ALL
select 'WASHINGTON' descripcion , 'WA' Res UNION ALL
select 'WEST VIRGINIA' descripcion , 'WV' Res UNION ALL
select 'WISCONSIN' descripcion , 'WI' Res 
)X