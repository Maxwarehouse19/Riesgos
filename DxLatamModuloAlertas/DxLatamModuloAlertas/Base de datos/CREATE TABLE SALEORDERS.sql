--SELECT COUNT(*) FROM SALEORDERS

-- DROP TABLE SALEORDERS
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


/****** Object:  Table [dbo].[RESUMEN_VENTAS]    Script Date: 2/02/2021 11:59:18 ******/
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETALLE_VENTAS]') AND type in (N'U'))
	DROP TABLE [dbo].[DETALLE_VENTAS]
	
	CREATE TABLE [dbo].[DETALLE_VENTAS](
		[Fecha] [bigint] NULL,
		[Hora] [bigint] NULL,	
		[CanalVenta] [varchar](15) NULL,
		[TiposOrdenVenta] [varchar](28) NULL,
		[CanalyTiposOrden] [varchar](50) NULL,
		[Estado] [varchar](9) NULL,	
		[Moneda] [varchar](6) NULL,
		[Monto] [decimal](18,2)  NULL,
		[Año] [int] NULL,
		[Mes] [varchar](20) NULL,
		[Dia] [int] NULL,
		[SKU] [varchar](1500) NULL
	) ON [PRIMARY]

--- tabla de rangos de 15 minutos


-- drop table RANGOS_Hora
SELECT *
INTO RANGOS_Hora
FROM (

SELECT 1 Hora, 0 Minuto ,100 HoraInicial, 114 HoraFinal UNION
SELECT 1 Hora, 15 Minuto ,115 HoraInicial, 129 HoraFinal UNION
SELECT 1 Hora, 30 Minuto ,130 HoraInicial, 144 HoraFinal UNION
SELECT 1 Hora, 45 Minuto ,145 HoraInicial, 199 HoraFinal UNION
SELECT 2 Hora, 0 Minuto ,200 HoraInicial, 214 HoraFinal UNION
SELECT 2 Hora, 15 Minuto ,215 HoraInicial, 229 HoraFinal UNION
SELECT 2 Hora, 30 Minuto ,230 HoraInicial, 244 HoraFinal UNION
SELECT 2 Hora, 45 Minuto ,245 HoraInicial, 299 HoraFinal UNION
SELECT 3 Hora, 0 Minuto ,300 HoraInicial, 314 HoraFinal UNION
SELECT 3 Hora, 15 Minuto ,315 HoraInicial, 329 HoraFinal UNION
SELECT 3 Hora, 30 Minuto ,330 HoraInicial, 344 HoraFinal UNION
SELECT 3 Hora, 45 Minuto ,345 HoraInicial, 399 HoraFinal UNION
SELECT 4 Hora, 0 Minuto ,400 HoraInicial, 414 HoraFinal UNION
SELECT 4 Hora, 15 Minuto ,415 HoraInicial, 429 HoraFinal UNION
SELECT 4 Hora, 30 Minuto ,430 HoraInicial, 444 HoraFinal UNION
SELECT 4 Hora, 45 Minuto ,445 HoraInicial, 499 HoraFinal UNION
SELECT 5 Hora, 0 Minuto ,500 HoraInicial, 514 HoraFinal UNION
SELECT 5 Hora, 15 Minuto ,515 HoraInicial, 529 HoraFinal UNION
SELECT 5 Hora, 30 Minuto ,530 HoraInicial, 544 HoraFinal UNION
SELECT 5 Hora, 45 Minuto ,545 HoraInicial, 599 HoraFinal UNION
SELECT 6 Hora, 0 Minuto ,600 HoraInicial, 614 HoraFinal UNION
SELECT 6 Hora, 15 Minuto ,615 HoraInicial, 629 HoraFinal UNION
SELECT 6 Hora, 30 Minuto ,630 HoraInicial, 644 HoraFinal UNION
SELECT 6 Hora, 45 Minuto ,645 HoraInicial, 699 HoraFinal UNION
SELECT 7 Hora, 0 Minuto ,700 HoraInicial, 714 HoraFinal UNION
SELECT 7 Hora, 15 Minuto ,715 HoraInicial, 729 HoraFinal UNION
SELECT 7 Hora, 30 Minuto ,730 HoraInicial, 744 HoraFinal UNION
SELECT 7 Hora, 45 Minuto ,745 HoraInicial, 799 HoraFinal UNION
SELECT 8 Hora, 0 Minuto ,800 HoraInicial, 814 HoraFinal UNION
SELECT 8 Hora, 15 Minuto ,815 HoraInicial, 829 HoraFinal UNION
SELECT 8 Hora, 30 Minuto ,830 HoraInicial, 844 HoraFinal UNION
SELECT 8 Hora, 45 Minuto ,845 HoraInicial, 899 HoraFinal UNION
SELECT 9 Hora, 0 Minuto ,900 HoraInicial, 914 HoraFinal UNION
SELECT 9 Hora, 15 Minuto ,915 HoraInicial, 929 HoraFinal UNION
SELECT 9 Hora, 30 Minuto ,930 HoraInicial, 944 HoraFinal UNION
SELECT 9 Hora, 45 Minuto ,945 HoraInicial, 999 HoraFinal UNION
SELECT 10 Hora, 0 Minuto ,1000 HoraInicial, 1014 HoraFinal UNION
SELECT 10 Hora, 15 Minuto ,1015 HoraInicial, 1029 HoraFinal UNION
SELECT 10 Hora, 30 Minuto ,1030 HoraInicial, 1044 HoraFinal UNION
SELECT 10 Hora, 45 Minuto ,1045 HoraInicial, 1099 HoraFinal UNION
SELECT 11 Hora, 0 Minuto ,1100 HoraInicial, 1114 HoraFinal UNION
SELECT 11 Hora, 15 Minuto ,1115 HoraInicial, 1129 HoraFinal UNION
SELECT 11 Hora, 30 Minuto ,1130 HoraInicial, 1144 HoraFinal UNION
SELECT 11 Hora, 45 Minuto ,1145 HoraInicial, 1199 HoraFinal UNION
SELECT 12 Hora, 0 Minuto ,1200 HoraInicial, 1214 HoraFinal UNION
SELECT 12 Hora, 15 Minuto ,1215 HoraInicial, 1229 HoraFinal UNION
SELECT 12 Hora, 30 Minuto ,1230 HoraInicial, 1244 HoraFinal UNION
SELECT 12 Hora, 45 Minuto ,1245 HoraInicial, 1299 HoraFinal UNION
SELECT 13 Hora, 0 Minuto ,1300 HoraInicial, 1314 HoraFinal UNION
SELECT 13 Hora, 15 Minuto ,1315 HoraInicial, 1329 HoraFinal UNION
SELECT 13 Hora, 30 Minuto ,1330 HoraInicial, 1344 HoraFinal UNION
SELECT 13 Hora, 45 Minuto ,1345 HoraInicial, 1399 HoraFinal UNION
SELECT 14 Hora, 0 Minuto ,1400 HoraInicial, 1414 HoraFinal UNION
SELECT 14 Hora, 15 Minuto ,1415 HoraInicial, 1429 HoraFinal UNION
SELECT 14 Hora, 30 Minuto ,1430 HoraInicial, 1444 HoraFinal UNION
SELECT 14 Hora, 45 Minuto ,1445 HoraInicial, 1499 HoraFinal UNION
SELECT 15 Hora, 0 Minuto ,1500 HoraInicial, 1514 HoraFinal UNION
SELECT 15 Hora, 15 Minuto ,1515 HoraInicial, 1529 HoraFinal UNION
SELECT 15 Hora, 30 Minuto ,1530 HoraInicial, 1544 HoraFinal UNION
SELECT 15 Hora, 45 Minuto ,1545 HoraInicial, 1599 HoraFinal UNION
SELECT 16 Hora, 0 Minuto ,1600 HoraInicial, 1614 HoraFinal UNION
SELECT 16 Hora, 15 Minuto ,1615 HoraInicial, 1629 HoraFinal UNION
SELECT 16 Hora, 30 Minuto ,1630 HoraInicial, 1644 HoraFinal UNION
SELECT 16 Hora, 45 Minuto ,1645 HoraInicial, 1699 HoraFinal UNION
SELECT 17 Hora, 0 Minuto ,1700 HoraInicial, 1714 HoraFinal UNION
SELECT 17 Hora, 15 Minuto ,1715 HoraInicial, 1729 HoraFinal UNION
SELECT 17 Hora, 30 Minuto ,1730 HoraInicial, 1744 HoraFinal UNION
SELECT 17 Hora, 45 Minuto ,1745 HoraInicial, 1799 HoraFinal UNION
SELECT 18 Hora, 0 Minuto ,1800 HoraInicial, 1814 HoraFinal UNION
SELECT 18 Hora, 15 Minuto ,1815 HoraInicial, 1829 HoraFinal UNION
SELECT 18 Hora, 30 Minuto ,1830 HoraInicial, 1844 HoraFinal UNION
SELECT 18 Hora, 45 Minuto ,1845 HoraInicial, 1899 HoraFinal UNION
SELECT 19 Hora, 0 Minuto ,1900 HoraInicial, 1914 HoraFinal UNION
SELECT 19 Hora, 15 Minuto ,1915 HoraInicial, 1929 HoraFinal UNION
SELECT 19 Hora, 30 Minuto ,1930 HoraInicial, 1944 HoraFinal UNION
SELECT 19 Hora, 45 Minuto ,1945 HoraInicial, 1999 HoraFinal UNION
SELECT 20 Hora, 0 Minuto ,2000 HoraInicial, 2014 HoraFinal UNION
SELECT 20 Hora, 15 Minuto ,2015 HoraInicial, 2029 HoraFinal UNION
SELECT 20 Hora, 30 Minuto ,2030 HoraInicial, 2044 HoraFinal UNION
SELECT 20 Hora, 45 Minuto ,2045 HoraInicial, 2099 HoraFinal UNION
SELECT 21 Hora, 0 Minuto ,2100 HoraInicial, 2114 HoraFinal UNION
SELECT 21 Hora, 15 Minuto ,2115 HoraInicial, 2129 HoraFinal UNION
SELECT 21 Hora, 30 Minuto ,2130 HoraInicial, 2144 HoraFinal UNION
SELECT 21 Hora, 45 Minuto ,2145 HoraInicial, 2199 HoraFinal UNION
SELECT 22 Hora, 0 Minuto ,2200 HoraInicial, 2214 HoraFinal UNION
SELECT 22 Hora, 15 Minuto ,2215 HoraInicial, 2229 HoraFinal UNION
SELECT 22 Hora, 30 Minuto ,2230 HoraInicial, 2244 HoraFinal UNION
SELECT 22 Hora, 45 Minuto ,2245 HoraInicial, 2299 HoraFinal UNION
SELECT 23 Hora, 0 Minuto ,2300 HoraInicial, 2314 HoraFinal UNION
SELECT 23 Hora, 15 Minuto ,2315 HoraInicial, 2329 HoraFinal UNION
SELECT 23 Hora, 30 Minuto ,2330 HoraInicial, 2344 HoraFinal UNION
SELECT 23 Hora, 45 Minuto ,2345 HoraInicial, 2399 HoraFinal UNION
SELECT  0 Hora, 0 Minuto  ,0000 HoraInicial, 0014 HoraFinal UNION
SELECT  0 Hora, 15 Minuto ,0015 HoraInicial, 0029 HoraFinal UNION
SELECT  0 Hora, 30 Minuto ,0030 HoraInicial, 0044 HoraFinal UNION
SELECT  0 Hora, 45 Minuto ,0045 HoraInicial, 0059 HoraFinal 
)X