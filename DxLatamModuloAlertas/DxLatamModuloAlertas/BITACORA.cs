using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace DxLatamModuloAlertas
{
    class registroBITACORA {

        public string IdRegistro   = string.Empty;
        public string Fecha        = string.Empty;
        public string Hora         = string.Empty;
        public string IdMensaje    = string.Empty;
        public string Criterio     = string.Empty;
        public string IdLista      = string.Empty;
        public string IdContacto   = string.Empty;
        public string Telefono     = string.Empty;
        public string Subject      = string.Empty;
        public string Mensaje      = string.Empty;
        public string Estado       = string.Empty;
        public string DescError    = string.Empty;
        public string EstadoLogico = string.Empty;

        public void Init() {
            IdRegistro = string.Empty;
            Fecha = string.Empty;
            Hora = string.Empty;
            IdMensaje = string.Empty;
            Criterio = string.Empty;
            IdLista = string.Empty;
            IdContacto = string.Empty;
            Telefono = string.Empty;
            Subject = string.Empty;
            Mensaje = string.Empty;
            Estado = string.Empty;
            DescError = string.Empty;
            EstadoLogico = string.Empty;
        }

    }
    class BITACORA : EntidadSQL {

        public List<registroBITACORA> ListaBITACORAs = new List<registroBITACORA>();

        public int Guardar (registroBITACORA prRegistroBITACORA) {

            prRegistroBITACORA.EstadoLogico = "0";

            strQuery = "INSERT INTO ALEBITACORA (Fecha,Hora,IdMensaje,Criterio,IdLista,IdContacto" 
                      +",Telefono,Subject,Mensaje,Estado,DescError,EstadoLogico) SELECT ";
            
            strQuery += prRegistroBITACORA.Fecha + ", ";
            strQuery += prRegistroBITACORA.Hora + ", ";
            strQuery += "\'" + prRegistroBITACORA.IdMensaje + "\', ";
            strQuery += "\'" + prRegistroBITACORA.Criterio  + "\', ";
            strQuery += "\'" +prRegistroBITACORA.IdLista    + "\', ";
            strQuery += "\'" +prRegistroBITACORA.IdContacto + "\', ";
            strQuery += "\'" +prRegistroBITACORA.Telefono   + "\', ";
            strQuery += "\'" +prRegistroBITACORA.Subject    + "\', ";
            strQuery += "\'" +prRegistroBITACORA.Mensaje    + "\', ";
            strQuery += "\'" +prRegistroBITACORA.Estado     + "\', ";
            strQuery += "\'" + prRegistroBITACORA.DescError + "\', ";
            strQuery += prRegistroBITACORA.EstadoLogico ;

            return EjecutarInsertOUpdate();
        }

        public override int TrabajarResultados(SqlDataReader reader) {

            ListaBITACORAs.Clear();

            while (reader.Read())
            {
                ListaBITACORAs.Add(new registroBITACORA
                {
                    IdRegistro   = reader["IdRegistro"].ToString(),
                    Fecha        = reader["Fecha"].ToString(),
                    Hora         = reader["Hora"].ToString(),
                    IdMensaje    = reader["IdMensaje"].ToString(),
                    Criterio     = reader["Criterio"].ToString(),
                    IdLista      = reader["IdLista"].ToString(),
                    IdContacto   = reader["IdContacto"].ToString(),
                    Telefono     = reader["Telefono"].ToString(),
                    Subject      = reader["Subject"].ToString(),
                    Mensaje      = reader["Mensaje"].ToString(),
                    Estado       = reader["Estado"].ToString(),
                    DescError    = reader["DescError"].ToString(),
                    EstadoLogico = reader["EstadoLogico"].ToString()

            });

            }

            return 0;
        }

        public int ConsultarActivos() {
            strQuery = "SELECT * FROM ALEBITACORA WITH(NOLOCK) WHERE EstadoLogico = 0 ";
            if (EjecutarConsulta() != 0)
                return 1;

          
            return 0;
        }

        public int ConsultarFecha(int prFecha, int prHora, string prEstado)
        {
            if (prFecha == 0) {
                Console.WriteLine("ConsultarFecha - Valor requerido Fecha");
            }

            strQuery = "SELECT * FROM ALEBITACORA WITH(NOLOCK) WHERE EstadoLogico = 0 " +
                       " AND Fecha  = " + prFecha.ToString();

            if (prHora >= 0)
                strQuery += " AND Hora  >= " + prHora.ToString();

            if (string.IsNullOrEmpty(prEstado))
                strQuery += " AND Estado = " + prFecha.ToString();

            if (EjecutarConsulta() != 0)
                return 1;

            if (ListaBITACORAs.Count == 0)
            {  
                return 1;
            }

            return 0;
        }
    }
}
