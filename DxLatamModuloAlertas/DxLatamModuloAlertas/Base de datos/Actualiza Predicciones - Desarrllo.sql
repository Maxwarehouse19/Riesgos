select CanalyTiposOrden, count(*) from [PREDICCION] where EstadoLogico != 0 group by CanalyTiposOrden
select CanalyTiposOrden, count(*) from [PREDICCION] where EstadoLogico = 0 group by CanalyTiposOrden


select * from [PREDICCION] where EstadoLogico = 0 


