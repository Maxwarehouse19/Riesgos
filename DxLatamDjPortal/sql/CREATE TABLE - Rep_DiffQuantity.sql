-- select * from Rep_DiffQuantity
USE [MaxWarehouse]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Rep_DiffQuantity]') AND type in (N'U'))
DROP TABLE [dbo].[Rep_DiffQuantity]
GO

create table Rep_DiffQuantity (
	[IdRegistro] [bigint]   IDENTITY(1,1) NOT NULL,
	[FechaIngreso]          date not null,
	[Sku]                   varchar(100) null,
	[SKU Status]            varchar(100) null,
	[Listing]               varchar(100) null,
	[Listing Status]        varchar(100) null,
	[AmazonUomQuantity]     float null,
	[PublicationMode]       varchar(200) null,
	[Review State]          varchar(200) null,
	[AvailabilityMode]      varchar(200) null,
	[Number Of Items]       float null,
	[Item Package Quantity] varchar(200) null,
	[ASIN]                  varchar(200) null,
)

