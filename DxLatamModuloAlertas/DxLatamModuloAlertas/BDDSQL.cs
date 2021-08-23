using System;
using IniParser;
using IniParser.Model;
using IniParser.Exceptions;
using System.Data.SqlClient;
using System.Data;
using System.Collections.Generic;

namespace DxLatamModuloAlertas
{    
    public enum TipoParametro { Entero, Cadena};

    public class parametros_sp {
        public string Nombre  = string.Empty;  // @NombreVariable
        public string sValor  = string.Empty;  // valor si es cadena
        public long   iValor  = 0;             // valor si es entero
        public TipoParametro tipoParametro;
    }
    public class BDDSQL
    {
        public List<parametros_sp> ListaParametros = new List<parametros_sp>();

        protected string strQuery;

        private string bdd_servidor      = string.Empty; 
        private string bdd_usuario       = string.Empty;
        private string bdd_password      = string.Empty;
        private string databaseName      = string.Empty;
        private string RutaIni           = string.Empty;

        protected SqlConnection connection = null;

        public BDDSQL() {
            string[] args = Environment.GetCommandLineArgs();
            RutaIni = string.Empty;
            //El primer argumento es la ruta del exe o dll
            if (!string.IsNullOrEmpty(args[1]))
                RutaIni = args[1];//string.Concat(args);
            else
                RutaIni = args[0]; // no venía la ruta del exe
        }

        public int EjecutaStoredProcedure(string spName) {

            if (ConexionABaseDeDatos() != 0)
                return 1;

            if (EjecutaStoresProcedure(spName) != 0)
                return 1;

            return 0;

        }

        protected int EjecutaStoresProcedure(string spName)
        {
            try
            {
                // 1.  create a command object identifying
                //     the stored procedure
                SqlCommand cmd = new SqlCommand(spName, connection);

                // 2. set the command object so it knows
                //    to execute a stored procedure
                cmd.CommandType = CommandType.StoredProcedure;


                foreach (parametros_sp PARAMETRO in ListaParametros)
                {
                    // 3. add parameter to command, which
                    //    will be passed to the stored procedure
                    if(PARAMETRO.tipoParametro == TipoParametro.Entero)
                        cmd.Parameters.Add(new SqlParameter(PARAMETRO.Nombre, PARAMETRO.iValor));
                    else 
                        cmd.Parameters.Add(new SqlParameter(PARAMETRO.Nombre, PARAMETRO.sValor));
                }
                // execute the command
                SqlDataReader rdr = cmd.ExecuteReader();

                // iterate through results, printing each to console
                while (rdr.Read())
                {                    
                    Console.WriteLine("Salida SP {0} resultado  {1}", spName, rdr["Mensaje"]);
                }

                //close data reader
                rdr.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Stored Procedure Exception Type: {0}", ex.GetType());
                Console.WriteLine("Message: {0}", ex.Message);                
            }
            finally
            {
                connection.Close();
            }

            return 0;
        }

        protected int EjecutarTransacional(string script)
        {

            SqlTransaction transaction;            
            transaction = connection.BeginTransaction("Dx_EnviaAlertas");
            using var cmd = new SqlCommand(script, connection);
            cmd.Transaction = transaction;
            
            try
            {
                cmd.CommandText = script;
                cmd.ExecuteNonQuery();
                transaction.Commit();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Commit Exception Type: {0}", ex.GetType());
                Console.WriteLine("  Message: {0}", ex.Message);

                // Attempt to roll back the transaction.
                try
                {
                    transaction.Rollback();
                    return 1;
                }
                catch (Exception ex2)
                {
                    // This catch block will handle any errors that may have occurred
                    // on the server that would cause the rollback to fail, such as
                    // a closed connection.
                    Console.WriteLine("Rollback Exception Type: {0}", ex2.GetType());
                    Console.WriteLine("  Message: {0}", ex2.Message);
                    return 1;
                }
            }
            finally
            {
                connection.Close();
            }

            return 0;
        }

        protected int ConexionABaseDeDatos() {

            // For remote connection, remote server name / ServerInstance needs to be specified  
            try
            {

                if (LeerConfiguracion(RutaIni) != 0)
                    return 1;

                string ConectionStr = /*"Provider=MSOLEDBSQL;*/"Server=" + bdd_servidor +
                                      "; Database=" + databaseName +
                                      "; UID=" + bdd_usuario +
                                      "; PWD=" + bdd_password + ";";

                connection = new SqlConnection(ConectionStr);
                connection.Open();

                //Console.WriteLine($"Conexión a base de datos OK");
            }
            catch (Exception e)
            {
                //Console.WriteLine(e.Message);
                Console.WriteLine($"SqlConnection Error {e.Message}");
                return 1;
            }

            return 0;
        }

        protected int LeerConfiguracion(string RutaIni)
        {

            /*************************************************************************
              * Leyendo archivo de configuración
              *************************************************************************/
            try
            {
                if (string.IsNullOrEmpty(RutaIni))
                {
                    Console.WriteLine("EnviarMensaje - Valor requerido: Ruta de archivo ini ");
                    return 1;
                }

                var parser = new FileIniDataParser();
                IniData data = parser.ReadFile(RutaIni);// "..\\..\\SRC\\SETUP.INI");

                //Conexión a base de datos
                bdd_servidor = data["BaseDeDatos"]["servidor"];
                bdd_usuario  = data["BaseDeDatos"]["usuario"];
                bdd_password = data["BaseDeDatos"]["password"];
                databaseName = data["BaseDeDatos"]["BDD"];
                return 0;
            }
            catch (Exception e)
            {
                //Console.WriteLine(e.Message);
                Console.WriteLine($"IniData Error {e.Message}");
                return 1;
            }
        }
    }
}
