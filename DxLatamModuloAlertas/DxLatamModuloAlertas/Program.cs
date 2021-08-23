

using System;
//using ListaDeContactos;



namespace DxLatamModuloAlertas
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Modulo Alertas - Se esperaba ruta de ini en agumentos");
                return;
            }


            AtenderSolicitudMensajes cAtenderSolicitudMensajes = new AtenderSolicitudMensajes();
            cAtenderSolicitudMensajes.Main();

        }
    }
}
