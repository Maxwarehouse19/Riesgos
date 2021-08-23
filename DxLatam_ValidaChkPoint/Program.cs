using System;

using DxLatamModuloAlertas;
using System.Threading;
using IniParser;
using IniParser.Model;


namespace DxLatam_ValidaChkPoint
{
    class Program
    {

        static string sol_Estado = string.Empty;
        static int sol_MinsEspera = 0;
        static string sol_FechaPrueba = string.Empty;        

        static DateTime getFechaUTC() { 
            DateTime timeNow = DateTime.Now;
            try
            {
                TimeZoneInfo utcZone = TimeZoneInfo.Utc;
                DateTime utcTimeNow = TimeZoneInfo.ConvertTime(timeNow, TimeZoneInfo.Local,
                                                               utcZone);
                return utcTimeNow.AddHours(-7);
            }
            // Handle exception
            //
            // As an alternative to simply displaying an error message, an alternate Eastern
            // Standard Time TimeZoneInfo object could be instantiated here either by restoring
            // it from a serialized string or by providing the necessary data to the
            // CreateCustomTimeZone method.
            catch (TimeZoneNotFoundException)
            {
               Console.WriteLine("UTC Zone cannot be found on the local system.");
            }
            catch (InvalidTimeZoneException)
            {
               Console.WriteLine("UTC Time Zone contains invalid or missing data.");
            }            
            catch (OutOfMemoryException)
            {
               Console.WriteLine("Not enough memory is available to load information on the UTC zone.");
            }
            // If we weren't passing FindSystemTimeZoneById a literal string, we also
            // would handle an ArgumentNullException.
            return timeNow;
        }

        static int LeerConfiguracion()
        {
            string[] args = Environment.GetCommandLineArgs();
            string RutaIni = string.Empty;
            //El primer argumento es la ruta del exe o dll
            RutaIni = args[1];

            /*************************************************************************
              * Leyendo archivo de configuración
              *************************************************************************/
            try
            {
                Console.WriteLine("<<< MÓDULO DE ALERTAS - ROBOT DE ANÁLISIS DE CHECK POINTS >>> ");
                // if (string.IsNullOrEmpty(RutaIni))
                // {
                //     Console.WriteLine("AtenderSolicitudMensajes - Valor requerido: Ruta de archivo ini ");
                //     return 1;
                // }
                //
                // var parser = new FileIniDataParser();
                // IniData data = parser.ReadFile(RutaIni);// "..\\..\\SRC\\SETUP.INI");
                //
                // sol_Estado = data["ValidaChkPoint"]["Estado"];                
                // sol_MinsEspera = Int32.Parse(data["ValidaChkPoint"]["CantMinsEspera"]);
                // sol_FechaPrueba = data["ValidaChkPoint"]["FechaPrueba"];
                //
                CONFIG cCONFIG = new CONFIG();
                string varIdModulo = "CHKPNT";

                if (cCONFIG.ConsultarActivos(varIdModulo) != 0)
                {
                    Console.WriteLine("AtenderSolicitudMensajes - No hay parametros en BDD");
                    return 1;
                }

                foreach (registroCONFIG rCONFIG in cCONFIG.ListaCONFIG)
                {
                    //if(rCONFIG.IdParametro == "TWI_MODE")
                    if (rCONFIG.IdParametro == "Estado")
                        sol_Estado = rCONFIG.Valor;
                    else if (rCONFIG.IdParametro == "MinsEspera")
                        sol_MinsEspera = Int32.Parse(rCONFIG.Valor);
                    else if (rCONFIG.IdParametro == "FechaPrue")
                        sol_FechaPrueba = rCONFIG.Valor;
                }

                Console.WriteLine("Parámetros Estado:{0}, CantMinsEspera {1}, FechaPrueba {2} "
                   , sol_Estado, sol_MinsEspera, sol_FechaPrueba);

                if (sol_MinsEspera < 0)
                    return -1;

                return 0;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                return 1;
            }
        }
        static void Main(string[] args)    {

            BDDSQL cBDDSQL = new BDDSQL();
            ALECHKPOINT cALECHKPOINT = new ALECHKPOINT();            

            do
            {
                if (LeerConfiguracion() != 0)
                    return;

                if (sol_Estado != "ACTIVO")
                {
                    Console.WriteLine("ValidaChkpoint - Estado {0} ", sol_Estado);
                    return;
                }

                DateTime localDate = getFechaUTC();//DateTime.Now;                
                string FechaActual = localDate.ToString("yyyyMMdd");
                string HoraActual = localDate.ToString("HHmmss");

                if (!string.IsNullOrEmpty(sol_FechaPrueba) &&
                        sol_FechaPrueba != "HOY")
                    FechaActual = sol_FechaPrueba;

                TimeSpan intervalM = new TimeSpan(0, sol_MinsEspera, 0);
                        
                string NombreSP = string.Empty;// "ChkPoint_RealizarAnalisis";
            
                Console.WriteLine("Parámetros: Fecha: {0} ,Hora: {1}, Estado {2}", FechaActual, HoraActual, sol_Estado);
            
                cALECHKPOINT.ListaALECHKPOINTs.Clear();

                if (cALECHKPOINT.ConsultarActivosVigentes() != 0)
                {
                    Console.WriteLine("No hay checkpoints activos y vigentes");
                    return;
                }

                foreach (registroALECHKPOINT CHKPOINT in cALECHKPOINT.ListaALECHKPOINTs)
                {
                    NombreSP = CHKPOINT.sp_Validacion;

                    cBDDSQL.ListaParametros.Clear();

                    cBDDSQL.ListaParametros.Add(
                        new parametros_sp
                        {
                            Nombre = "@IdRegistro",
                            sValor = string.Empty,
                            iValor = Int64.Parse(CHKPOINT.IdRegistro),
                            tipoParametro = TipoParametro.Entero
                        }
                    );
                    cBDDSQL.ListaParametros.Add(
                        new parametros_sp
                        {
                            Nombre = "@FechaActual",
                            sValor = string.Empty,
                            iValor = Int32.Parse(localDate.ToString(FechaActual)),
                            tipoParametro = TipoParametro.Entero
                        }
                    );

                    cBDDSQL.ListaParametros.Add(
                        new parametros_sp
                        {
                            Nombre = "@HoraCompleta",
                            sValor = string.Empty,
                            iValor = Int32.Parse(localDate.ToString("HHmm")),
                            tipoParametro = TipoParametro.Entero
                        }
                    );

                    cBDDSQL.EjecutaStoredProcedure(NombreSP);
                }

                Console.WriteLine("Esperando {0} Minutos", sol_MinsEspera);
                Thread.Sleep(intervalM);
                localDate = DateTime.Now;
                HoraActual = localDate.ToString("HHmmss");
                Console.WriteLine("Fin de Espera", FechaActual, HoraActual);

            } while (true);
        }
    }
}
 