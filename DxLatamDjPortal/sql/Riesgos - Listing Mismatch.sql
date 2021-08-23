use MaxSuppliers

-- listings de amazon pero el extracto no trae UOMQty, confirmar con J si es posible generar un reporte personalizado que lo incluya
select top 100 * from SCCatalogAmazon with(nolock) where status  = 'Active'

        -->> el campo quantity parece estar más relacionado a la cantidad disponible en el listing

select sum(case when quantity <= 0 then 1 else 0 end) quantityZero,
		sum(1) Total
from SCCatalogAmazon with(nolock) where status  = 'Active'

select status from SCCatalogAmazon with(nolock) group by status
/*
status
Incomplete
Inactive
Active
*/

-- informacion del producto amazon buscado por ASIN, es trabajo en proceso porque el scraping se detiene por captcha
select top 100 * from infoArtAMZ WHERE upcOriginal = '772004947'
--'19200006019' and asin = 'B000TDZH3S'

select  sum(case when len(itemPackageQuantity)=0 then 1 else 0 end) NoTiene
, sum(case when len(itemPackageQuantity)=0 then 0 else 1 end) Tiene 
, sum(1) Total
from infoArtAMZ with(nolock)

/*
itemPackageQuantity
NoTiene	Tiene	Total
13,130	9,624	22,754
*/


select  sum(case when len(productDimensions)=0 then 1 else 0 end) NoTiene
, sum(case when len(productDimensions)=0 then 0 else 1 end) Tiene 
, sum(1) Total
from infoArtAMZ with(nolock)

/*
productDimensions
NoTiene	Tiene	Total
5,105	17,649	22,754
*/

-- estos son los listings de EVP que estan vivos para cargar o cargados a Amazon
select top 10 * from tmpListingInventoryAmazon where SalesListingStatus='Existing' and SalesListingReviewStatus='Verified'
order by UPC, sku

select UPC, Asin, Title, [Item Package Quantity], UOMQuantity
, * from tmpListingInventoryAmazon 
--where SalesListingStatus='Existing' and SalesListingReviewStatus='Verified'
where UPC = '772004947'-- '19200006019'

select upcOriginal, asin, title, productDimensions
,* from infoArtAMZ b 
where upcOriginal = '19200006019'
and ltrim(rtrim(asin)) in (
 'B0014E6NE8'
,'B01IAIBTOY'
,'B00IB18S2C'
,'B000TDZH3S'
,'B007ZT3RSQ'
,'B00007J6D7'
,'B00LFO3DWM'
,'B0014E6NE8'
)
	
select UPC, a.Asin, a.Title, [Item Package Quantity], UOMQuantity,
 upcOriginal, b.asin, b.title, productDimensions
from tmpListingInventoryAmazon a
INNER JOIN  infoArtAMZ b 
	on upcOriginal = a.UPC
	and ltrim(rtrim(b.asin)) = ltrim(rtrim(a.Asin))
--where SalesListingStatus='Existing' and SalesListingReviewStatus='Verified'
where UPC = '19200006019'


select [Item Package Quantity], UOMQuantity,  UOMQuantity - [Item Package Quantity] Diferencia,*
from tmpListingInventoryAmazon where SalesListingStatus='Existing' and SalesListingReviewStatus='Verified'
and [Item Package Quantity] != UOMQuantity
order by UPC, sku


select [SKU Status], SUM (CASE WHEN  UOMQuantity - [Item Package Quantity] > 0 THEN 1 ELSE  0 END)  'Inconsistente',
SUM(1) Total
from tmpListingInventoryAmazon where SalesListingStatus='Existing' and SalesListingReviewStatus='Verified'
group by [SKU Status]
--and [Item Package Quantity] != UOMQuantity
/*
Inconsistente	Total
 41,531	        241,897

 SKU Status	Inconsistente	Total
Active			40,496		234,922
Inactive		 1,026		  6,878
Deleted				 8		     83
Unverified			 1		     14
*/

-- inventario
select * from tmpEvpSkuInventory where sku='ACE-45769'

 SELECT Status  from tmpEvpSkuInventory with(nolock) GROUP BY Status
 /* Status
	Active
	Inactive
	Deleted
	Delete
	Unverified
 */
select [EJD QTY], [ACE QTY], [JEN QTY], [DLE QTY]
,[EJD UOMQTY],[ACE UOMQTY],[JEN UOMQTY]
, [EJD ADJ UOM QTY],[JEN ADJ UOM QTY]
, 
-- select top 10
*  from tmpEvpSkuInventory with(nolock) 
where Status ='Active'
and [EJD UOMQTY] != [ACE UOMQTY] and [EJD UOMQTY] != [JEN UOMQTY]

select sum(case when [EJD QTY] != [ACE QTY] and [EJD QTY] != [JEN QTY] then 1 else 0 end) Inconsistente
       ,sum(1) Total
from tmpEvpSkuInventory with(nolock) 
where Status ='Active'

select sum(case when [EJD ADJ UOM QTY] != [JEN ADJ UOM QTY] then 1 else 0 end) Inconsistente
       ,sum(1) Total
from tmpEvpSkuInventory with(nolock) 
where Status ='Active' and [JEN ADJ UOM QTY] > 0

select sum(case when [EJD UOMQTY] != [ACE UOMQTY] and [EJD UOMQTY] != [JEN UOMQTY] then 1 else 0 end) Inconsistente
       ,sum(1) Total
from tmpEvpSkuInventory with(nolock) 
where Status ='Active'

-- Esta es la correlación de consistencia de la tabla
select sum(case when [EJD QTY] != round([EJD UOMQTY] * [EJD ADJ UOM QTY],0)then 1 else 0 end) Inconsistente
       ,sum(1) Total
from tmpEvpSkuInventory with(nolock) 
where Status ='Active'

SELECT [EJD QTY], [ACE QTY], [JEN QTY], [DLE QTY]
,[EJD UOMQTY],[ACE UOMQTY],[JEN UOMQTY]
, [EJD ADJ UOM QTY],[JEN ADJ UOM QTY]
, [EJD UOMQTY] * [EJD ADJ UOM QTY] [EJD QTY calculado]
, *
from tmpEvpSkuInventory with(nolock) 
where Status ='Active'
AND [EJD QTY] != ([EJD UOMQTY] * [EJD ADJ UOM QTY])



SELECT [EJD UOMQTY],[EJD ADJ UOM QTY],[EJD QTY], Sku
, *
from tmpEvpSkuInventory with(nolock) 
where --Status ='Active'and  
UPC = '19200006019'

select distinct a.UPC, a.Asin, a.Title, [Item Package Quantity],UOMCode,  UOMQuantity, SalesListingStatus,SalesListingReviewStatus
, upcOriginal, b.asin, b.title, productDimensions
, [EJD UOMQTY],[EJD ADJ UOM QTY],[EJD QTY], c.Sku
--,c.*
--, a.*
from tmpListingInventoryAmazon a
INNER JOIN  infoArtAMZ b 
	on upcOriginal = a.UPC
	and ltrim(rtrim(b.asin)) = ltrim(rtrim(a.Asin))
INNER JOIN tmpEvpSkuInventory c with(nolock) 
	ON a.UPC = c.UPC
	and a.UOMQuantity = c.[EJD UOMQTY]
	and c.Status = 'Active'
where SalesListingStatus='Existing' 
	  and SalesListingReviewStatus='Verified'
	  and ltrim(rtrim(a.SalesListingAvailabilityMode)) = 'Actual'
and a.UPC  != '0'
--and a.UPC = '19200006019'
order by a.UPC



-- relacion con producto padre
select top 100 UPC,
ACEUOMQuantity              ,
EJDUOMQuantity              ,
JensenUOMQuantity           ,
JensenFBA_UOMQuantity       ,
Dale_UOMQuantity            ,
Costellos_UOMQuantity       ,
Magefesa_UOMQuantity        ,
EMSCO_UOMQuantity           ,
EmpireFaucets_UOMQuantity   ,
BigRockSports_UOMQuantity   ,
Rugs2Go_UOMQuantity         ,
Tramontina_UOMQuantity      ,
Duospot_UOMQuantity         ,
CentralPet_UOMQuantity      ,
ProductWorks_UOMQuantity    ,
Folex_UOMQuantity			
,* 
from tmpEVPPARENTSKU a where EvpStatus = 'Active'
and UPC in (
24034610134	,24034610080	,43374790122	,53538401092	,
43374781397	,43374780970	,43374790955	,8236033793	,
92097960107	,92097960152	,92097960053	,8236033816	,
92097960305	,92097960251	,8236033786	,62964950289	,
62964914915	,32886866043	,897864002321)
order by a.UPC
-- sku es unitario ACE-123

select EvpStatus from tmpEVPPARENTSKU group by EvpStatus
-- 




/*
EvpStatus
Unverified
Delete
Inactive
Active
Deleted
*/

select Type from tmpEVPPARENTSKU group by Type
/*
Type
General
*/
select EJDUOMCode from tmpEVPPARENTSKU where EvpStatus = 'Active' GROUP BY EJDUOMCode

select SUBSTRING(EvpSku,1,CHARINDEX('-',EvpSku,1)) Proveedor, Rugs2Go_UOMQuantity, count(*) Cantidad
from tmpEVPPARENTSKU 
where EvpStatus = 'Active'
GROUP BY SUBSTRING(EvpSku,1,CHARINDEX('-',EvpSku,1)) ,Rugs2Go_UOMQuantity
order BY SUBSTRING(EvpSku,1,CHARINDEX('-',EvpSku,1)) ,Rugs2Go_UOMQuantity

select SUBSTRING(EvpSku,1,CHARINDEX('-',EvpSku,1)) Proveedor
from tmpEVPPARENTSKU 
where EvpStatus = 'Active'
GROUP BY SUBSTRING(EvpSku,1,CHARINDEX('-',EvpSku,1)) 
order BY SUBSTRING(EvpSku,1,CHARINDEX('-',EvpSku,1)) 

select *
from tmpEVPPARENTSKU 
where EvpStatus = 'Active' AND EvpSku LIKE '%UNFI-%'


SELECT UPC,
ACEUOMQuantity              ,
EJDUOMQuantity              ,
JensenUOMQuantity           ,
JensenFBA_UOMQuantity       ,
Dale_UOMQuantity            ,
Costellos_UOMQuantity       ,
Magefesa_UOMQuantity        ,
EMSCO_UOMQuantity           ,
EmpireFaucets_UOMQuantity   ,
BigRockSports_UOMQuantity   ,
Rugs2Go_UOMQuantity         ,
Tramontina_UOMQuantity      ,
Duospot_UOMQuantity         ,
CentralPet_UOMQuantity      ,
ProductWorks_UOMQuantity    ,
Folex_UOMQuantity			,
CASE WHEN (ACEUOMQuantity > 0.0 and EJDUOMQuantity > 0.0 AND ACEUOMQuantity != EJDUOMQuantity)
  OR (EJDUOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != EJDUOMQuantity)
  OR (JensenFBA_UOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != JensenFBA_UOMQuantity)
  OR (JensenFBA_UOMQuantity > 0.0 AND Dale_UOMQuantity > 0.0 AND Dale_UOMQuantity != JensenFBA_UOMQuantity)
  OR (Costellos_UOMQuantity > 0.0 AND Dale_UOMQuantity > 0.0 AND Dale_UOMQuantity != Costellos_UOMQuantity)
  OR (Costellos_UOMQuantity > 0.0 AND Magefesa_UOMQuantity > 0.0 AND Magefesa_UOMQuantity != Costellos_UOMQuantity)
  OR (EMSCO_UOMQuantity > 0.0 AND Magefesa_UOMQuantity > 0.0 AND Magefesa_UOMQuantity != EMSCO_UOMQuantity)
  OR (EMSCO_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity != EMSCO_UOMQuantity)
  OR (BigRockSports_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity != BigRockSports_UOMQuantity)
  OR (BigRockSports_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity != BigRockSports_UOMQuantity)
  OR (Tramontina_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity != Tramontina_UOMQuantity)
  OR (Tramontina_UOMQuantity > 0.0 AND Duospot_UOMQuantity > 0.0 AND Duospot_UOMQuantity != Tramontina_UOMQuantity)
  OR (CentralPet_UOMQuantity > 0.0 AND Duospot_UOMQuantity > 0.0 AND Duospot_UOMQuantity != CentralPet_UOMQuantity)
  OR (CentralPet_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity != CentralPet_UOMQuantity)    
  OR (Folex_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity != Folex_UOMQuantity) THEN 'FAIL' ELSE 'OK' END QuantityEvaluation
from(

	select UPC, 
		CAST(ACEUOMQuantity             AS FLOAT )ACEUOMQuantity              ,
		CAST(EJDUOMQuantity             AS FLOAT )EJDUOMQuantity              ,
		CAST(JensenUOMQuantity          AS FLOAT )JensenUOMQuantity           ,
		CAST(JensenFBA_UOMQuantity      AS FLOAT )JensenFBA_UOMQuantity       ,
		CAST(Dale_UOMQuantity           AS FLOAT )Dale_UOMQuantity            ,
		CAST(Costellos_UOMQuantity      AS FLOAT )Costellos_UOMQuantity       ,
		CAST(Magefesa_UOMQuantity       AS FLOAT )Magefesa_UOMQuantity        ,
		CAST(EMSCO_UOMQuantity          AS FLOAT )EMSCO_UOMQuantity           ,
		CAST(EmpireFaucets_UOMQuantity  AS FLOAT )EmpireFaucets_UOMQuantity   ,
		CAST(BigRockSports_UOMQuantity  AS FLOAT )BigRockSports_UOMQuantity   ,
		CAST(Rugs2Go_UOMQuantity        AS FLOAT )Rugs2Go_UOMQuantity         ,
		CAST(Tramontina_UOMQuantity     AS FLOAT )Tramontina_UOMQuantity      ,
		CAST(Duospot_UOMQuantity        AS FLOAT )Duospot_UOMQuantity         ,
		CAST(CentralPet_UOMQuantity     AS FLOAT )CentralPet_UOMQuantity      ,
		CAST(ProductWorks_UOMQuantity   AS FLOAT )ProductWorks_UOMQuantity    ,
		CAST(Folex_UOMQuantity			AS FLOAT)Folex_UOMQuantity			
	from tmpEVPPARENTSKU 
	where EvpStatus = 'Active'
--	AND UPC IN ('93432155127','70798275218','30878335102','95421075201','32247617833')
)x
WHERE (ACEUOMQuantity > 0.0 and EJDUOMQuantity > 0.0 AND ACEUOMQuantity != EJDUOMQuantity)
  OR (EJDUOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != EJDUOMQuantity)
  OR (JensenFBA_UOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != JensenFBA_UOMQuantity)
  OR (JensenFBA_UOMQuantity > 0.0 AND Dale_UOMQuantity > 0.0 AND Dale_UOMQuantity != JensenFBA_UOMQuantity)
  OR (Costellos_UOMQuantity > 0.0 AND Dale_UOMQuantity > 0.0 AND Dale_UOMQuantity != Costellos_UOMQuantity)
  OR (Costellos_UOMQuantity > 0.0 AND Magefesa_UOMQuantity > 0.0 AND Magefesa_UOMQuantity != Costellos_UOMQuantity)
  OR (EMSCO_UOMQuantity > 0.0 AND Magefesa_UOMQuantity > 0.0 AND Magefesa_UOMQuantity != EMSCO_UOMQuantity)
  OR (EMSCO_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity != EMSCO_UOMQuantity)
  OR (BigRockSports_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity > 0.0 AND EmpireFaucets_UOMQuantity != BigRockSports_UOMQuantity)
  OR (BigRockSports_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity != BigRockSports_UOMQuantity)
  OR (Tramontina_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity > 0.0 AND Rugs2Go_UOMQuantity != Tramontina_UOMQuantity)
  OR (Tramontina_UOMQuantity > 0.0 AND Duospot_UOMQuantity > 0.0 AND Duospot_UOMQuantity != Tramontina_UOMQuantity)
  OR (CentralPet_UOMQuantity > 0.0 AND Duospot_UOMQuantity > 0.0 AND Duospot_UOMQuantity != CentralPet_UOMQuantity)
  OR (CentralPet_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity != CentralPet_UOMQuantity)    
  OR (Folex_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity > 0.0 AND ProductWorks_UOMQuantity != Folex_UOMQuantity) 


--
SELECT UPC,
max(ACEUOMQuantity              )ACEUOMQuantity              ,
max(EJDUOMQuantity              )EJDUOMQuantity              ,
max(JensenUOMQuantity           )JensenUOMQuantity           ,
max(JensenFBA_UOMQuantity       )JensenFBA_UOMQuantity       ,
max(Dale_UOMQuantity            )Dale_UOMQuantity            ,
max(Costellos_UOMQuantity       )Costellos_UOMQuantity       ,
max(Magefesa_UOMQuantity        )Magefesa_UOMQuantity        ,
max(EMSCO_UOMQuantity           )EMSCO_UOMQuantity           ,
max(EmpireFaucets_UOMQuantity   )EmpireFaucets_UOMQuantity   ,
max(BigRockSports_UOMQuantity   )BigRockSports_UOMQuantity   ,
max(Rugs2Go_UOMQuantity         )Rugs2Go_UOMQuantity         ,
max(Tramontina_UOMQuantity      )Tramontina_UOMQuantity      ,
max(Duospot_UOMQuantity         )Duospot_UOMQuantity         ,
max(CentralPet_UOMQuantity      )CentralPet_UOMQuantity      ,
max(ProductWorks_UOMQuantity    )ProductWorks_UOMQuantity    ,
max(Folex_UOMQuantity			)Folex_UOMQuantity			
from tmpEVPPARENTSKU 
where EvpStatus = 'Active'
AND UPC IN ('93432155127','70798275218','30878335102','95421075201','32247617833')
GROUP BY UPC
ORDER BY UPC

--,,,,,,,,,ACE-58321
SELECT UPC, COUNT(*) from tmpEVPPARENTSKU 
where EvpStatus = 'Active'
--GROUP BY UPC HAVING COUNT(*) >1


-- informacion del supplier catalogos
select top 10 * from tmpSTSuppliersCatalog where Item_UPC_Code=739236301093
select distinct Casepack_Qty, UnitofMeasure_Qty from tmpSTSuppliersCatalog

select top 10 * from tmpSTSuppliersCatalog 

select Item_Status from tmpSTSuppliersCatalog WITH(NOLOCK) GROUP BY Item_Status
/*
Item_Status
S
A
T
9
N
*/

-- tiene campo Qty pero no parece ser la cantidad de unidades por paquete
select top 10 * from tmpCatalogEVP where Qty>0 

select top 100 * from tmpCatalogEVP where Status = 'Active' and  Qty>0 

select [Type] from tmpCatalogEVP group by [Type]
/*
Type

Purchase
None
*/

select [Item Type] from tmpCatalogEVP group by [Item Type]
/*
Item Type
Item
Assembly
VariantGroup
VariantItem
Kit
Service
*/

select Status from tmpCatalogEVP group by Status
/*
Status
Unverified
Delete
Inactive
Active
Deleted
*/
