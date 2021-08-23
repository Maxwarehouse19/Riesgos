using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace DxLatamModuloAlertas
{
    class registroMENSAJE {

        public string IdRegistro =        string.Empty;
        public string IdMensaje =         string.Empty;
        public string Criterio =          string.Empty;
        public string IdLista =           string.Empty;
        public string Subject =           string.Empty;
        public string Mensaje =           string.Empty;
        public string Estado =            string.Empty;
        public string EstadoLogico =      string.Empty;
        public string FechaCreacion =     string.Empty;
        public string HoraCreacion =      string.Empty;
        public string FechaModificacion = string.Empty;
        public string HoraModifcacion =   string.Empty;
        
    }
    class MENSAJE : EntidadSQL {

        public List<registroMENSAJE> ListaMensajes = new List<registroMENSAJE>();

        public override int TrabajarResultados(SqlDataReader reader) {

            ListaMensajes.Clear();

            while (reader.Read())
            {
                ListaMensajes.Add(new registroMENSAJE
                {
                    IdRegistro =        reader["IdRegistro"].ToString(),
                    IdMensaje =         reader["IdMensaje"].ToString(),
                    Criterio =          reader["Criterio"].ToString(),
                    IdLista =           reader["IdLista"].ToString(),
                    Subject =           reader["Subject"].ToString(),
                    Mensaje =           reader["Mensaje"].ToString(),
                    Estado =            reader["Estado"].ToString(),
                    EstadoLogico =      reader["EstadoLogico"].ToString(),
                    FechaCreacion =     reader["FechaCreacion"].ToString(),
                    HoraCreacion =      reader["HoraCreacion"].ToString(),
                    FechaModificacion = reader["FechaModificacion"].ToString(),
                    HoraModifcacion =   reader["HoraModifcacion"].ToString()
                });

            }

            return 0;
        }

        public int ConsultarMensajeActivo(string prIdMensaje, string prCriterio)
        {
            strQuery = "SELECT * FROM ALEMENSAJE WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' "+
                       " AND IdMensaje = \'" + prIdMensaje + "\'"+
                       " AND Criterio = \'" + prCriterio + "\'";

            if (EjecutarConsulta() != 0)
                return 1;

            if (ListaMensajes.Count == 0)
            {
                return 1;
            }

            return 0;
        }

        public int ConsultarMensajesActivos() {
            strQuery = "SELECT * FROM ALEMENSAJE WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' ";
            if (EjecutarConsulta() != 0)
                return 1;

            //Console.WriteLine();
            //foreach (registroMENSAJE MENSAJE in ListaMensajes)
            //{
            //    Console.WriteLine(MENSAJE);
            //}

            return 0;
        }
    }
}
