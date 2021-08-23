select * from ALECONTACTOS
select * from ALELISTACONTACTO
select * from ALEMENSAJE
-- truncate table ALEBITACORA
select * from ALEBITACORA (nolock) order by IdRegistro desc


--INSERT INTO ALEBITACORA (IdRegistro,Fecha,Hora,IdMensaje,Criterio,IdLista,IdContacto,Telefono,Subject,Mensaje,Estado,DescError,EstadoLogico) SELECT * FROM (, 20210205, 053018, 'SALEORDERS', 'MINIMO', 'L0OPERACIO', 'op01@email.com', '555-555-55-105', 'Alerta de Ordenes de Compra', 'Ordenes de compra no tienen nivel mínimo esperado', 'ENVIADO', '', ) X
--INSERT INTO ALEBITACORA (Fecha,Hora,IdMensaje,Criterio,IdLista,IdContacto,Telefono,Subject,Mensaje,Estado,DescError,EstadoLogico) 
--SELECT  20210205, 053335, 'SALEORDERS', 'MINIMO', 'L0OPERACIO', 'op02@email.com', '555-555-55-105', 'Alerta de Ordenes de Compra', 'Ordenes de compra no tienen nivel mínimo esperado', 'ENVIADO', 'Contacto no encontrado o inactivo', 0

--INSERT INTO ALEBITACORA (Fecha,Hora,IdMensaje,Criterio,IdLista,IdContacto,Telefono,Subject,Mensaje,Estado,DescError,EstadoLogico) SELECT 20210210, 110700, 'DESARROLLO', 'PRUEBA', 'L0DESARROL', 'joel@email.com', '+13053222307', 'Alerta de prueba', 'DxLatam: La calidad nunca es un accidente; siempre es el resultado de un esfuerzo de la inteligencia. John Ruskin', 'ERROR', 'Permission to send an SMS has not been enabled for the region indicated by the 'To' number: +13053222307.', 0
--INSERT INTO ALEBITACORA (Fecha,Hora,IdMensaje,Criterio,IdLista,IdContacto,Telefono,Subject,Mensaje,Estado,DescError,EstadoLogico) SELECT 20210210, 111326, 'DESARROLLO', 'PRUEBA', 'L0DESARROL', 'joel@email.com', '+13053222307', 'Alerta de prueba', 'DxLatam: La calidad nunca es un accidente; siempre es el resultado de un esfuerzo de la inteligencia. John Ruskin', 'ERROR', 'Permission to send an SMS has not been enabled for the region indicated by the \'To\' number: +13053222307.', 0

INSERT INTO ALEBITACORA (Fecha,Hora,IdMensaje,Criterio,IdLista,IdContacto,Telefono,Subject,Mensaje,Estado,DescError,EstadoLogico) SELECT 20210210, 111511, 'DESARROLLO', 'PRUEBA', 'L0DESARROL', 'joel@email.com', '+13053222307', 'Alerta de prueba', 'DxLatam: La calidad nunca es un accidente; siempre es el resultado de un esfuerzo de la inteligencia. John Ruskin', 'ERROR', 'Permission to send an SMS has not been enabled for the region indicated by the "To" number: +13053222307.', 0