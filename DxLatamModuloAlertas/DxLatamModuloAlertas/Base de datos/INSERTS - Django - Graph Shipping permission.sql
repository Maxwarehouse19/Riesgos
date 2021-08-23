DECLARE @IdGraph INT

select @IdGraph  = id FROM django_content_type WHERE app_label = 'Home' and model = 'Graphic'

insert into auth_permission (name,	   content_type_id,	   codename)
SELECT * FROM (
	
	select 'Shipping Dashboard' name, @IdGraph   content_type_id,	'graph_shipping'   codename 

)x
