-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALECONFIG]') AND type in (N'U'))
DROP TABLE [dbo].[ALECONFIG]
GO

CREATE TABLE [dbo].[ALECONFIG](
	[IdRegistro]   [bigint] IDENTITY(1,1) ,-- Identificador interno del registro
	[IdModulo]     [varchar](10) NOT NULL, -- Nemónico que haga alusión al módulo
	[IdParametro]  [varchar](10) NOT NULL, -- Nemónico que haga alusión al parámetro
	[Valor]		   [varchar](100) NOT NULL, -- Valor del parámetro
	[Estado]       [varchar](10) NOT NULL , -- PENDIENTE, ENVIADO, ERROR
	[EstadoLogico] [bigint] NOT NULL  DEFAULT 0, -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente	
) ON [PRIMARY]
GO

CREATE UNIQUE INDEX [ALECONFIG_01] ON [dbo].[ALECONFIG](
	[EstadoLogico],[Estado],[IdModulo],[IdParametro]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

INSERT INTO [ALECONFIG] (
 [IdModulo],[IdParametro] ,[Valor],[Estado],[EstadoLogico])

 SELECT
  'CHKPNT' [IdModulo]    
, 'Estado' [IdParametro] 
, 'ACTIVO' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]
UNION
 SELECT
  'CHKPNT' [IdModulo]    
, 'MinsEspera' [IdParametro] 
, '3' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]
UNION
SELECT
  'CHKPNT' [IdModulo]    
, 'FechaPrue' [IdParametro] 
, 'HOY' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]

UNION

SELECT
  'ALERTA' [IdModulo]    
, 'TWI_MODE' [IdParametro] 
, 'DEBUG' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]
UNION
SELECT
  'ALERTA' [IdModulo]    
, 'Estado' [IdParametro] 
, 'ACTIVO' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]
UNION
SELECT
  'ALERTA' [IdModulo]    
, 'LecSinAler' [IdParametro] 
, '10' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]
UNION
SELECT
  'ALERTA' [IdModulo]    
, 'SecEspera' [IdParametro] 
, '30' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]
UNION
SELECT
  'ALERTA' [IdModulo]    
, 'MinsEspera' [IdParametro] 
, '3' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]
UNION
SELECT
  'ALERTA' [IdModulo]    
, 'FechaPrue' [IdParametro] 
, 'HOY' [Valor]		  
, 'ACTIVO' [Estado]      
, 0 [EstadoLogico]



SELECT * FROM [ALECONFIG]