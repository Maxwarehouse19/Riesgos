-- SELECT * FROM ALECONTACTOS
-- SELECT * FROM ALEMENSAJE
-- SELECT * FROM ALELISTACONTACTO
-- SELECT * FROM ALEBITACORA

truncate table ALECONTACTOS

insert into ALECONTACTOS ([IdContacto]	   ,[Telefono]		   ,[NombreCompleto]   ,[Puesto]           ,
[ModoContacto]     ,[Estado]           ,[EstadoLogico]     ,[FechaCreacion]    ,
[HoraCreacion]     ,[FechaModificacion],[HoraModifcacion]  )
SELECT * FROM (
 --SELECT 'ceo@email.com'  [IdContacto],'555-555-55-101'[Telefono],'Juan Pedro	'[NombreCompleto]   ,'CEO'                   [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  UNION 
 --SELECT 'vpo@email.com'  [IdContacto],'555-555-55-102'[Telefono],'Salomón		'[NombreCompleto]   ,'VP Operaciones'        [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  UNION 
 --SELECT 'vpv@email.com'  [IdContacto],'555-555-55-103'[Telefono],'Juan Carlos	'[NombreCompleto]   ,'VP Ventas'             [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  UNION 
 --SELECT 'bovp@email.com' [IdContacto],'555-555-55-104'[Telefono],'Joel Bandayan '[NombreCompleto]   ,'Business Optimization' [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  UNION 
 --SELECT 'op01@email.com' [IdContacto],'555-555-55-105'[Telefono],'Gustavo		'[NombreCompleto]   ,'Operaciones 1'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  UNION 
 --SELECT 'op02@email.com' [IdContacto],'555-555-55-106'[Telefono],'Marco		    '[NombreCompleto]   ,'Operaciones 2'         [Puesto], 'SMS' [ModoContacto], 'INACTI'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  UNION
 SELECT 'gaby@email.com' [IdContacto],'+50253089771'[Telefono],'Gaby'[NombreCompleto]   ,'Desarrollador'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  UNION
 SELECT 'gaby2@email.com' [IdContacto],'+50253089771'[Telefono],'Gaby'[NombreCompleto]   ,'Desarrollador'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  
 --UNION
 --SELECT 'edgar@email.com'[IdContacto],'+50254140689'[Telefono],'Edgar'[NombreCompleto]   ,'Jefe TI'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  union
 --SELECT 'rafa@email.com'[IdContacto],'+50245647567'[Telefono],'Rafa'[NombreCompleto]   ,'Jefe TI'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  
 --UNION  SELECT 'cristian@email.com'[IdContacto],'+50247027418'[Telefono],'Cristian Perdonmo'[NombreCompleto]   ,'PM'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  
 --UNION  SELECT 'jr@email.com'[IdContacto],'+50240034466'/*+50247027418'*/[Telefono],'JR'[NombreCompleto]   ,'IT DX'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  

 --SELECT 'joel@email.com'[IdContacto],'+13053222307'[Telefono],'Joel Bendayan'[NombreCompleto]   ,'BusinessOptimization'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  
 --UNION  SELECT 'salomon@email.com'[IdContacto],'+17867310028'[Telefono],'Salomon Levy'[NombreCompleto]   ,'VP Operaciones'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  
 --UNION  SELECT 'juanpedro@email.com'[IdContacto],'+50242107933'[Telefono],'Juan pedro'[NombreCompleto]   ,'VP Operaciones'         [Puesto], 'SMS' [ModoContacto], 'ACTIVO'[Estado], 0 [EstadoLogico] , 20210204  [FechaCreacion], 0 [HoraCreacion], 0 [FechaModificacion], 0 [HoraModifcacion]  
  )X

 
truncate table ALELISTACONTACTO
INSERT INTO ALELISTACONTACTO(
[IdLista]       ,[Descripcion]   ,   [IdContacto]	,   [Estado]        ,   [EstadoLogico]  ,   [FechaCreacion] ,   [HoraCreacion]  ,   
[FechaModificacion],[HoraModifcacion]  )
SELECT * FROM (
 --SELECT 'L0GERENCIA' [IdLista],'GERENCIA'  [Descripcion],'ceo@email.com'[IdContacto], 'ACTIVO'[Estado]  , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]   UNION
 --SELECT 'L0GERENCIA' [IdLista],'GERENCIA'  [Descripcion],'vpo@email.com'[IdContacto], 'ACTIVO'[Estado]  , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]   UNION
 --SELECT 'L0GERENCIA' [IdLista],'GERENCIA'  [Descripcion],'vpv@email.com'[IdContacto], 'ACTIVO'[Estado]  , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]   UNION
 --SELECT 'L0GERENCIA' [IdLista],'GERENCIA'  [Descripcion],'bovp@email.com'[IdContacto],'ACTIVO'[Estado]  , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion] UNION  
 --SELECT 'L0GERENCIA' [IdLista],'GERENCIA'  [Descripcion],'op01@email.com'[IdContacto],'ACTIVO'[Estado]  , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion] UNION  
 --SELECT 'L0GERENCIA' [IdLista],'GERENCIA'  [Descripcion],'op02@email.com'[IdContacto],'ACTIVO'[Estado]  , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion] UNION  
 --SELECT 'L0OPERACIO' [IdLista],'OPERACION' [Descripcion],'op01@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion] UNION  
 --SELECT 'L0OPERACIO' [IdLista],'OPERACION' [Descripcion],'op02@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210205 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion] UNION
 --SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'gaby2@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  UNION
 SELECT 'L0OPERACIO' [IdLista],'IT Desarrollo' [Descripcion],'gaby@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  UNION
 SELECT 'L0GERENCIA' [IdLista],'IT Desarrollo' [Descripcion],'gaby2@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  
 --UNION
 --SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'edgar@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion] union 
 --SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'rafa@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  
 --union SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'joel@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  
 --union SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'salomon@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  
 --union SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'juanpedro@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  
 
 --UNION SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'cristian@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  
 --UNION SELECT 'L0DESARROL' [IdLista],'IT Desarrollo' [Descripcion],'jr@email.com'[IdContacto] ,'ACTIVO'[Estado] , 0 [EstadoLogico],20210208 [FechaCreacion], 0 [HoraCreacion],0 [FechaModificacion],0 [HoraModifcacion]  

 )X

 truncate table ALEMENSAJE
 INSERT INTO ALEMENSAJE ( 
[IdMensaje],[Criterio] ,[IdLista]  ,[Subject]  ,[Mensaje]  ,[Estado]   ,[EstadoLogico]      ,[FechaCreacion]     ,[HoraCreacion]      ,[FechaModificacion] ,
[HoraModifcacion]   )
SELECT * FROM (
	SELECT 'CANTORDEN' [IdMensaje], 'MAXORDEN'[Criterio] , 'L0GERENCIA' [IdLista]  , 'Alerta de Ordenes de Compra'[Subject]  , 'Ordenes de compra superaron nivel máximo esperado' [Mensaje]  , 'ACTIVO' [Estado]   , 0[EstadoLogico]      , 20210204 [FechaCreacion]     ,0[HoraCreacion]      ,0[FechaModificacion] ,0[HoraModifcacion]   UNION
	SELECT 'CANTORDEN' [IdMensaje], 'MINORDEN'[Criterio] , 'L0OPERACIO' [IdLista]  , 'Alerta de Ordenes de Compra'[Subject]  , 'Ordenes de compra no tienen nivel mínimo esperado' [Mensaje]  , 'ACTIVO' [Estado]   , 0[EstadoLogico]      , 20210204 [FechaCreacion]     ,0[HoraCreacion]      ,0[FechaModificacion] ,0[HoraModifcacion]   
	--UNION
	--SELECT 'DESARROLLO' [IdMensaje], 'PRUEBA'[Criterio] , 'L0DESARROL' [IdLista]  , 'Alerta de prueba' [Subject]  , 'DxLatam: La calidad nunca es un accidente; siempre es el resultado de un esfuerzo de la inteligencia. John Ruskin' [Mensaje]  , 'ACTIVO' [Estado]   , 0[EstadoLogico]      , 20210208 [FechaCreacion]     ,0[HoraCreacion]      ,0[FechaModificacion] ,0[HoraModifcacion]   
)X