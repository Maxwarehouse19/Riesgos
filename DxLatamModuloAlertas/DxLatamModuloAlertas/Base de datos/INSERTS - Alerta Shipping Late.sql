--SELECT * FROM ALECHKPOINT

insert into ALECHKPOINT (
--IdRegistro,
IdChkPoint,FechaVigencia,HoraInicial
,Descripicion,sp_Validacion,IdMensaje,MensajeInf
,MensajSup,UniRevision,Periodicidad,Estado
,HoraFinal,EstadoLogico
)
select --IdRegistro,
'CHKSHIPIN2'IdChkPoint
,FechaVigencia
,HoraInicial
,'Shipping Late'Descripicion
,'ChkPoint_ShippingLate'sp_Validacion
,IdMensaje
,MensajeInf
,MensajSup
,UniRevision
,Periodicidad
,Estado
,HoraFinal
,EstadoLogico
--select *
from ALECHKPOINT where IdChkPoint = 'CHKSHIPING' and EstadoLogico = 0 and IdMensaje = 'SHIPING'

--select * from ALTCHKPOINT where IdChkPoint = 'SHIPING' and EstadoLogico = 0 