insert into django_content_type (app_label,model)
SELECT * FROM (
	select 	'home' app_label,	'Graphic' model union
	select 	'home' app_label,	'Report' model
)X

DECLARE @IdGraph INT, @IdReport INT

select @IdGraph  = id FROM django_content_type WHERE app_label = 'Home' and model = 'Graphic'
select @IdReport  = id FROM django_content_type WHERE app_label = 'Home' and model = 'Report'

insert into auth_permission (name,	   content_type_id,	   codename)
SELECT * FROM (
	
	select 'Sales Orders Dashboard' name, @IdGraph   content_type_id,	'graph_salesorders'   codename union
	select 'Shipping Reports ' name, @IdReport   content_type_id,	'reports_shipping'   codename union
	select 'Alert Reports ' name, @IdReport   content_type_id,	'reports_alerts'   codename
)x
