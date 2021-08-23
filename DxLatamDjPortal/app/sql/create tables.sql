CREATE TABLE [dbo].[hdBatch](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[codigo] [varchar](20) NULL,
	[descripcion] [varchar](60) NULL,
	[usuario] [varchar](20) NULL,
	[fechahora] [datetime] NULL,
	[tipo] [tinyint] NULL,
	[status] [tinyint] NULL
) 

--************************

CREATE TABLE [dbo].[dtBatch](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[batchId] [int] NULL,
	[salesListing] [varchar](64) NULL,
	[asin] [varchar](64) NULL,
	[upc] [float] NULL,
	[sku] [varchar](64) NULL,
	[status] [tinyint] NULL,
	[answers] [varchar](64) NULL,
	[matchStatus] [tinyint] NULL,
	[operador] [varchar](20) NULL,
	[porcentajeSimilitud] [int] NULL
) 


--*************************

CREATE TABLE [dbo].[questions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Textual] [varchar](512) NULL,
	[RespPosibles] [varchar](5) NULL
)


--************************************

CREATE TABLE [dbo].[infoArtAMZ](
	[upcOriginal] [nvarchar](255) NULL,
	[asinOriginal] [nvarchar](255) NULL,
	[title] [nvarchar](255) NULL,
	[price] [nvarchar](255) NULL,
	[brand] [nvarchar](255) NULL,
	[asin] [nvarchar](255) NULL,
	[partNumber] [nvarchar](255) NULL,
	[color] [nvarchar](255) NULL,
	[itemWeight] [nvarchar](255) NULL,
	[manufacturer] [nvarchar](255) NULL,
	[productDimensions] [nvarchar](255) NULL,
	[numberOfItems] [nvarchar](255) NULL,
	[itemPackageQuantity] [nvarchar](255) NULL,
	[material] [nvarchar](255) NULL,
	[itemModelNumber] [nvarchar](255) NULL,
	[linkImagen] [nvarchar](255) NULL
)


--*****************************************

CREATE TABLE [dbo].[AmazonListingInventory](
	[sku] [nvarchar](255) NULL,
	[SKU Status] [nvarchar](255) NULL,
	[UPC] [float] NULL,
	[PrimaryorSecondary] [nvarchar](255) NULL,
	[Sales Listing] [nvarchar](255) NULL,
	[Title] [nvarchar](255) NULL,
	[Brand] [nvarchar](255) NULL,
	[Manufacturer] [nvarchar](255) NULL,
	[FBA] [nvarchar](255) NULL,
	[Asin] [nvarchar](255) NULL,
	[Channel] [nvarchar](255) NULL,
	[Item Package Quantity] [float] NULL,
	[UOMCode] [nvarchar](255) NULL,
	[UOMQuantity] [float] NULL,
	[SalesListingStatus] [nvarchar](255) NULL,
	[SalesListingReviewStatus] [nvarchar](255) NULL,
	[SalesListingAvailabilityMode] [nvarchar](255) NULL,
	[LastPublishQuantity] [float] NULL,
	[SalesListingPublicationMode] [nvarchar](255) NULL,
	[ListingNote] [nvarchar](255) NULL
)


--*************************************

CREATE TABLE [dbo].[CatalogEVP042121$](
	[Master Sku] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[InactiveReason (Custom Field)] [nvarchar](255) NULL,
	[Title] [nvarchar](255) NULL,
	[Manufacturer] [nvarchar](255) NULL,
	[Part #] [float] NULL,
	[UPC] [float] NULL,
	[ORM-D] [nvarchar](255) NULL,
	[Notes] [nvarchar](255) NULL,
	[Item Type] [nvarchar](255) NULL,
	[Variation] [nvarchar](255) NULL,
	[ParentSku] [nvarchar](255) NULL,
	[Created Date] [nvarchar](255) NULL,
	[# Sales Listings] [float] NULL,
	[Channels] [nvarchar](255) NULL,
	[Reasons] [nvarchar](255) NULL,
	[Mode] [nvarchar](255) NULL,
	[Last Check] [nvarchar](255) NULL,
	[Latest Reorder] [nvarchar](255) NULL,
	[Qty] [float] NULL,
	[Type] [nvarchar](255) NULL,
	[Stock Out] [nvarchar](255) NULL,
	[Supplier] [float] NULL,
	[In Stock] [float] NULL
) 


--******************************************

CREATE TABLE [dbo].[tmpEVPPARENTSKU](
	[EvpSku] [varchar](255) NULL,
	[EvpStatus] [varchar](255) NULL,
	[Type] [varchar](255) NULL,
	[Title] [varchar](255) NULL,
	[Manufacturer] [varchar](255) NULL,
	[MFRPARTNO] [float] NULL,
	[UPC] [float] NULL,
	[ACESku] [float] NULL,
	[ACEUOMCode] [varchar](255) NULL,
	[ACEUOMQuantity] [float] NULL,
	[EJDSku] [float] NULL,
	[EJDUOMCode] [varchar](255) NULL,
	[EJDUOMQuantity] [float] NULL,
	[JensenSku] [varchar](255) NULL,
	[JensenUOMCode] [varchar](255) NULL,
	[JensenUOMQuantity] [float] NULL,
	[JensenFBASku] [varchar](255) NULL,
	[JensenFBA_UOMCode] [varchar](255) NULL,
	[JensenFBA_UOMQuantity] [float] NULL,
	[DaleHardwareSku] [varchar](255) NULL,
	[DaleHardware_UOMCode] [varchar](255) NULL,
	[Dale_UOMQuantity] [varchar](255) NULL,
	[CostellosSku] [varchar](255) NULL,
	[Costellos_UOMCode] [varchar](255) NULL,
	[Costellos_UOMQuantity] [varchar](255) NULL,
	[MagefesaSku] [varchar](255) NULL,
	[Magefesa_UOMCode] [varchar](255) NULL,
	[Magefesa_UOMQuantity] [varchar](255) NULL,
	[EMSCOSku] [varchar](255) NULL,
	[EMSCO_UOMCode] [varchar](255) NULL,
	[EMSCO_UOMQuantity] [varchar](255) NULL,
	[EmpireFaucetsSku] [varchar](255) NULL,
	[EmpireFaucets_UOMCode] [varchar](255) NULL,
	[EmpireFaucets_UOMQuantity] [varchar](255) NULL,
	[BigRockSportsSku] [varchar](255) NULL,
	[BigRockSports_UOMCode] [varchar](255) NULL,
	[BigRockSports_UOMQuantity] [varchar](255) NULL,
	[Rugs2GoSku] [varchar](255) NULL,
	[Rugs2Go_UOMCode] [varchar](255) NULL,
	[Rugs2Go_UOMQuantity] [varchar](255) NULL,
	[TramontinaSku] [varchar](255) NULL,
	[Tramontina_UOMCode] [varchar](255) NULL,
	[Tramontina_UOMQuantity] [varchar](255) NULL,
	[DuospotSku] [varchar](255) NULL,
	[Duospot_UOMCode] [varchar](255) NULL,
	[Duospot_UOMQuantity] [varchar](255) NULL,
	[CentralPetSku] [varchar](255) NULL,
	[CentralPet_UOMCode] [varchar](255) NULL,
	[CentralPet_UOMQuantity] [varchar](255) NULL,
	[ProductWorksSku] [varchar](255) NULL,
	[ProductWorks_UOMCode] [varchar](255) NULL,
	[ProductWorks_UOMQuantity] [varchar](255) NULL,
	[FolexSku] [varchar](255) NULL,
	[Folex_UOMCode] [varchar](255) NULL,
	[Folex_UOMQuantity] [varchar](255) NULL,
	[EtailSku] [varchar](255) NULL
)

--*****************************************

CREATE TABLE [dbo].[tmpEvpSkuInventory](
	[Sku] [varchar](500) NULL,
	[Status] [varchar](255) NULL,
	[InactiveReason_Notes] [varchar](500) NULL,
	[Restrictions] [varchar](255) NULL,
	[Title] [varchar](2500) NULL,
	[Manufacturer] [varchar](500) NULL,
	[UPC] [float] NULL,
	[InventoryShed] [float] NULL,
	[FBAUSStock] [float] NULL,
	[FBATransit] [float] NULL,
	[InventoryPrincenton] [float] NULL,
	[InventorySacramentoCA] [float] NULL,
	[InventorySacramentoCACrossdock_EJD] [float] NULL,
	[InventoryFredericksburgPA] [float] NULL,
	[InventoryColorado] [float] NULL,
	[InventoryGainesvilleGA] [float] NULL,
	[InventoryLoxleyAL] [float] NULL,
	[InventoryPrescottAZ] [float] NULL,
	[InventoryWiltonNY] [float] NULL,
	[InventoryDefaultLocations_JENSEN] [float] NULL,
	[Total Amazon QTY Published] [float] NULL,
	[Total Ebay QTY Published] [float] NULL,
	[TotalWalmartQTYPublished] [float] NULL,
	[Total Shopify QTY Published] [float] NULL,
	[EJD QTY] [float] NULL,
	[ACE QTY] [float] NULL,
	[JEN QTY] [float] NULL,
	[DLE QTY] [float] NULL,
	[EJD SKU] [float] NULL,
	[EJDUOMCODE] [varchar](255) NULL,
	[EJD UOMQTY] [float] NULL,
	[ACE SKU] [float] NULL,
	[ACEUOMCODE] [varchar](255) NULL,
	[ACE UOMQTY] [float] NULL,
	[JENSKU] [varchar](255) NULL,
	[JENUOMCODE] [varchar](255) NULL,
	[JEN UOMQTY] [float] NULL,
	[EJD ADJ UOM QTY] [float] NULL,
	[JEN ADJ UOM QTY] [float] NULL
)

--***********************************************

CREATE TABLE [dbo].[wUniStorages](
	[Row#] [bigint] NULL,
	[Loc] [varchar](3) NOT NULL,
	[#Action_Cd] [nvarchar](255) NULL,
	[RSC] [nvarchar](255) NULL,
	[EJD_Item#] [float] NULL,
	[Item_Description] [nvarchar](255) NULL,
	[Search_Desc] [nvarchar](255) NULL,
	[SearchOverride_Desc] [nvarchar](255) NULL,
	[Item_UPC_Code] [float] NULL,
	[CasePack_UPC] [float] NULL,
	[Manufacturer#] [nvarchar](255) NULL,
	[Vendor#] [float] NULL,
	[Vendor_Name] [nvarchar](255) NULL,
	[Order_Multiple_in_Eachs] [float] NULL,
	[CasePack_Qty] [float] NULL,
	[UnitofMeasure_Qty] [float] NULL,
	[UnitofMeasure_Code] [nvarchar](255) NULL,
	[Retail_Unit_Qty] [float] NULL,
	[Consumer_Unit] [float] NULL,
	[Consumer_Unit_Text] [nvarchar](255) NULL,
	[OM_Length] [float] NULL,
	[OM_Width] [float] NULL,
	[OM_Height] [float] NULL,
	[OM_Weight] [float] NULL,
	[OM_Cube] [float] NULL,
	[Cubic_feet_per_Each] [float] NULL,
	[Consumer_Brand] [nvarchar](255) NULL,
	[Wholesaler_cost_per_Each] [float] NULL,
	[Recommended_Retail_Price] [float] NULL,
	[UPS] [nvarchar](255) NULL,
	[Velocity_Code_Units] [nvarchar](255) NULL,
	[Velocity_Code_Dollars] [nvarchar](255) NULL,
	[Multiple_Retail_Unit] [nvarchar](255) NULL,
	[Not_for_Resale_Flag] [nvarchar](255) NULL,
	[Nonstock_Flag] [nvarchar](255) NULL,
	[Item_Status] [nvarchar](255) NULL,
	[Hazardous_Flag] [nvarchar](255) NULL,
	[OldMaterialNumber] [float] NULL,
	[NewMaterialNum] [float] NULL,
	[department] [float] NULL,
	[departmentDesc] [nvarchar](255) NULL,
	[buyerCd] [nvarchar](255) NULL,
	[mdseClassCd] [float] NULL,
	[mdseClassDesc] [nvarchar](255) NULL,
	[prodGroup] [float] NULL,
	[prodGroupDesc] [nvarchar](255) NULL,
	[Nonreturnable_Flag] [nvarchar](255) NULL,
	[defectPolicyCd] [nvarchar](255) NULL,
	[dcAllocMax] [nvarchar](255) NULL,
	[dcAllocEnd] [datetime] NULL,
	[custAllocMax] [nvarchar](255) NULL,
	[custAllocEnd] [datetime] NULL,
	[Bulleted_Description] [nvarchar](max) NULL,
	[CountryOrigin] [nvarchar](255) NULL,
	[FuturePrice_Amt] [nvarchar](255) NULL,
	[FuturePrice_ValidFrom_Dt] [nvarchar](255) NULL
)