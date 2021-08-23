USE [MaxWarehouse]
GO

DECLARE @IdGraph INT, @IdReport INT

select @IdGraph  = id FROM django_content_type WHERE app_label = 'Home' and model = 'Graphic'
select @IdReport  = id FROM django_content_type WHERE app_label = 'Home' and model = 'Report'

insert into auth_permission (name,	   content_type_id,	   codename)
SELECT * FROM (
	select 'Latest Shipdate Reports' name, @IdReport   content_type_id,	'reports_lateshidate'   codename union
	select 'Latest Shipdate Graph' name, @IdGraph   content_type_id,	'graph_lateshidate'   codename
)x
