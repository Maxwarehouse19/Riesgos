using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DxLatamModuloAlertas
{
    class EnviaMensajeAListaDeContactos
    {
        private CONTACTO         cCONTACTO         = new CONTACTO();
        private MENSAJE          cMENSAJE          = new MENSAJE();
        private LISTACONTACTO    cLISTACONTACTO    = new LISTACONTACTO();
        private registroBITACORA cregistroBITACORA = new registroBITACORA();
        private BITACORA         cBITACORA         = new BITACORA();
        private EnviarMensaje    cEnviarMensaje    = new EnviarMensaje();

        public int Enviar(string prIdMensaje, string prCriterio, string DetMensaje = null) {

            string ListaAnt = string.Empty;
            DateTime localDate = DateTime.Now;

            cregistroBITACORA.Init();

            cregistroBITACORA.Fecha     = localDate.ToString("yyyyMMdd");
            cregistroBITACORA.Hora      = localDate.ToString("HHmmss");
            cregistroBITACORA.IdMensaje = prIdMensaje;
            cregistroBITACORA.Criterio  = prCriterio;
            cregistroBITACORA.Estado    = "ERROR";

            Console.WriteLine();

            if (cMENSAJE.ConsultarMensajeActivo(prIdMensaje, prCriterio) != 0)
            {
                Console.WriteLine("Mensaje NO Encontrado Mensaje: {0} ,Criterio: {1}", prIdMensaje, prCriterio);
                cregistroBITACORA.DescError = "Mensaje NO Encontrado ";
                cBITACORA.Guardar(cregistroBITACORA);
                return 1;
            }
                        
            foreach (registroMENSAJE MENSAJE in cMENSAJE.ListaMensajes)
            {
                Console.WriteLine("Mensaje Encontrado: {0} - {1} , Criterio {2} ,Con listado: {3}", MENSAJE.IdMensaje, MENSAJE.Subject, prCriterio, MENSAJE.IdLista);
                Console.WriteLine("Mensaje a enviar: {0}", MENSAJE.Mensaje);

                cregistroBITACORA.IdLista = MENSAJE.IdLista;
                cregistroBITACORA.Mensaje = MENSAJE.Mensaje;
                cregistroBITACORA.Subject = MENSAJE.Subject;

                if (cLISTACONTACTO.ConsultaUnaLista(MENSAJE.IdLista) != 0) {
                    
                    Console.WriteLine("Lista de contacctos NO encontrada o inactiva: {0} ", MENSAJE.IdLista);
                    cregistroBITACORA.DescError = "Lista de contacctos NO encontrada o inactiva";
                    cBITACORA.Guardar(cregistroBITACORA);
                    return 1;
                }

                foreach (registroLISTACONTACTO LISTACONTACTO in cLISTACONTACTO.ListaListaContactos)                
                {
                    if (string.IsNullOrEmpty(ListaAnt) || ListaAnt != LISTACONTACTO.IdLista)
                    {
                        ListaAnt = LISTACONTACTO.IdLista;
                        Console.WriteLine();
                        Console.WriteLine("Lista de Contacto encontrada: {0} - {1}", LISTACONTACTO.IdLista, LISTACONTACTO.Descripcion);
                    }
                    cregistroBITACORA.IdContacto = LISTACONTACTO.IdContacto;                    

                    if (cCONTACTO.ConsultarContactoActivo(LISTACONTACTO.IdContacto) != 0)
                    {
                        Console.WriteLine("Contacto no encontrado o inactivo: {0}", LISTACONTACTO.IdContacto);
                        cregistroBITACORA.DescError = "Contacto no encontrado o inactivo";
                        cBITACORA.Guardar(cregistroBITACORA);
                    }
                    else
                    {

                        foreach (registroContacto Contacto in cCONTACTO.ListaContactos)
                        {
                            cregistroBITACORA.Telefono = Contacto.Telefono;
                            
                            Console.WriteLine("Contacto: {0}, Teléfono: {1}", Contacto.IdContacto, Contacto.Telefono);

                            if (DetMensaje == null)
                                cEnviarMensaje.Mensaje = MENSAJE.Mensaje;
                            else{
                                cEnviarMensaje.Mensaje = DetMensaje;
                                cregistroBITACORA.Mensaje = DetMensaje;
                                Console.WriteLine("Detalle Mensaje: {0}", DetMensaje);
                            }

                            cEnviarMensaje.TelefonoDestino = Contacto.Telefono;
                            if (cEnviarMensaje.Main() != 0)
                            {
                                cregistroBITACORA.DescError = cEnviarMensaje.Error;
                            }
                            else {
                                cregistroBITACORA.Estado = "ENVIADO";
                                cregistroBITACORA.DescError = "";
                            }

                            cBITACORA.Guardar(cregistroBITACORA);
                            cregistroBITACORA.Estado = "ERROR";//<< iniciando el estado
                            cregistroBITACORA.Telefono = "";
                        }
                    }

                    
                }
            }
            return 0;
        }
    }
}
