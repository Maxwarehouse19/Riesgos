select 
--EJDUOMQuantity              --JensenUOMQuantity         --Dale_UOMQuantity          --Costellos_UOMQuantity     
--Magefesa_UOMQuantity      xx
--EMSCO_UOMQuantity         xx
--EmpireFaucets_UOMQuantity 
--BigRockSports_UOMQuantity xx
--Rugs2Go_UOMQuantity       --Tramontina_UOMQuantity    
--Duospot_UOMQuantity      xx
--CentralPet_UOMQuantity    
--ProductWorks_UOMQuantity  
--Folex_UOMQuantity			
from tmpEVPPARENTSKU with(nolock)
group by 
--EJDUOMQuantity              --JensenUOMQuantity         --Dale_UOMQuantity          
--Costellos_UOMQuantity     
--Magefesa_UOMQuantity      XX
--EMSCO_UOMQuantity         xx
--EmpireFaucets_UOMQuantity 
--BigRockSports_UOMQuantity xx
--Rugs2Go_UOMQuantity       
--Tramontina_UOMQuantity    
--Duospot_UOMQuantity       xx
--CentralPet_UOMQuantity    
--ProductWorks_UOMQuantity  
--Folex_UOMQuantity			













select a.UPC, a.Asin, a.Title, [Item Package Quantity], a.UOMQuantity,
EvpSku,
b.Title,
EJDUOMQuantity              ,
JensenUOMQuantity           ,
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
--select top 10 * 
from tmpListingInventoryAmazon a
INNER JOIN tmpEVPPARENTSKU b WITH(NOLOCK) 
	on EvpStatus = 'Active'
	and b.UPC= a.UPC	
where SalesListingStatus='Existing' and SalesListingReviewStatus='Verified'
and SalesListingPublicationMode in ('PriceAvailability','Full')
-- El listing debe estar expresado en múltiplos de la cantidad indicada en el parent
and (( cast(cast(EJDUOMQuantity            as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(EJDUOMQuantity            as float) as int))!=0))
or ( cast(cast(JensenUOMQuantity         as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(JensenUOMQuantity         as float) as int))!=0))
or ( cast(cast(Dale_UOMQuantity          as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(Dale_UOMQuantity          as float) as int))!=0))
or ( cast(cast(Costellos_UOMQuantity     as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(Costellos_UOMQuantity     as float) as int))!=0))
or ( cast(cast(Magefesa_UOMQuantity      as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(Magefesa_UOMQuantity      as float) as int))!=0))
or ( cast(cast(EMSCO_UOMQuantity         as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(EMSCO_UOMQuantity         as float) as int))!=0))
or ( cast(cast(EmpireFaucets_UOMQuantity as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(EmpireFaucets_UOMQuantity as float) as int))!=0))
or ( cast(cast(BigRockSports_UOMQuantity as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(BigRockSports_UOMQuantity as float) as int))!=0))
or ( cast(cast(Rugs2Go_UOMQuantity       as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(Rugs2Go_UOMQuantity       as float) as int))!=0))
or ( cast(cast(Tramontina_UOMQuantity    as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(Tramontina_UOMQuantity    as float) as int))!=0))
or ( cast(cast(Duospot_UOMQuantity       as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(Duospot_UOMQuantity       as float) as int))!=0))
or ( cast(cast(CentralPet_UOMQuantity    as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(CentralPet_UOMQuantity    as float) as int))!=0))
or ( cast(cast(ProductWorks_UOMQuantity  as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(ProductWorks_UOMQuantity  as float) as int))!=0))
or ( cast(cast(Folex_UOMQuantity		 as float)as int) >= 1 and ((cast(UOMQuantity as int) % cast(cast(Folex_UOMQuantity		    as float) as int))!=0)))
------------------------------------------------------------------------------------



--and a.UPC = '19200006019'

select SalesListingPublicationMode
from tmpListingInventoryAmazon with(nolock)
group by SalesListingPublicationMode


SELECT a.UPC
,case when a.UPC = '0' THEN 'varios ' ELSE  EvpSku END  EvpSku,COUNT(*) cantidad
FROM tmpEVPPARENTSKU a WITH(NOLOCK)
INNER JOIN (
	SELECT UPC, count(*) cantidad
	from tmpEVPPARENTSKU WITH(NOLOCK) 
	where EvpStatus = 'Active'
	group by UPC
	HAVING COUNT(*) > 1
)b ON a.UPC = b.UPC
where EvpStatus = 'Active'
group by a.UPC,case when a.UPC = '0' THEN 'varios ' ELSE  EvpSku END 
ORDER by a.UPC,case when a.UPC = '0' THEN 'varios ' ELSE  EvpSku END 

select UPC, EvpStatus,EvpSku, EJDSku, ACESku, JensenSku,DaleHardwareSku, CostellosSku, MagefesaSku, 
EMSCOSku,EmpireFaucetsSku, BigRockSportsSku,Rugs2GoSku,DuospotSku,CentralPetSku,ProductWorksSku,
FolexSku,EtailSku,*
from tmpEVPPARENTSKU a WITH(NOLOCK) 
where EvpStatus = 'Active' and UPC IN (
772051514,772051743,
772051743,8236033786)
ORDER BY a.UPC, a.EJDSku

-- UPC con distintos sku
SELECT a.UPC
,case when a.UPC = '0' THEN 'varios ' ELSE  SUBSTRING(EvpSku,CHARINDEX('-',EvpSku,1)+1,30) END EvpSku,COUNT(*) cantidad
FROM tmpEVPPARENTSKU a WITH(NOLOCK)
INNER JOIN (
	SELECT UPC, count(*) cantidad
	from tmpEVPPARENTSKU WITH(NOLOCK) 
	where EvpStatus = 'Active'
	group by UPC
	HAVING COUNT(*) > 1
)b ON a.UPC = b.UPC
where EvpStatus = 'Active'
group by a.UPC,case when a.UPC = '0' THEN 'varios ' ELSE  SUBSTRING(EvpSku,CHARINDEX('-',EvpSku,1)+1,30) END 
HAVING COUNT(*) = 1
ORDER by a.UPC,case when a.UPC = '0' THEN 'varios ' ELSE  SUBSTRING(EvpSku,CHARINDEX('-',EvpSku,1)+1,30) END 

-- Diferencias en cantidad
SELECT UPC,EvpSku,
--ACEUOMQuantity              ,
EJDUOMQuantity              ,
JensenUOMQuantity           ,
--JensenFBA_UOMQuantity       ,
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
CASE WHEN 
  --En reunión del 08/06/2021 Roger indica que ACEUOMQuantity no debe tomarse en consideración
  --(ACEUOMQuantity > 0.0 and EJDUOMQuantity > 0.0 AND ACEUOMQuantity != EJDUOMQuantity)OR 
  (EJDUOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != EJDUOMQuantity)
  --En reunión del 08/06/2021 Roger indica que JensenFBA_UOMQuantity no debe tomarse en consideración
  --FBA: Fullfilled by Amzon
  --OR (JensenFBA_UOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != JensenFBA_UOMQuantity)
  OR (JensenUOMQuantity > 0.0 AND Dale_UOMQuantity > 0.0 AND Dale_UOMQuantity != JensenUOMQuantity)
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

	select UPC, EvpSku,
		--CAST(ACEUOMQuantity             AS FLOAT )ACEUOMQuantity              ,
		CAST(EJDUOMQuantity             AS FLOAT )EJDUOMQuantity              ,
		CAST(JensenUOMQuantity          AS FLOAT )JensenUOMQuantity           ,
		--CAST(JensenFBA_UOMQuantity      AS FLOAT )JensenFBA_UOMQuantity       ,
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
WHERE
  --(ACEUOMQuantity > 0.0 and EJDUOMQuantity > 0.0 AND ACEUOMQuantity != EJDUOMQuantity)OR 
  (EJDUOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != EJDUOMQuantity)
  --OR (JensenFBA_UOMQuantity > 0.0 AND JensenUOMQuantity > 0.0 AND JensenUOMQuantity != JensenFBA_UOMQuantity)
  OR (JensenUOMQuantity > 0.0 AND Dale_UOMQuantity > 0.0 AND Dale_UOMQuantity != JensenUOMQuantity)
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
order by UPC,EvpSku