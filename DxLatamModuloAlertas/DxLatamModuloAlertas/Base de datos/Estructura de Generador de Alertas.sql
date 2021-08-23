/****************************************************************************************************************************
             DXLatam - Proyecto de Análisis de Riesgo para MaxWarehouse - ENERO 2021
			 Desarrollador: Gabriela Reynoso
 ****************************************************************************************************************************/

 
-----------------------------------------------------------------------------------------------------------------------------
-- ALESOLICITUD
-- Solicitud de envío de mensajes
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALESOLICITUD]') AND type in (N'U'))
DROP TABLE [dbo].[ALESOLICITUD]
GO

CREATE TABLE [dbo].[ALESOLICITUD](
	[IdRegistro]   [bigint] IDENTITY(1,1) ,-- Identificador interno del registro
	[Fecha]        [int] NOT NULL, -- Formato CCYYMMDD
	[Hora]         [int] NOT NULL, -- Formato HHMMSSMM	
	[IdMensaje]    [varchar](10) NOT NULL, -- Nemónico que haga alusión al mensaje que se enviará
	[Criterio]     [varchar](10) NOT NULL, -- Nemónico que haga alusión la razón del mensaje (MAXIMO, MINIMO, MONTO)
	[Estado]       [varchar](10) NOT NULL , -- PENDIENTE, ENVIADO, ERROR
	[Detalle]      [varchar](100)  NOT NULL, -- Detalle del mensaje
	[DescError]    [varchar](200)  NOT NULL, -- Si hay error indicar cual fue.
	[EstadoLogico] [bigint] NOT NULL  DEFAULT 0, -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente	
) ON [PRIMARY]
GO

CREATE UNIQUE INDEX [ALESOLICITUD_01] ON [dbo].[ALESOLICITUD](
	[EstadoLogico],[Fecha],[Estado], [Hora], [IdMensaje],[Criterio],[IdRegistro]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-----------------------------------------------------------------------------------------------------------------------------
-- ALECHECKPOINT
--    Contendrá la configurción para puntos de chequeo y emisión de alertas
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALECHKPOINT]') AND type in (N'U'))
DROP TABLE [dbo].[ALECHKPOINT]
	
CREATE TABLE [dbo].[ALECHKPOINT](
	 [IdRegistro]       [bigint] IDENTITY(1,1) -- Identificador interno del registro
	,[IdChkPoint]       [varchar](10) not null -- Identificador del código de punto de validación
	,[FechaVigencia] 	int           not null -- Formato CCYYMMDD
	,[HoraInicial]		int           not null -- Formato HHMMSSMM
	,[Descripicion]    	[varchar](30) not null -- Descripción
	,[sp_Validacion]    [varchar](30) not null -- Proceso almacenado que realiza la validación       
	,[IdMensaje]		[varchar](10) not null -- [ALEMENSAJE].IdMensaje
	,[MensajeInf]		[varchar](10) not null -- [ALEMENSAJE].Criterio
	,[MensajSup]		[varchar](10) not null -- [ALEMENSAJE].Criterio
	,[UniRevision]		[varchar](10) not null -- 'DIA','HORA','MINUTO' 
	,[Periodicidad]		tinyint       not null -- Cantidad de unidades
	,[Estado]			[varchar](10) not null -- ACTIVA, INACTIVA		
	,[HoraFinal]  		int           not null -- Formato HHMMSSMM
	,[EstadoLogico]     [bigint]      NOT NULL  DEFAULT 0 -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
) ON [PRIMARY]

CREATE UNIQUE INDEX [ALECHKPOINT_01] ON [dbo].[ALECHKPOINT](
	[EstadoLogico],[IdChkPoint] ,[FechaVigencia],[HoraInicial] 
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------
-- ALTCHKPOINT
--    Detalle de checkpoint
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALTCHKPOINT]') AND type in (N'U'))
DROP TABLE [dbo].[ALTCHKPOINT]
	
CREATE TABLE [dbo].[ALTCHKPOINT](
	 [IdRegistro]          [bigint] IDENTITY(1,1) -- Identificador interno del registro
	,[IdChkPoint]          [varchar](10) not null -- [ALECHKPOINT].IdChkPoint
	,[CanalyTiposOrden]    [varchar](30) not null -- Segregando configuración por canal y tipo de venta
	,[FechaInicial]		   int           not null -- Formato CCYYMMDD
	,[HoraInicial]		   int           not null -- Formato HHMMSSMM
	,[FechaFinal]		   int           not null -- Formato CCYYMMDD	
	,[HoraFinal]		   int           not null -- Formato HHMMSSMM
	,[ValorDifMinimo]	   decimal (7,2) not null -- Mínima cantidad de diferencia antes de evaluar rango de tolerancia 
	,[ToleranciaInferior]  decimal (7,2) not null -- %diferencia inferior
	,[ToleranciaSuperior]  decimal (7,2) not null -- %diferencia superior
	,[Estado]			[varchar](10) not null -- ACTIVA, INACTIVA		
	,[EstadoLogico]        [bigint]      NOT NULL  DEFAULT 0 -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
) ON [PRIMARY]

CREATE UNIQUE INDEX [ALTCHKPOINT_01] ON [dbo].[ALTCHKPOINT](
	[EstadoLogico],[IdChkPoint],[CanalyTiposOrden] ,[FechaInicial],[HoraInicial]	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
 
 -----------------------------------------------------------------------------------------------------------------------------
-- ALBITCHKPOINT
--    Bitácora de checkpoint 
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALBITCHKPOINT]') AND type in (N'U'))
DROP TABLE [dbo].[ALBITCHKPOINT]
	
CREATE TABLE [dbo].[ALBITCHKPOINT](
	  [IdRegistro]      [bigint] IDENTITY(1,1) -- Identificador interno del registro
	 ,[Fecha]			INT not null -- Formato CCYYMMDD -- Fecha del registro
	 ,[IdChkPoint]		[varchar](10) not null -- [ALTCHKPOINT].[IdChkPoint]	
	 ,[CanalyTiposOrden] [varchar](30)  not null--[ALTCHKPOINT].[CanalyTiposOrden]	
	 ,[Hora] 	        int not null		   -- Formato HHMMSSMM -- Hora del registro
	 ,[HoraDesde]		int not null		   -- Formato HHMMSSMM -- Hora menor de análisis
	 ,[HoraHasta] 		int not null		   -- Formato HHMMSSMM -- Hora mayor de análisis	 
	 ,[FechaInicial]   	int not null		   -- [ALTCHKPOINT].[FechaInicial]   		 
	 ,[HoraInicial] 	int not null		   -- [ALTCHKPOINT].[HoraInicial] 	
	 ,[FechaFinal]   	int not null		   -- [ALTCHKPOINT].[FechaFinal]   	
	 ,[HoraFinal]		int not null		   -- [ALTCHKPOINT].[HoraFinal]		
	 ,[ValDifMinimo] 	decimal(7,2) not null  -- [ALTCHKPOINT].[ValDifMinimo] 	
	 ,[ToleranciaInf] 	decimal(7,2) not null  -- [ALTCHKPOINT].[ToleranciaInf] 	
	 ,[ToleranciaSup]  	decimal(7,2) not null  -- [ALTCHKPOINT].[ToleranciaSup]  	
	 ,[Accion]          varchar(10)            -- ALERTA/NADA
	 ,[EstadoLogico]    [bigint]      NOT NULL  DEFAULT 0 -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
) ON [PRIMARY]

CREATE UNIQUE INDEX [ALBITCHKPOINT_01] ON [dbo].[ALBITCHKPOINT](
	[EstadoLogico],[Fecha],[IdChkPoint],[CanalyTiposOrden] ,[Hora]	,[HoraHasta] 
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

 -----------------------------------------------------------------------------------------------------------------------------
-- ALBIDETCHKPOINT
--    Detalle de bitácora  
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALBIDETCHKPOINT]') AND type in (N'U'))
DROP TABLE [dbo].[ALBIDETCHKPOINT]
	
CREATE TABLE [dbo].[ALBIDETCHKPOINT](
	  [IdRegistro]       [bigint] IDENTITY(1,1)  -- Identificador interno del registro
	 ,[Fecha]		              int   not null -- [ALBITCHKPOINT].[Fecha]		
	 ,[IdChkPoint]	     [varchar](10)  not null -- [ALBITCHKPOINT].[IdChkPoint]	
	 ,[Hora]	                  int   not null -- [ALBITCHKPOINT].[Hora]	    
	 ,[CanalyTiposOrden] [varchar](30)  not null
	 ,[Accion]		     [varchar](10)  not null -- MÁXIMO/MINIMO/NINGUNO
	 ,[FechaModelo]	              int   not null
	 ,[HoraModelo]		          int   not null
	 ,[Prediccion]		 [decimal](7,2) not null
	 ,[ValorReal]		 [decimal](7,2) not null
	 ,[Diferencia]		 [decimal](7,2) not null
	 ,[Variacion]        [decimal](7,2) not null
	 ,[EstadoLogico]     [bigint]       NOT NULL  DEFAULT 0 -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
) ON [PRIMARY]

CREATE UNIQUE INDEX [ALBIDETCHKPOINT_01] ON [dbo].[ALBIDETCHKPOINT](
	[EstadoLogico],[Fecha],[IdChkPoint] ,[Hora],[CanalyTiposOrden],	[HoraModelo]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------
-- ALEORDENVENTA
--    Contendrá la lectura del archivo de SALESORDERS
-----------------------------------------------------------------------------------------------------------------------------
 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALEORDENVENTA]') AND type in (N'U'))
DROP TABLE [dbo].[ALEORDENVENTA]
	
CREATE TABLE [dbo].[ALEORDENVENTA](
	[IdRegistro]         [bigint] IDENTITY(1,1), -- Identificador interno del registro
	[Fecha] [bigint] NULL,
	[Hora] [bigint] NULL,	
	[CanalVenta] [varchar](15) NULL,
	[TiposOrdenVenta] [varchar](28) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,	
	[Moneda] [varchar](6) NULL,
	[Monto] [decimal](18,2)  NULL,
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[Dia] [int] NULL,
	[SKU] [varchar](1500) NULL,
	[EstadoLogico]       [bigint] NOT NULL  DEFAULT 0 -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
) ON [PRIMARY]

CREATE UNIQUE INDEX [ALEORDENVENTA_01] ON [dbo].[ALEORDENVENTA](
	[EstadoLogico],	[CanalyTiposOrden]	,[Fecha],[Hora], [IdRegistro]				
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-----------------------------------------------------------------------------------------------------------------------------
-- PREDICCION
--    Utilizando machine learning contendrá los valores predictivos del modelo 
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PREDICCION]') AND type in (N'U'))
DROP TABLE [dbo].[PREDICCION]
GO
 
 CREATE TABLE [dbo].[PREDICCION](
 	[IdRegistro]         [bigint] IDENTITY(1,1), -- Identificador interno del registro
	[CanalyTiposOrden]	 [varchar](50) NULL,
	[date]				 int not null,
	[hour]				 tinyint not null,
	[last_training]		 varchar(20)   not null,
	prediction			 decimal(11,2) not null,	
	[FechaCreacion]      bigint DEFAULT CONVERT(varchar, getdate(), 112),
	[EstadoLogico]       [bigint] NOT NULL  DEFAULT 0 -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
)ON [PRIMARY]
go


CREATE UNIQUE INDEX [PREDICCION_01] ON [dbo].[PREDICCION](
	[EstadoLogico],	[CanalyTiposOrden]	,[date],[hour]				
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-----------------------------------------------------------------------------------------------------------------------------
-- ALECONTACTOS
--           Estructura que contendrá el detalle de los usuarios que deberán recibir las alertas 
--           las alertas se ralizarán por mensaje de texto
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALECONTACTOS]') AND type in (N'U'))
DROP TABLE [dbo].[ALECONTACTOS]
GO

CREATE TABLE [dbo].[ALECONTACTOS](
	[IdRegistro]         [bigint] IDENTITY(1,1), -- Identificador interno del registro
	[IdContacto]	     [varchar](40) NOT NULL, -- deberá ser el correo electrónico	
	[Telefono]		     [varchar](20) NOT NULL, -- deberá ser almacenado en el formato internacional para ser utilizado por medio de twilio
	[NombreCompleto]     [varchar](80) NOT NULL, -- nombres y apellidos que serán utilizados en los mensajes
	[Puesto]             [varchar](30) NOT NULL, -- Puesto de la persona a ser contactada
	[ModoContacto]       [varchar](10) NOT NULL, -- EMAIL, TELEFONO, AMBOS
	[Estado]             [varchar](10) NOT NULL, -- ACTIVO, INACTIVO -- indicará si debe o no recibir los mensajes.    
	[EstadoLogico]       [bigint] NULL  DEFAULT 0, -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
	[FechaCreacion]      [int] NULL  DEFAULT 0, -- Formato CCYYMMDD
	[HoraCreacion]       [int] NULL  DEFAULT 0, -- Formato HHMMSSMM	
	[FechaModificacion]  [int] NULL  DEFAULT 0, -- Formato CCYYMMDD 
	[HoraModifcacion]    [int] NULL  DEFAULT 0, -- Formato HHMMSSMM	
) ON [PRIMARY]
GO


CREATE UNIQUE INDEX [ALECONTACTOS_01] ON [dbo].[ALECONTACTOS](
	[EstadoLogico],[IdContacto], [Telefono]	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------
-- ALELISTACONTACTO
--          Las listas de contactos contendrán el listado de personas a quienes dirigirse la alerta
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALELISTACONTACTO]') AND type in (N'U'))
DROP TABLE [dbo].[ALELISTACONTACTO]
GO

CREATE TABLE [dbo].[ALELISTACONTACTO](
	[IdRegistro]         [bigint] IDENTITY(1,1) ,-- Identificador interno del registro
	[IdLista]            [varchar](10) NOT NULL, -- Nemónico que haga alusión al conjunto de personas que deben recibir el mensaje
	[Descripcion]        [varchar](80) NOT NULL, -- Descripción de la lista de contactos.         
	[IdContacto]	     [varchar](40) NOT NULL, -- deberá ser el correo electrónico	    
	[Estado]             [varchar](10) NOT NULL, -- ACTIVO, INACTIVO -- indicará si debe o no recibir los mensajes.    
	[EstadoLogico]       [bigint] NOT NULL, -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
	[FechaCreacion]      [int] NOT NULL, -- Formato CCYYMMDD
	[HoraCreacion]       [int] NOT NULL, -- Formato HHMMSSMM	
	[FechaModificacion]  [int] NOT NULL, -- Formato CCYYMMDD 
	[HoraModifcacion]    [int] NOT NULL, -- Formato HHMMSSMM	
) ON [PRIMARY]
GO

CREATE UNIQUE INDEX [ALELISTACONTACTO_01] ON [dbo].[ALELISTACONTACTO](
	[EstadoLogico],[IdLista],[IdContacto]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------
-- ALEMENSAJE
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALEMENSAJE]') AND type in (N'U'))
DROP TABLE [dbo].[ALEMENSAJE]
GO

CREATE TABLE [dbo].[ALEMENSAJE](
	[IdRegistro]         [bigint] IDENTITY(1,1) ,-- Identificador interno del registro
	[IdMensaje]          [varchar](10) NOT NULL, -- Nemónico que haga alusión al mensaje que se enviará
	[Criterio]           [varchar](10) NOT NULL, -- Nemónico que haga alusión la razón del mensaje (MAXIMO, MINIMO, MONTO)
	[IdLista]            [varchar](10) NOT NULL, -- Nemónico que haga alusión al conjunto de personas que deben recibir el mensaje


	[Subject]            [varchar](50)  NOT NULL, -- Subject del mensaje a ser enviado

	/*	https://www.twilio.com/docs/glossary/what-sms-character-limit#:~:text=The%20character%20limit%20for%20a,are%20limited%20to%2070%20characters.
		The character limit for a single SMS message is 160 characters. However, most modern phones and networks support concatenation; 
	    they segment and rebuild messages up to 1600 characters. Messages not using GSM-7 encoding are limited to 70 characters. 	   */
	[Mensaje]            [varchar](160) NOT NULL, -- Mensaje a ser enviado
	
	[Estado]             [varchar](10)  NOT NULL, -- ACTIVO, INACTIVO -- indicará si debe enviarse el mensaje.    
	[EstadoLogico]       [bigint] NOT NULL, -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
	[FechaCreacion]      [int] NOT NULL, -- Formato CCYYMMDD
	[HoraCreacion]       [int] NOT NULL, -- Formato HHMMSSMM	
	[FechaModificacion]  [int] NOT NULL, -- Formato CCYYMMDD 
	[HoraModifcacion]    [int] NOT NULL, -- Formato HHMMSSMM	

) ON [PRIMARY]
GO

CREATE UNIQUE INDEX [ALEMENSAJE_01] ON [dbo].[ALEMENSAJE](
	[EstadoLogico],[IdMensaje],[Criterio]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------
-- ALEBITACORA
-----------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALEBITACORA]') AND type in (N'U'))
DROP TABLE [dbo].[ALEBITACORA]
GO

CREATE TABLE [dbo].[ALEBITACORA](
	[IdRegistro]         [bigint] IDENTITY(1,1) ,-- Identificador interno del registro
	[Fecha]      [int] NOT NULL, -- Formato CCYYMMDD
	[Hora]       [int] NOT NULL, -- Formato HHMMSSMM	
	[IdMensaje]  [varchar](10) NOT NULL, -- Nemónico que haga alusión al mensaje que se enviará
	[Criterio]   [varchar](10) NOT NULL, -- Nemónico que haga alusión la razón del mensaje (MAXIMO, MINIMO, MONTO)
	[IdLista]    [varchar](10) NOT NULL, -- Nemónico que haga alusión al conjunto de personas que deben recibir el mensaje
	[IdContacto] [varchar](40) NOT NULL, -- deberá ser el correo electrónico	
	[Telefono]	 [varchar](20) NOT NULL, -- deberá ser almacenado en el formato internacional para ser utilizado por medio de twilio
	[Subject]    [varchar](50)  NOT NULL, -- Subject del mensaje a ser enviado
	[Mensaje]    [varchar](160) NOT NULL, -- Mensaje a ser enviado
	[Estado]     [varchar](10) NOT NULL , -- ENVIADO, RECIBIDO, ERROR
	[DescError]  [varchar](200)  NOT NULL, -- Si hay error indicar cual fue.

	[EstadoLogico]       [bigint] NOT NULL, -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente	

) ON [PRIMARY]
GO

CREATE UNIQUE INDEX [ALEBITACORA_01] ON [dbo].[ALEBITACORA](
	[EstadoLogico],[Fecha], [Hora], [IdMensaje],[Criterio],[IdLista],[IdContacto],[Telefono],[IdRegistro]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------
-- ALHMENSAJES
-----------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------
-- ALEPOLITICA
--           Contendrá los valores a ser evaluados para generar la alerta
-----------------------------------------------------------------------------------------------------------------------------
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALELISTACONTACTO]') AND type in (N'U'))
DROP TABLE [dbo].[ALEPOLITICA]
GO

CREATE TABLE [dbo].[ALEPOLITICA](
	[IdPolitica]         [varchar](10) NOT NULL, -- Nemónico que haga alusión a la política que se está evaluando
	[Descripcion]        [varchar](80) NOT NULL, -- Descripción de la política que se estará evalundo         
	[IdAlerta]           [varchar](10) NOT NULL, -- Nemónico que haga alusión a la alerta que deberá ser emitid
	[PuntoDeVenta]       [varchar](20) NOT NULL, -- Punto de venta a ser evaluado
	
	[FechaInicial]      [int]          NOT NULL, -- Formato CCYYMMDD - Fecha de inicio de vigencia de la política
	[FechaFinal]		[int]          NOT NULL, -- Formato CCYYMMDD - Fecha de Fin de vigencia de la política
	[HoraInicial]		[int]          NOT NULL, -- Formato HHMMSSMM - Hora de inicial para evalar información
	[HoraFinal]			[int]          NOT NULL, -- Formato HHMMSSMM - Hora de Final para evalar información
	[CampoAValidar]     [varchar] (20) NOT NULL, -- Indicará el valor al cual hará alusión la política (i. e. OrdenesDeCompra)
	[CantVarMax]        [decimal](5,2) NOT NULL, -- % de variación máxima aceptable en crecimiento de cantidad  - Alertar máximo
	[MontVarMax]        [decimal](5,2) NOT NULL, -- % de variación máxima en crecimiento de monto - Alertar máximo
	[MinFecuencia]      [tinyint]      NOT NULL, -- Cantidad de minutos que deberá transcurrir para obtener la siguiente muestra de datos.
	[CantVarMin]        [int]          NOT NULL, -- % de variación mínima en crecimiento de monto   - Alertar mínimo
	[MontVarMin]        [int]          NOT NULL, -- % de variación mínima en crecimiento de monto   - Alertar mínimo

	[Estado]             [varchar](10) NOT NULL, -- ACTIVO, INACTIVO -- indicará si debe o no emitir el mensaje.    
	[EstadoLogico]       [bigint] NOT NULL, -- Estdo del registro Otro = Borrado  0 = Activo << se asignará el valor del identity al borrarse lógicamente
	[FechaCreacion]      [int] NOT NULL, -- Formato CCYYMMDD
	[HoraCreacion]       [int] NOT NULL, -- Formato HHMMSSMM	
	[FechaModificacion]  [int] NOT NULL, -- Formato CCYYMMDD 
	[HoraModifcacion]    [int] NOT NULL, -- Formato HHMMSSMM
	[IdRegistro]         [bigint] IDENTITY(1,1) -- Identificador interno del registro
) ON [PRIMARY]
GO

CREATE UNIQUE INDEX [ALEPOLITICA_01] ON [dbo].[ALEPOLITICA](
	[EstadoLogico],[IdPolitica],[FechaInicial],[HoraInicial]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
*/
