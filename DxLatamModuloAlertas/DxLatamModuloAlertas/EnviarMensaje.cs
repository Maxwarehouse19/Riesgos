/* GREYNOSO 20210122 agregar lógica para enviar mensajitos con twilio
 * Tutorial https://www.youtube.com/watch?v=ndxQXnoDIj8 
            https://www.twilio.com/blog/2016/04/send-an-sms-message-with-c-in-30-seconds.html*/
using System;
using Twilio;
//using Twilio.Rest.Messaging.V1;
using Twilio.Exceptions;
using Twilio.Rest.Api.V2010.Account;

using IniParser;
using IniParser.Model;
using IniParser.Exceptions;

namespace DxLatamModuloAlertas
{
    class EnviarMensaje
    {
        public string TelefonoDestino   = string.Empty;
        public string Mensaje           = string.Empty;
        public string Error            = string.Empty;

        private string twilio_accountSid = string.Empty;
        private string twilio_authToken  = string.Empty;
        private string twilio_phone      = string.Empty;
        private string twilio_Mode       = string.Empty;
        private string RutaIni           = string.Empty;
        
        private CONFIG cCONFIG = new CONFIG();

        public EnviarMensaje()
        {
            string[] args = Environment.GetCommandLineArgs();
            RutaIni = string.Empty;
            //El primer argumento es la ruta del exe o dll
            RutaIni = args[1];//string.Concat(args);
        }

        public int Main()  {


            if (string.IsNullOrEmpty(twilio_accountSid) ||
                string.IsNullOrEmpty(twilio_authToken) ||
                string.IsNullOrEmpty(twilio_phone)) {

                if (LeerConfiguracion() != 0)
                    return 1;                
            }

            try
            {
                if (twilio_Mode == "FULL")
                {
                    //Enviando mensajito         
                    TwilioClient.Init(twilio_accountSid, twilio_authToken);

                    var twilio_message = MessageResource.Create(
                                body: Mensaje,//"Mensajito: Programa de alertas",
                                from: new Twilio.Types.PhoneNumber(twilio_phone),
                                to: new Twilio.Types.PhoneNumber(TelefonoDestino)
                    );
                }
                else {
                    Console.WriteLine("Twilio DEBUG: to:{0} body: {1}", TelefonoDestino, Mensaje);
                }
                return 0;
            }
            catch (ApiException e)
            {
                Error = e.Message;// + "Twilio Error {" + e.Code + "} - {" + e.MoreInfo + "}";
                Error = Error.Replace("\'", "\"");
                Console.WriteLine(e.Message);
                Console.WriteLine($"Twilio Error {e.Code} - {e.MoreInfo}");
                return 1;
            }
        }

        private int LeerConfiguracion() {

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

                // Find your Account Sid and Token at twilio.com/console
                // and set the environment variables. See http://twil.io/secure
               twilio_accountSid = data["Twilio"]["TWILIO_ACCOUNT_SID"];
               twilio_authToken  = data["Twilio"]["TWILIO_AUTH_TOKEN"];
               twilio_phone      = data["Twilio"]["TWILIO_PHONE_FROM"];
               //twilio_Mode = data["Twilio"]["TWILIO_MODE"];

                string varIdModulo = "ALERTA";

                if (cCONFIG.ConsultarActivos(varIdModulo) != 0)
                {
                    Console.WriteLine("AtenderSolicitudMensajes - No hay parametros en BDD");
                    return 1;
                }

                foreach (registroCONFIG rCONFIG in cCONFIG.ListaCONFIG)
                {
                    if(rCONFIG.IdParametro == "TWI_MODE")
                        twilio_Mode =  rCONFIG.Valor;
                }

                Console.WriteLine("Parámetros TWILIO_MODE:{0}"
                   , twilio_Mode);


                Console.WriteLine("Conexión a Twilio OK ");
                return 0;
            }
            catch (ApiException e)
            {

                Error = e.Message + "IniData Error {" + e.Code + "} - {" + e.MoreInfo + "}";
                Console.WriteLine(e.Message);
                Console.WriteLine($"IniData Error {e.Code} - {e.MoreInfo}");
                return 1;
            }
        }

    }
}
