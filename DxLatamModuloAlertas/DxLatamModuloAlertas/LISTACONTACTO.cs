using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace DxLatamModuloAlertas
{
    class registroLISTACONTACTO {

        public string IdRegistro        = string.Empty;
        public string IdLista           = string.Empty;
        public string Descripcion       = string.Empty;
        public string IdContacto        = string.Empty;
        public string Estado            = string.Empty;
        public string EstadoLogico      = string.Empty;
        public string FechaCreacion     = string.Empty;
        public string HoraCreacion      = string.Empty;
        public string FechaModificacion = string.Empty;
        public string HoraModifcacion   = string.Empty;       
    }
    class LISTACONTACTO : EntidadSQL {

        public List<registroLISTACONTACTO> ListaListaContactos = new List<registroLISTACONTACTO>();

        public override int TrabajarResultados(SqlDataReader reader) {
            
            ListaListaContactos.Clear();

            while (reader.Read())
            {         
                ListaListaContactos.Add(new registroLISTACONTACTO
                {

                    IdRegistro        = reader["IdRegistro"].ToString(),
                    IdLista           = reader["IdLista"].ToString(),
                    Descripcion       = reader["Descripcion"].ToString(),
                    IdContacto        = reader["IdContacto"].ToString(),
                    Estado            = reader["Estado"].ToString(),
                    EstadoLogico      = reader["EstadoLogico"].ToString(),
                    FechaCreacion     = reader["FechaCreacion"].ToString(),
                    HoraCreacion      = reader["HoraCreacion"].ToString(),
                    FechaModificacion = reader["FechaModificacion"].ToString(),
                    HoraModifcacion   = reader["HoraModifcacion"].ToString()

                });

            }

            return 0;
        }

        public int ConsultarActivos() {
            strQuery = "SELECT * FROM ALELISTACONTACTO WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' ";
            if (EjecutarConsulta() != 0)
                return 1;

            //Console.WriteLine();
            //foreach (registroLISTACONTACTO LISTACONTACTO in ListaListaContactos)
            //{
            //    Console.WriteLine(LISTACONTACTO);
            //}

            return 0;
        }

        public int ConsultaUnaLista(string prIdLista)
        {
            if (string.IsNullOrEmpty(prIdLista)) {
                Console.WriteLine("ConsultaUnaLista - Valor requerido Código de Lista");
                return 1;
            }

            strQuery = "SELECT * FROM ALELISTACONTACTO WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO'"+
                       " AND IdLista = \'"+ prIdLista + "\'";
            
            if (EjecutarConsulta() != 0)
                return 1;

           // if (ListaListaContactos.Count == 0) {
           //     Console.WriteLine("ConsultaUnaLista - No hay registros para Id {0}", prIdLista);
           //     return 1;
           // }
           
            return 0;
        }
    }
}
