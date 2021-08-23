USE [MaxWarehouse]
GO
/****** Object:  Table [dbo].[ALBIDETCHKPOINT]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALBIDETCHKPOINT](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[Fecha] [int] NOT NULL,
	[IdChkPoint] [varchar](10) NOT NULL,
	[Hora] [int] NOT NULL,
	[CanalyTiposOrden] [varchar](30) NOT NULL,
	[Accion] [varchar](10) NOT NULL,
	[FechaModelo] [int] NOT NULL,
	[HoraModelo] [int] NOT NULL,
	[Prediccion] [decimal](7, 2) NOT NULL,
	[ValorReal] [decimal](7, 2) NOT NULL,
	[Diferencia] [decimal](7, 2) NOT NULL,
	[Variacion] [decimal](7, 2) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALBITCHKPOINT]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALBITCHKPOINT](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[Fecha] [int] NOT NULL,
	[IdChkPoint] [varchar](10) NOT NULL,
	[CanalyTiposOrden] [varchar](30) NOT NULL,
	[Hora] [int] NOT NULL,
	[HoraDesde] [int] NOT NULL,
	[HoraHasta] [int] NOT NULL,
	[FechaInicial] [int] NOT NULL,
	[HoraInicial] [int] NOT NULL,
	[FechaFinal] [int] NOT NULL,
	[HoraFinal] [int] NOT NULL,
	[ValDifMinimo] [decimal](7, 2) NOT NULL,
	[ToleranciaInf] [decimal](7, 2) NOT NULL,
	[ToleranciaSup] [decimal](7, 2) NOT NULL,
	[Accion] [varchar](10) NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALEBITACORA]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALEBITACORA](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[Fecha] [int] NOT NULL,
	[Hora] [int] NOT NULL,
	[IdMensaje] [varchar](10) NOT NULL,
	[Criterio] [varchar](10) NOT NULL,
	[IdLista] [varchar](10) NOT NULL,
	[IdContacto] [varchar](40) NOT NULL,
	[Telefono] [varchar](20) NOT NULL,
	[Subject] [varchar](50) NOT NULL,
	[Mensaje] [varchar](160) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[DescError] [varchar](200) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALECHKPOINT]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALECHKPOINT](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[IdChkPoint] [varchar](10) NOT NULL,
	[FechaVigencia] [int] NOT NULL,
	[HoraInicial] [int] NOT NULL,
	[Descripicion] [varchar](30) NOT NULL,
	[sp_Validacion] [varchar](30) NOT NULL,
	[IdMensaje] [varchar](10) NOT NULL,
	[MensajeInf] [varchar](10) NOT NULL,
	[MensajSup] [varchar](10) NOT NULL,
	[UniRevision] [varchar](10) NOT NULL,
	[Periodicidad] [tinyint] NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[HoraFinal] [int] NOT NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALECONFIG]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALECONFIG](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[IdModulo] [varchar](10) NOT NULL,
	[IdParametro] [varchar](10) NOT NULL,
	[Valor] [varchar](100) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALECONTACTOS]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALECONTACTOS](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[IdContacto] [varchar](40) NOT NULL,
	[Telefono] [varchar](20) NOT NULL,
	[NombreCompleto] [varchar](80) NOT NULL,
	[Puesto] [varchar](30) NOT NULL,
	[ModoContacto] [varchar](10) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[EstadoLogico] [bigint] NULL,
	[FechaCreacion] [int] NULL,
	[HoraCreacion] [int] NULL,
	[FechaModificacion] [int] NULL,
	[HoraModifcacion] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALELISTACONTACTO]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALELISTACONTACTO](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[IdLista] [varchar](10) NOT NULL,
	[Descripcion] [varchar](80) NOT NULL,
	[IdContacto] [varchar](40) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL,
	[FechaCreacion] [int] NOT NULL,
	[HoraCreacion] [int] NOT NULL,
	[FechaModificacion] [int] NOT NULL,
	[HoraModifcacion] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALELISTAMENSAJE]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALELISTAMENSAJE](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[IdMensaje] [varchar](10) NOT NULL,
	[Criterio] [varchar](10) NOT NULL,
	[IdLista] [varchar](10) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL,
	[FechaCreacion] [int] NOT NULL,
	[HoraCreacion] [int] NOT NULL,
	[FechaModificacion] [int] NOT NULL,
	[HoraModifcacion] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALEMENSAJE]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALEMENSAJE](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[IdMensaje] [varchar](10) NOT NULL,
	[Criterio] [varchar](10) NOT NULL,
	[IdLista] [varchar](10) NOT NULL,
	[Subject] [varchar](50) NOT NULL,
	[Mensaje] [varchar](160) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL,
	[FechaCreacion] [int] NOT NULL,
	[HoraCreacion] [int] NOT NULL,
	[FechaModificacion] [int] NOT NULL,
	[HoraModifcacion] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALEORDENVENTA]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALEORDENVENTA](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[Fecha] [bigint] NULL,
	[Hora] [bigint] NULL,
	[CanalVenta] [varchar](15) NULL,
	[TiposOrdenVenta] [varchar](28) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,
	[Moneda] [varchar](6) NULL,
	[Monto] [decimal](18, 2) NULL,
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[Dia] [int] NULL,
	[SKU] [varchar](1500) NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALESOLICITUD]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALESOLICITUD](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[Fecha] [int] NOT NULL,
	[Hora] [int] NOT NULL,
	[IdMensaje] [varchar](10) NOT NULL,
	[Criterio] [varchar](10) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[Detalle] [varchar](100) NOT NULL,
	[DescError] [varchar](200) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ALTCHKPOINT]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALTCHKPOINT](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[IdChkPoint] [varchar](10) NOT NULL,
	[CanalyTiposOrden] [varchar](30) NOT NULL,
	[FechaInicial] [int] NOT NULL,
	[HoraInicial] [int] NOT NULL,
	[FechaFinal] [int] NOT NULL,
	[HoraFinal] [int] NOT NULL,
	[ValorDifMinimo] [decimal](7, 2) NOT NULL,
	[ToleranciaInferior] [decimal](7, 2) NOT NULL,
	[ToleranciaSuperior] [decimal](7, 2) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
	[EstadoLogico] [bigint] NOT NULL,
	[ValorDifMaximo] [decimal](7, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[app_alecontactos]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[app_alecontactos](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Telefono] [nvarchar](20) NOT NULL,
	[NombreCompleto] [nvarchar](80) NOT NULL,
	[Puesto] [nvarchar](30) NOT NULL,
	[ModoContacto] [nvarchar](10) NOT NULL,
	[Estado] [nvarchar](10) NOT NULL,
	[EstadoLogico] [int] NOT NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
	[HoraCreacion] [datetime2](7) NOT NULL,
	[FechaModificacion] [datetime2](7) NOT NULL,
	[HoraModifcacion] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[app_contact]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[app_contact](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[city] [nvarchar](50) NOT NULL,
	[state] [nvarchar](2) NOT NULL,
	[create_date] [datetime2](7) NOT NULL,
	[phone_number] [nvarchar](20) NOT NULL,
	[email] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[app_part]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[app_part](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AUTONUM] [nvarchar](max) NOT NULL,
	[CATEGORY] [nvarchar](max) NOT NULL,
	[NUMBER] [nvarchar](max) NOT NULL,
	[PART_NUM] [nvarchar](max) NOT NULL,
	[PART_DESC] [nvarchar](max) NOT NULL,
	[Slug] [nvarchar](50) NOT NULL,
	[PART_otro] [nvarchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_group]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](150) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [auth_group_name_a6ea08ec_uniq] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_group_permissions]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group_permissions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[group_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_permission]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_permission](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[content_type_id] [int] NOT NULL,
	[codename] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_user]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[password] [nvarchar](128) NOT NULL,
	[last_login] [datetime2](7) NULL,
	[is_superuser] [bit] NOT NULL,
	[username] [nvarchar](150) NOT NULL,
	[first_name] [nvarchar](30) NOT NULL,
	[last_name] [nvarchar](150) NOT NULL,
	[email] [nvarchar](254) NOT NULL,
	[is_staff] [bit] NOT NULL,
	[is_active] [bit] NOT NULL,
	[date_joined] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [auth_user_username_6821ab7c_uniq] UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_user_groups]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user_groups](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[group_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_user_user_permissions]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user_user_permissions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CantidadVentasXDia]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CantidadVentasXDia](
	[category] [varchar](50) NULL,
	[Fecha] [int] NULL,
	[Deteccion] [varchar](10) NULL,
	[Cantidad] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DET_VENTASXRANGO]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DET_VENTASXRANGO](
	[Fecha] [bigint] NULL,
	[Hora] [bigint] NULL,
	[CanalVenta] [varchar](15) NULL,
	[TiposOrdenVenta] [varchar](28) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,
	[Moneda] [varchar](6) NULL,
	[Monto] [decimal](18, 2) NULL,
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[Dia] [int] NULL,
	[SKU] [varchar](1500) NULL,
	[DiaSemanaNum] [int] NULL,
	[DiaHoraNum] [int] NULL,
	[DiaSemana] [varchar](9) NULL,
	[HoraInicial] [int] NOT NULL,
	[HoraFinal] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DETALLE_VENTAS]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DETALLE_VENTAS](
	[Fecha] [bigint] NULL,
	[Hora] [bigint] NULL,
	[CanalVenta] [varchar](15) NULL,
	[TiposOrdenVenta] [varchar](28) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,
	[Moneda] [varchar](6) NULL,
	[Monto] [decimal](18, 2) NULL,
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[Dia] [int] NULL,
	[SKU] [varchar](1500) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DETALLE_VENTAS2]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DETALLE_VENTAS2](
	[Fecha] [bigint] NULL,
	[Hora] [bigint] NULL,
	[CanalVenta] [varchar](15) NULL,
	[TiposOrdenVenta] [varchar](28) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,
	[Moneda] [varchar](6) NULL,
	[Monto] [decimal](18, 2) NULL,
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[Dia] [int] NULL,
	[SKU] [varchar](500) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_admin_log]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_admin_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[action_time] [datetime2](7) NOT NULL,
	[object_id] [nvarchar](max) NULL,
	[object_repr] [nvarchar](200) NOT NULL,
	[action_flag] [smallint] NOT NULL,
	[change_message] [nvarchar](max) NOT NULL,
	[content_type_id] [int] NULL,
	[user_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_content_type]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_content_type](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app_label] [nvarchar](100) NOT NULL,
	[model] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_migrations]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_migrations](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app] [nvarchar](255) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[applied] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_plotly_dash_dashapp]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_plotly_dash_dashapp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[instance_name] [nvarchar](100) NOT NULL,
	[slug] [nvarchar](110) NOT NULL,
	[base_state] [nvarchar](max) NOT NULL,
	[creation] [datetime2](7) NOT NULL,
	[update] [datetime2](7) NOT NULL,
	[save_on_change] [bit] NOT NULL,
	[stateless_app_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[instance_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_plotly_dash_statelessapp]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_plotly_dash_statelessapp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app_name] [nvarchar](100) NOT NULL,
	[slug] [nvarchar](110) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[app_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_session]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_session](
	[session_key] [nvarchar](40) NOT NULL,
	[session_data] [nvarchar](max) NOT NULL,
	[expire_date] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[session_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[home_category]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[home_category](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[parent_id] [int] NULL,
	[code] [nvarchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[home_part]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[home_part](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AUTONUM] [nvarchar](max) NOT NULL,
	[CATEGORY] [nvarchar](max) NOT NULL,
	[NUMBER] [nvarchar](max) NOT NULL,
	[PART_NUM] [nvarchar](max) NOT NULL,
	[PART_DESC] [nvarchar](max) NOT NULL,
	[PART_otro] [nvarchar](max) NOT NULL,
	[Slug] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ORDENVENTA_REAL]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ORDENVENTA_REAL](
	[Fecha] [bigint] NULL,
	[SoloHora] [bigint] NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Cantidad] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PREDICCION]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PREDICCION](
	[IdRegistro] [bigint] IDENTITY(1,1) NOT NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[date] [int] NOT NULL,
	[hour] [tinyint] NOT NULL,
	[last_training] [varchar](20) NOT NULL,
	[prediction] [decimal](11, 2) NOT NULL,
	[FechaCreacion] [bigint] NULL,
	[EstadoLogico] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RANGOS_Hora]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RANGOS_Hora](
	[Hora] [int] NOT NULL,
	[Minuto] [int] NOT NULL,
	[HoraInicial] [int] NOT NULL,
	[HoraFinal] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReporteInconsistenciasCarrier]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReporteInconsistenciasCarrier](
	[ID] [int] NOT NULL,
	[SalesOrderNumber] [nvarchar](255) NULL,
	[RequestedServiceLevel] [nvarchar](255) NULL,
	[PROSHIP_SERVICE_PLAINTEXT] [varchar](255) NULL,
	[BilledWeight] [varchar](255) NULL,
	[CambioServicio] [varchar](15) NOT NULL,
	[FechaInsercion] [datetime] NULL,
	[EsNuevo] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RES_VARIANZA]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RES_VARIANZA](
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,
	[HoraInicial] [int] NOT NULL,
	[Cantidad] [int] NULL,
	[Var_Cantidad] [float] NOT NULL,
	[cantidad_DesEst] [float] NOT NULL,
	[Monto_SUM] [int] NOT NULL,
	[Monto_Varianza] [int] NOT NULL,
	[Monto_AVG] [int] NOT NULL,
	[Monto_DesEst] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RES_VENTASXRANGO]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RES_VENTASXRANGO](
	[Fecha] [bigint] NULL,
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,
	[HoraInicial] [int] NOT NULL,
	[Monto_SUM] [decimal](38, 2) NULL,
	[Monto_AVG] [decimal](38, 6) NULL,
	[Cantidad] [int] NULL,
	[Monto_Varianza] [float] NOT NULL,
	[Monto_DesEst] [float] NOT NULL,
	[DiaSemanaNum] [int] NULL,
	[DiaHoraNum] [int] NULL,
	[DiaSemana] [varchar](9) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RESUMEN_VENTAS]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RESUMEN_VENTAS](
	[Fecha] [bigint] NULL,
	[Hora_Menor] [bigint] NULL,
	[Hora_Mayor] [bigint] NULL,
	[CanalVenta] [varchar](15) NULL,
	[TiposOrdenVenta] [varchar](28) NULL,
	[CanalyTiposOrden] [varchar](50) NULL,
	[Estado] [varchar](9) NULL,
	[Cantidad] [int] NULL,
	[Moneda] [varchar](6) NULL,
	[Monto] [decimal](18, 2) NULL,
	[Año] [int] NULL,
	[Mes] [varchar](20) NULL,
	[Dia] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SALEORDERS]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SALEORDERS](
	[Order Date] [varchar](19) NULL,
	[Order Number] [varchar](19) NULL,
	[Earliest Ship Date] [varchar](19) NULL,
	[Latest Ship Date] [varchar](19) NULL,
	[Estimated Delivery Date] [varchar](19) NULL,
	[HaveShippingLabels] [varchar](max) NULL,
	[Status] [varchar](9) NULL,
	[ERP Number] [varchar](14) NULL,
	[Sales Channel] [varchar](15) NULL,
	[ORM-D] [bit] NULL,
	[City] [varchar](27) NULL,
	[State] [varchar](14) NULL,
	[Country] [varchar](14) NULL,
	[Postal Code] [varchar](12) NULL,
	[TotalWeight] [real] NULL,
	[Sales Order Type] [varchar](28) NULL,
	[Adjustment] [varchar](10) NULL,
	[Net] [real] NULL,
	[Discount] [varchar](9) NULL,
	[Total] [varchar](10) NULL,
	[Currency] [varchar](50) NULL,
	[Sales Channel Items] [varchar](1500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SALEORDERS2]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SALEORDERS2](
	[Order Date] [varchar](18) NULL,
	[Order Number] [varchar](19) NULL,
	[Earliest Ship Date] [varchar](18) NULL,
	[Latest Ship Date] [varchar](18) NULL,
	[Estimated Delivery Date] [varchar](18) NULL,
	[HaveShippingLabels] [varchar](max) NULL,
	[Status] [varchar](9) NULL,
	[ERP Number] [varchar](14) NULL,
	[Sales Channel] [varchar](15) NULL,
	[ORM-D] [bit] NULL,
	[City] [varchar](25) NULL,
	[State] [varchar](14) NULL,
	[Country] [varchar](14) NULL,
	[Postal Code] [varchar](10) NULL,
	[TotalWeight] [real] NULL,
	[Sales Order Type] [varchar](28) NULL,
	[Adjustment] [smallint] NULL,
	[Net] [real] NULL,
	[Discount] [varchar](9) NULL,
	[Total] [varchar](10) NULL,
	[Currency] [varchar](50) NULL,
	[Sales Channel Items] [varchar](1500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TRANSFORMACION1]    Script Date: 5/11/2021 9:31:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TRANSFORMACION1](
	[Order Date] [varchar](19) NULL,
	[mes] [int] NULL,
	[dia] [int] NULL,
	[año] [int] NULL,
	[horaCompleta] [varchar](10) NULL,
	[hora] [int] NULL,
	[minuto] [int] NULL,
	[jornada] [varchar](2) NULL,
	[Status] [varchar](9) NULL,
	[Sales Channel] [varchar](15) NULL,
	[Sales Order Type] [varchar](28) NULL,
	[Net] [decimal](11, 2) NULL,
	[Currency] [varchar](3) NULL,
	[FechaFormato] [bigint] NULL,
	[HoraFormato] [bigint] NULL,
	[Sales Channel Items] [varchar](1500) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ALBIDETCHKPOINT] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALBITCHKPOINT] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALECHKPOINT] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALECONFIG] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALECONTACTOS] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALECONTACTOS] ADD  DEFAULT ((0)) FOR [FechaCreacion]
GO
ALTER TABLE [dbo].[ALECONTACTOS] ADD  DEFAULT ((0)) FOR [HoraCreacion]
GO
ALTER TABLE [dbo].[ALECONTACTOS] ADD  DEFAULT ((0)) FOR [FechaModificacion]
GO
ALTER TABLE [dbo].[ALECONTACTOS] ADD  DEFAULT ((0)) FOR [HoraModifcacion]
GO
ALTER TABLE [dbo].[ALEORDENVENTA] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALESOLICITUD] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALTCHKPOINT] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[ALTCHKPOINT] ADD  DEFAULT ((0)) FOR [ValorDifMaximo]
GO
ALTER TABLE [dbo].[PREDICCION] ADD  DEFAULT (CONVERT([varchar],getdate(),(112))) FOR [FechaCreacion]
GO
ALTER TABLE [dbo].[PREDICCION] ADD  DEFAULT ((0)) FOR [EstadoLogico]
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id]
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[auth_permission]  WITH CHECK ADD  CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[auth_permission] CHECK CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[auth_user_groups]  WITH CHECK ADD  CONSTRAINT [auth_user_groups_group_id_97559544_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[auth_user_groups] CHECK CONSTRAINT [auth_user_groups_group_id_97559544_fk_auth_group_id]
GO
ALTER TABLE [dbo].[auth_user_groups]  WITH CHECK ADD  CONSTRAINT [auth_user_groups_user_id_6a12ed8b_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[auth_user_groups] CHECK CONSTRAINT [auth_user_groups_user_id_6a12ed8b_fk_auth_user_id]
GO
ALTER TABLE [dbo].[auth_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [auth_user_user_permissions_permission_id_1fbb5f2c_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[auth_user_user_permissions] CHECK CONSTRAINT [auth_user_user_permissions_permission_id_1fbb5f2c_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[auth_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[auth_user_user_permissions] CHECK CONSTRAINT [auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[django_plotly_dash_dashapp]  WITH CHECK ADD  CONSTRAINT [django_plotly_dash_dashapp_stateless_app_id_220444de_fk_django_plotly_dash_statelessapp_id] FOREIGN KEY([stateless_app_id])
REFERENCES [dbo].[django_plotly_dash_statelessapp] ([id])
GO
ALTER TABLE [dbo].[django_plotly_dash_dashapp] CHECK CONSTRAINT [django_plotly_dash_dashapp_stateless_app_id_220444de_fk_django_plotly_dash_statelessapp_id]
GO
ALTER TABLE [dbo].[home_category]  WITH CHECK ADD  CONSTRAINT [home_category_parent_id_a0bb35a2_fk_home_category_id] FOREIGN KEY([parent_id])
REFERENCES [dbo].[home_category] ([id])
GO
ALTER TABLE [dbo].[home_category] CHECK CONSTRAINT [home_category_parent_id_a0bb35a2_fk_home_category_id]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_action_flag_a8637d59_check] CHECK  (([action_flag]>=(0)))
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_action_flag_a8637d59_check]
GO
