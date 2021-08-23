using System;
using IniParser;
using IniParser.Model;
using IniParser.Exceptions;
using System.Data.SqlClient;
using System.Data;
using System.Collections.Generic;

namespace DxLatamModuloAlertas
{   
    abstract public class EntidadSQL:BDDSQL
    {
        public EntidadSQL() {
            //this->BDDSQL();
        }

        protected int EjecutarInsertOUpdate() {

            if (ConexionABaseDeDatos() != 0)
                return 1;

            if (EjecutarTransacional(strQuery) != 0)
                return 1;

            return 0;

        }

        protected int EjecutarConsulta() {
          
            if (ConexionABaseDeDatos() != 0)
                return 1;

            if (Consultar(strQuery) != 0)
                return 1;

            return 0;
        }

        public abstract int TrabajarResultados (SqlDataReader reader);
        
        private int Consultar(string script) {

            // For remote connection, remote server name / ServerInstance needs to be specified  
            try
            {
                using var cmd = new SqlCommand(script, connection);
                SqlDataReader reader = cmd.ExecuteReader();
                TrabajarResultados(reader);
            }
            catch (Exception e)
            {
                Console.WriteLine($"SqlCommand Error {e.Message}");                
            }
            finally
            {
                connection.Close();
            }

            return 0;
        }
    }
}
