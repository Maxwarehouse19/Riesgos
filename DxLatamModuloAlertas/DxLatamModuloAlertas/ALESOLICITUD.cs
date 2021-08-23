using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace DxLatamModuloAlertas
{
    class registroSolicitud {

        public string IdRegistro = string.Empty;
        public string Fecha       = string.Empty;
        public string Hora        = string.Empty;
        public string IdMensaje   = string.Empty;
        public string Criterio    = string.Empty;
        public string Estado      = string.Empty;
        public string Detalle     = string.Empty;
        public string DescError   = string.Empty;
        public string EstadoLogico= string.Empty;
    }
    class SOLICITUD : EntidadSQL {

        public List<registroSolicitud> ListaSolicitudes = new List<registroSolicitud>();

        public override int TrabajarResultados(SqlDataReader reader) {

            ListaSolicitudes.Clear();

            while (reader.Read())
            {
                ListaSolicitudes.Add(new registroSolicitud
                {
                    IdRegistro =  reader["IdRegistro"  ].ToString(),
                    Fecha =       reader["Fecha"       ].ToString(),
                    Hora =        reader["Hora"        ].ToString(),
                    IdMensaje =   reader["IdMensaje"   ].ToString(),
                    Criterio =    reader["Criterio"    ].ToString(),
                    Estado =      reader["Estado"      ].ToString(),
                    Detalle =     reader["Detalle"     ].ToString(),
                    DescError =   reader["DescError"   ].ToString(),
                    EstadoLogico =reader["EstadoLogico"].ToString()
                });
            }

            return 0;
        }

        public int ConsultarActivos() {
            strQuery = "SELECT * FROM ALESOLICITUD WITH(NOLOCK) WHERE EstadoLogico = 0 ";
            if (EjecutarConsulta() != 0)
                return 1;
            return 0;
        }

        public int ConsultarSolicitudesPendientes(string prFecha)
        {
            strQuery = "SELECT * FROM ALESOLICITUD WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'PENDIENTE' " +
                       " AND Fecha =" + prFecha;

            if (EjecutarConsulta() != 0)
                return 1;

            if (ListaSolicitudes.Count == 0)
            {  
                return 1;
            }           
            return 0;
        }

        public int MarcarProcesado(string prIdRegistro) {

            strQuery = "UPDATE ALESOLICITUD SET Estado = 'PROCESADO' WHERE EstadoLogico = 0 AND Estado = 'PENDIENTE' " +
                       " AND IdRegistro =" + prIdRegistro;

            return EjecutarInsertOUpdate();
        }

        public int MarcarError(string prIdRegistro)
        {

            strQuery = "UPDATE ALESOLICITUD SET Estado = 'ERROR' WHERE EstadoLogico = 0 AND Estado = 'PENDIENTE' " +
                       " AND IdRegistro =" + prIdRegistro;

            return EjecutarInsertOUpdate();
        }

    }
}
