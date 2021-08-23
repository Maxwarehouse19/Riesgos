using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace DxLatamModuloAlertas
{
    class registroContacto {

        public string IdContacto = string.Empty;
        public string Telefono = string.Empty;
        public string NombreCompleto = string.Empty;
        public string Puesto = string.Empty;
        public string ModoContacto = string.Empty;
        public string Estado = string.Empty;
        public string EstadoLogico = string.Empty;
        public string FechaCreacion = string.Empty;
        public string HoraCreacion = string.Empty;
        public string FechaModificacion = string.Empty;
        public string HoraModifcacion = string.Empty;
        public string IdRegistro = string.Empty;
    }
    class CONTACTO : EntidadSQL {

        public List<registroContacto> ListaContactos = new List<registroContacto>();

        public override int TrabajarResultados(SqlDataReader reader) {

            ListaContactos.Clear();

            while (reader.Read())
            {
                ListaContactos.Add(new registroContacto
                {
                    IdContacto = reader["IdContacto"].ToString(),
                    Telefono = reader["Telefono"].ToString(),
                    NombreCompleto = reader["NombreCompleto"].ToString(),
                    Puesto = reader["Puesto"].ToString(),
                    ModoContacto = reader["ModoContacto"].ToString(),
                    Estado = reader["Estado"].ToString(),
                    EstadoLogico = reader["EstadoLogico"].ToString(),
                    FechaCreacion = reader["FechaCreacion"].ToString(),
                    HoraCreacion = reader["HoraCreacion"].ToString(),
                    FechaModificacion = reader["FechaModificacion"].ToString(),
                    HoraModifcacion = reader["HoraModifcacion"].ToString(),
                    IdRegistro = reader["IdRegistro"].ToString()
                });

            }

            return 0;
        }

        public int ConsultarActivos() {
            strQuery = "SELECT * FROM ALECONTACTOS WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' ";
            if (EjecutarConsulta() != 0)
                return 1;

            //Console.WriteLine();
            //foreach (registroContacto Contacto in ListaContactos)
            //{
            //    Console.WriteLine(Contacto);
            //}

            return 0;
        }

        public int ConsultarContactoActivo(string prIdContacto)
        {
            strQuery = "SELECT * FROM ALECONTACTOS WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' "+
                       " AND IdContacto = \'" + prIdContacto + "\'";

            if (EjecutarConsulta() != 0)
                return 1;

            if (ListaContactos.Count == 0)
            {  
                return 1;
            }

           // Console.WriteLine();
           // foreach (registroContacto Contacto in ListaContactos)
           // {
           //     Console.WriteLine(Contacto);
           // }

            return 0;
        }
    }
}
