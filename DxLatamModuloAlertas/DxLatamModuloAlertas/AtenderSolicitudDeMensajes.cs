/* GREYNOSO 20210122 agregar lógica para enviar mensajitos con twilio
 * Tutorial https://www.youtube.com/watch?v=ndxQXnoDIj8 
            https://www.twilio.com/blog/2016/04/send-an-sms-message-with-c-in-30-seconds.html*/
using System;

using IniParser;
using IniParser.Model;
using IniParser.Exceptions;

using System.Threading;

namespace DxLatamModuloAlertas
{
    class AtenderSolicitudMensajes
    {

        private string RutaIni = string.Empty;

        private string sol_Estado       = string.Empty;
        private int    sol_CantLecturas = 0;
        private int    sol_SegsEspera = 0;
        private int    sol_MinsEspera = 0;
        private string sol_FechaPrueba = string.Empty;

        private SOLICITUD cSOLICITUD = new SOLICITUD();
        private CONFIG cCONFIG = new CONFIG();

        private string IdMensaje = string.Empty;
        private string Criterio =  string.Empty;
        EnviaMensajeAListaDeContactos Lista = new EnviaMensajeAListaDeContactos();

        static DateTime getFechaUTC()
        {
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
                Console.WriteLine("Not enough memory is available to load information on the Eastern Standard Time zone.");
            }
            // If we weren't passing FindSystemTimeZoneById a literal string, we also
            // would handle an ArgumentNullException.
            return timeNow;
        }

        public AtenderSolicitudMensajes()
        {
            string[] args = Environment.GetCommandLineArgs();
            RutaIni = string.Empty;
            //El primer argumento es la ruta del exe o dll
            RutaIni = args[1];
        }

        public int Main()  {
            int CantLecturas = 0;//, SegsEspera = 0, MinsEspera = 0;
            Console.WriteLine("<<< MÓDULO DE ALERTAS - ROBOT DE ALERTAS >>> ");

            do{ 
                try
                {
                    if (LeerConfiguracion() != 0)
                        return 1;

                    if (sol_Estado != "ACTIVO") {
                        Console.WriteLine("AtenderSolicitudMensajes - Estado {0} ", sol_Estado);
                        return 0;
                    }

                    DateTime localDate = getFechaUTC();// DateTime.Now;
                    
                    string FechaActual = localDate.ToString("yyyyMMdd");
                    string HoraActual = localDate.ToString("HHmmss");

                    if (!string.IsNullOrEmpty(sol_FechaPrueba) &&
                            sol_FechaPrueba != "HOY")
                        FechaActual = sol_FechaPrueba;

                    TimeSpan intervalS = new TimeSpan(0, 0, sol_SegsEspera);
                    TimeSpan intervalM = new TimeSpan(0, sol_MinsEspera, 0);
               
                    Console.WriteLine("Parámetros: Fecha: {0} ,Hora: {1}, Estado:{2}", FechaActual, HoraActual, sol_Estado);

                    if (cSOLICITUD.ConsultarSolicitudesPendientes(FechaActual) != 0)
                    {
                        CantLecturas = CantLecturas + 1;
                        Console.WriteLine("No hay Solicitud de Alertas Fecha: {0} ,Hora: {1}", FechaActual, HoraActual);

                        if (CantLecturas == sol_CantLecturas)
                        {
                            Console.WriteLine("Max Lecturas alcanzado Esperando {0} Minutos", sol_MinsEspera);
                            Thread.Sleep(intervalM);
                            localDate = DateTime.Now;
                            HoraActual = localDate.ToString("HHmmss");
                            Console.WriteLine("Fin de Espera Fecha: {0} ,Hora: {1}", FechaActual, HoraActual);
                            CantLecturas = 0;
                        }
                        else
                        {
                            Console.WriteLine("Lectura No. {0}, Esperando {1} Segundos", CantLecturas, sol_SegsEspera);
                            Thread.Sleep(intervalS);
                            localDate = DateTime.Now;
                            HoraActual = localDate.ToString("HHmmss");                            
                            Console.WriteLine("Fin de Espera Fecha: {0} ,Hora: {1}", FechaActual, HoraActual);
                        }
                    }
                    else
                    {
                        foreach (registroSolicitud SOLICITUD in cSOLICITUD.ListaSolicitudes)              {

                            IdMensaje = SOLICITUD.IdMensaje;
                            Criterio = SOLICITUD.Criterio;
                            if (Lista.Enviar(IdMensaje, Criterio, SOLICITUD.Detalle) == 0)
                                cSOLICITUD.MarcarProcesado(SOLICITUD.IdRegistro);
                            else
                                cSOLICITUD.MarcarError(SOLICITUD.IdRegistro);
                        }
                    }
                   
                }
                catch (Exception e)
                {                
                    Console.WriteLine(e.Message);                
                    return 1;
                }
            } while (true);
            return 0;
        }

        private int StrToInt(string input) {
            try
            {
                int result = Int32.Parse(input);                
                return result;
            }
            catch (FormatException)
            {
                Console.WriteLine($"Unable to parse '{input}'");
                return -1;
            }
        }

        private int LeerConfiguracion() {

            /*************************************************************************
              * Leyendo archivo de configuración
              *************************************************************************/
            try
            {
                // if (string.IsNullOrEmpty(RutaIni))
                // {
                //     Console.WriteLine("AtenderSolicitudMensajes - Valor requerido: Ruta de archivo ini ");
                //     return 1;
                // }
                //
                // var parser = new FileIniDataParser();
                // IniData data = parser.ReadFile(RutaIni);// "..\\..\\SRC\\SETUP.INI");
                //                 
                // sol_Estado      = data["AgenteAlertas"]["Estado"];
                // sol_CantLecturas= StrToInt(data["AgenteAlertas"]["CantLecSinAlerta"]);
                // sol_SegsEspera  = StrToInt(data["AgenteAlertas"]["CantSecEspera"]);
                // sol_MinsEspera  = StrToInt(data["AgenteAlertas"]["CantMinsEspera"]);
                // sol_FechaPrueba = data["AgenteAlertas"]["FechaPrueba"];

                string varIdModulo = "ALERTA";

                if (cCONFIG.ConsultarActivos(varIdModulo) !=0) {
                    Console.WriteLine("AtenderSolicitudMensajes - No hay parametros en BDD");
                    return 1;
                }

                foreach (registroCONFIG rCONFIG in cCONFIG.ListaCONFIG)
                {
                    //if(rCONFIG.IdParametro == "TWI_MODE")
                    if (rCONFIG.IdParametro == "Estado")
                        sol_Estado = rCONFIG.Valor;
                    else if (rCONFIG.IdParametro == "LecSinAler")
                        sol_CantLecturas = StrToInt(rCONFIG.Valor);
                    else if (rCONFIG.IdParametro == "SecEspera")
                        sol_SegsEspera = StrToInt(rCONFIG.Valor);
                    else if (rCONFIG.IdParametro == "MinsEspera")
                        sol_MinsEspera = StrToInt(rCONFIG.Valor);
                    else if (rCONFIG.IdParametro == "FechaPrue")
                        sol_FechaPrueba = rCONFIG.Valor;
                }

                Console.WriteLine("Parámetros Estado:{0}, CantLecSinAlerta: {1}, CantSecEspera {2}, CantMinsEspera {3}, FechaPrueba {4} "
                    , sol_Estado, sol_CantLecturas, sol_SegsEspera, sol_MinsEspera, sol_FechaPrueba);

                if (sol_CantLecturas < 0 ||
                     sol_SegsEspera < 0 ||
                     sol_MinsEspera < 0)
                    return -1;

                return 0;
            }
            catch (Exception e) {
                Console.WriteLine(e.Message);
                return 1;
            }
        }

    }
}
