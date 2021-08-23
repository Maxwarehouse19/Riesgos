using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace DxLatamModuloAlertas
{
    public class registroCONFIG {

        public string IdRegistro  = string.Empty;
        public string IdModulo    = string.Empty;
        public string IdParametro = string.Empty;
        public string Valor		  = string.Empty;
        public string Estado      = string.Empty;
        
    }
    public class CONFIG : EntidadSQL {

        public List<registroCONFIG> ListaCONFIG = new List<registroCONFIG>();

        public override int TrabajarResultados(SqlDataReader reader) {
            
            ListaCONFIG.Clear();

            while (reader.Read())
            {         
                ListaCONFIG.Add(new registroCONFIG
                {
                    IdRegistro  = reader["IdRegistro"].ToString(),
                    IdModulo    = reader["IdModulo"].ToString(),
                    IdParametro = reader["IdParametro"].ToString(),
                    Valor		= reader["Valor"].ToString(),
                    Estado      = reader["Estado"].ToString(),
                });

            }

            return 0;
        }

        public int ConsultarActivos( string prIdModulo) {
            strQuery = "SELECT * FROM ALECONFIG WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' ";
            
            if(!string.IsNullOrEmpty(prIdModulo))
                strQuery = strQuery + " AND IdModulo = '" + prIdModulo+"' ";
            
            if (EjecutarConsulta() != 0)
                return 1;
            
            return 0;
        }
    }
}
