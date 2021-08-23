using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace DxLatamModuloAlertas
{
    class registroALECHKPOINT {
		public string IdRegistro     = string.Empty;
		public string IdChkPoint     = string.Empty;
		public string FechaVigencia  = string.Empty;
		public string HoraInicial    = string.Empty;
		public string Descripicion   = string.Empty;
		public string sp_Validacion  = string.Empty;
		public string IdMensaje      = string.Empty;
		public string MensajeInf     = string.Empty;
		public string MensajSup      = string.Empty;
		public string UniRevision    = string.Empty;
		public string Periodicidad   = string.Empty;
		public string Estado         = string.Empty;
		public string HoraFinal      = string.Empty;
		public string EstadoLogico   = string.Empty;     
    }
    class ALECHKPOINT : EntidadSQL {

        public List<registroALECHKPOINT> ListaALECHKPOINTs = new List<registroALECHKPOINT>();

        public override int TrabajarResultados(SqlDataReader reader) {

            ListaALECHKPOINTs.Clear();

            while (reader.Read())
            {
                ListaALECHKPOINTs.Add(new registroALECHKPOINT
                {
                    IdRegistro     =  reader["IdRegistro"].ToString(),
					IdChkPoint     =  reader["IdChkPoint"].ToString(),
					FechaVigencia  =  reader["FechaVigencia"].ToString(),
					HoraInicial    =  reader["HoraInicial"].ToString(),
					Descripicion   =  reader["Descripicion"].ToString(),
					sp_Validacion  =  reader["sp_Validacion"].ToString(),
					IdMensaje      =  reader["IdMensaje"].ToString(),
					MensajeInf     =  reader["MensajeInf"].ToString(),
					MensajSup      =  reader["MensajSup"].ToString(),
					UniRevision    =  reader["UniRevision"].ToString(),
					Periodicidad   =  reader["Periodicidad"].ToString(),
					Estado         =  reader["Estado"].ToString(),
					HoraFinal      =  reader["HoraFinal"].ToString(),
					EstadoLogico   =  reader["EstadoLogico"].ToString()
                });
            }

            return 0;
        }

        public int ConsultarActivos() {
            strQuery = "SELECT * FROM ALECHKPOINT WITH(NOLOCK) WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' ";
            if (EjecutarConsulta() != 0)
                return 1;
            return 0;
        }

		public int ConsultarActivosVigentes()
		{

			DateTime localDate = DateTime.Now;

			strQuery = " SELECT * FROM ALECHKPOINT A WITH(NOLOCK) INNER JOIN(SELECT IdChkPoint, Max(FechaVigencia) FechaVigencia FROM ALECHKPOINT WITH(NOLOCK) "
			+ " WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' "
			+ " AND FechaVigencia <=" + localDate.ToString("yyyyMMdd")
			+ " AND " + localDate.ToString("HHmm") 
			+ " BETWEEN HoraInicial AND HoraFinal	group by IdChkPoint	)X ON A.IdChkPoint = X.IdChkPoint AND A.FechaVigencia = X.FechaVigencia	WHERE EstadoLogico = 0 AND Estado = 'ACTIVO' "
			+ " AND " + localDate.ToString("HHmm") +" BETWEEN HoraInicial AND HoraFinal ";

			if (EjecutarConsulta() != 0)
				return 1;
			return 0;
		}
	}
}
