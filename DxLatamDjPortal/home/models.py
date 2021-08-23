from django.db import models

from django.core.exceptions import ValidationError 
from django.core.validators import RegexValidator
from django.core.validators import EmailValidator
from compositefk.fields import CompositeForeignKey
from django.core.validators import MinValueValidator, MaxValueValidator

from django_currentuser.middleware import (
    get_current_user, get_current_authenticated_user)
from django_currentuser.db.models import CurrentUserField

from datetime import datetime
import simplejson as json
#from .fields import DatetimeEncoder
from django.utils import timezone

#se vuelve a definir acá la función para evitar error de compilación
class DatetimeEncoder(json.JSONEncoder):
    def default(self, obj):
        try:
            return super().default(obj)
        except TypeError:
            return str(obj)

def email_validation_function(value):
    validator = EmailValidator()
    try:
        validator(value)
    except ValidationError:
        raise ValidationError("Formato de email no válido") 
    return value 

class Part(models.Model):
    AUTONUM = models.TextField() 
    CATEGORY = models.TextField(default = ' ') 
    NUMBER = models.TextField(default = ' ')
    PART_NUM = models.TextField(default = ' ')
    PART_DESC = models.TextField(default = ' ')
    PART_otro = models.TextField(default = ' ')
    Slug = models.SlugField(unique = True)

TipoEstado = [
    ('ACTIVO','Activo'),
    ('INACTIVO','Inactivo'),
]

TipoModoContacto = [
    ('SMS','Mensaje de Texto'),    
]

TipoPeriodicidad = [
    ('MINUTO','Minutos'),    
    ('HORA','Horas'),    
]

TipoSP_Validacion =[
    ('ChkPoint_RealizarAnalisis', 'Cantidad Orden Venta'),
    ('ChkPoint_Shipping', 'Controles de Shipping'),
    ('ChkPoint_LatestShipdate','Controles Latest Shipdate')
]

TipoParam = [
    ('INT','Entero'),
    ('STR','Letras'),
]

############################################################################################################
# MÓDULO DE CLASIFICACIONES
############################################################################################################
class Category(models.Model):
    code = models.CharField(max_length=10)
    title = models.CharField(max_length=100)
    parent = models.ForeignKey('self', null=True, blank=True,on_delete=models.SET_NULL, related_name='subcategory')
    
    def children(self):
        """Return subcategory."""
        return Category.objects.filter(parent=self)

    @property
    def is_parent(self):
        """Return `True` if instance is a parent."""
        if self.parent is not None:
            return False
        return True

    def __str__ (self):
        return self.title;
    
class CategoryManager(models.Manager):

    def all(self):
        """Return results of instance with no parent (not a subcategory)."""
        qs = super().filter(parent=None)
        return qs

############################################################################################################
# MÓDULO DE ALERTAS
############################################################################################################
class Alecontactos(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro' ,primary_key=True)  # Field name made lowercase.
    #idregistro = models.IntegerField(db_column='IdRegistro')  # Field name made lowercase.
    idcontacto = models.CharField(db_column='IdContacto', max_length=40,validators =[email_validation_function] )  # Field name made lowercase.
    telefono = models.CharField(db_column='Telefono', max_length=20, validators = [RegexValidator(r'^\+?[0-9() -]{6,}$', "Formato teléfono no válido")])  # Field name made lowercase.
    nombrecompleto = models.CharField(db_column='NombreCompleto', max_length=80)  # Field name made lowercase.
    puesto = models.CharField(db_column='Puesto', max_length=30)  # Field name made lowercase.
    modocontacto = models.CharField(db_column='ModoContacto', max_length=10, choices=TipoModoContacto)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=10, choices=TipoEstado )  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico', default=0)  # Field name made lowercase.
    fechacreacion = models.IntegerField(db_column='FechaCreacion', default=0)  # Field name made lowercase.
    horacreacion = models.IntegerField(db_column='HoraCreacion', default=0)  # Field name made lowercase.
    fechamodificacion = models.IntegerField(db_column='FechaModificacion', default=0)  # Field name made lowercase.
    horamodifcacion = models.IntegerField(db_column='HoraModifcacion', default=0)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ALECONTACTOS'
        unique_together = (('estadologico', 'idcontacto', 'telefono'),)    

class Alelistacontacto(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    idlista = models.CharField(db_column='IdLista', max_length=10)  # Field name made lowercase.
    descripcion = models.CharField(db_column='Descripcion', max_length=80)  # Field name made lowercase.
    idcontacto = models.CharField(db_column='IdContacto', max_length=40)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=10, choices=TipoEstado)  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico', default=0)  # Field name made lowercase.
    fechacreacion = models.IntegerField(db_column='FechaCreacion', default=0)  # Field name made lowercase.
    horacreacion = models.IntegerField(db_column='HoraCreacion', default=0)  # Field name made lowercase.
    fechamodificacion = models.IntegerField(db_column='FechaModificacion', default=0)  # Field name made lowercase.
    horamodifcacion = models.IntegerField(db_column='HoraModifcacion', default=0)  # Field name made lowercase.
    
    class Meta:
        managed = False
        db_table = 'ALELISTACONTACTO'
        unique_together = (('estadologico', 'idlista', 'idcontacto'),)

class Alemensaje(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    idmensaje = models.CharField(db_column='IdMensaje', max_length=10)  # Field name made lowercase.
    criterio = models.CharField(db_column='Criterio', max_length=10)  # Field name made lowercase.
    idlista = models.CharField(db_column='IdLista', max_length=10)  # Field name made lowercase.
    subject = models.CharField(db_column='Subject', max_length=50)  # Field name made lowercase.
    mensaje = models.CharField(db_column='Mensaje', max_length=160)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=10, choices=TipoEstado)  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico', default=0)  # Field name made lowercase.
    fechacreacion = models.IntegerField(db_column='FechaCreacion', default=0)  # Field name made lowercase.
    horacreacion = models.IntegerField(db_column='HoraCreacion', default=0)  # Field name made lowercase.
    fechamodificacion = models.IntegerField(db_column='FechaModificacion', default=0)  # Field name made lowercase.
    horamodifcacion = models.IntegerField(db_column='HoraModifcacion', default=0)  # Field name made lowercase.

    #Contactos asociados
   # contacto =  models.ForeignKey(
   #     Alelistacontacto, on_delete=models.CASCADE)

    class Meta:
        managed = False
        db_table = 'ALEMENSAJE'
        unique_together = (('estadologico', 'idmensaje', 'criterio'),)

    def __str__ (self):
        return self.subject;

class Altchkpoint(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    idchkpoint = models.CharField(db_column='IdChkPoint', max_length=10)  # Field name made lowercase.
    canalytiposorden = models.CharField(db_column='CanalyTiposOrden', max_length=30)  # Field name made lowercase.
    fechainicial = models.IntegerField(db_column='FechaInicial')  # Field name made lowercase.
    horainicial = models.IntegerField(db_column='HoraInicial')  # Field name made lowercase.
    fechafinal = models.IntegerField(db_column='FechaFinal')  # Field name made lowercase.
    horafinal = models.IntegerField(db_column='HoraFinal')  # Field name made lowercase.
    valordifminimo = models.DecimalField(db_column='ValorDifMinimo', max_digits=7, decimal_places=2)  # Field name made lowercase.
    valordifmaximo = models.DecimalField(db_column='ValorDifMaximo', max_digits=7, decimal_places=2)  # Field name made lowercase.
    toleranciainferior = models.DecimalField(db_column='ToleranciaInferior', max_digits=7, decimal_places=2)  # Field name made lowercase.
    toleranciasuperior = models.DecimalField(db_column='ToleranciaSuperior', max_digits=7, decimal_places=2)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=10, choices=TipoEstado)  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico', default=0)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ALTCHKPOINT'
        unique_together = (('estadologico', 'idchkpoint', 'canalytiposorden', 'fechainicial', 'horainicial'),)
    
class Alechkpoint(models.Model):    
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    idchkpoint = models.CharField(db_column='IdChkPoint', max_length=10)  # Field name made lowercase.
    fechavigencia = models.IntegerField(db_column='FechaVigencia')  # Field name made lowercase.
    horainicial = models.IntegerField(db_column='HoraInicial')  # Field name made lowercase.
    descripicion = models.CharField(db_column='Descripicion', max_length=30)  # Field name made lowercase.
    sp_validacion = models.CharField(db_column='sp_Validacion', max_length=30, choices=TipoSP_Validacion)  # Field name made lowercase.
    idmensaje = models.CharField(db_column='IdMensaje', max_length=10)  # Field name made lowercase.
    mensajeinf = models.CharField(db_column='MensajeInf', max_length=10)  # Field name made lowercase.
    mensajsup = models.CharField(db_column='MensajSup', max_length=10)  # Field name made lowercase.
    unirevision = models.CharField(db_column='UniRevision', max_length=10, choices=TipoPeriodicidad)  # Field name made lowercase.
    periodicidad = models.SmallIntegerField(db_column='Periodicidad', validators=[MinValueValidator(1),MaxValueValidator(60)])  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=10, choices=TipoEstado)  # Field name made lowercase.
    horafinal = models.IntegerField(db_column='HoraFinal')  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico', default=0)  # Field name made lowercase.

    ##El detalle de la configuracón por punto de venta está acá
    #altchkpoint =  models.ForeignKey(
    #    Altchkpoint, on_delete=models.CASCADE)
    #
    ##Mensajes asociados
    #alelistacontacto =  models.ForeignKey(
    #    Alelistacontacto, on_delete=models.CASCADE)

    class Meta:
        managed = False
        db_table = 'ALECHKPOINT'
        unique_together = (('estadologico', 'idchkpoint', 'fechavigencia', 'horainicial'),)

class Albidetchkpoint(models.Model):
    #idregistro = models.BigAutoField(db_column='IdRegistro')  # Field name made lowercase.
    idregistro = models.BigAutoField(db_column='IdRegistro' ,primary_key=True)  # Field name made lowercase.
    fecha = models.IntegerField(db_column='Fecha')  # Field name made lowercase.
    idchkpoint = models.CharField(db_column='IdChkPoint', max_length=10)  # Field name made lowercase.
    hora = models.IntegerField(db_column='Hora')  # Field name made lowercase.
    canalytiposorden = models.CharField(db_column='CanalyTiposOrden', max_length=30)  # Field name made lowercase.
    accion = models.CharField(db_column='Accion', max_length=10)  # Field name made lowercase.
    fechamodelo = models.IntegerField(db_column='FechaModelo')  # Field name made lowercase.
    horamodelo = models.IntegerField(db_column='HoraModelo')  # Field name made lowercase.
    prediccion = models.DecimalField(db_column='Prediccion', max_digits=7, decimal_places=2)  # Field name made lowercase.
    valorreal = models.DecimalField(db_column='ValorReal', max_digits=7, decimal_places=2)  # Field name made lowercase.
    diferencia = models.DecimalField(db_column='Diferencia', max_digits=7, decimal_places=2)  # Field name made lowercase.
    variacion = models.DecimalField(db_column='Variacion', max_digits=7, decimal_places=2)  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico', default=0)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ALBIDETCHKPOINT'
        unique_together = (('estadologico', 'fecha', 'idchkpoint', 'hora', 'canalytiposorden', 'horamodelo'),)

class Aleordenventa(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    fecha = models.BigIntegerField(db_column='Fecha', blank=True, null=True)  # Field name made lowercase.
    hora = models.BigIntegerField(db_column='Hora', blank=True, null=True)  # Field name made lowercase.
    canalventa = models.CharField(db_column='CanalVenta', max_length=15, blank=True, null=True)  # Field name made lowercase.
    tiposordenventa = models.CharField(db_column='TiposOrdenVenta', max_length=28, blank=True, null=True)  # Field name made lowercase.
    canalytiposorden = models.CharField(db_column='CanalyTiposOrden', max_length=50, blank=True, null=True)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=9, blank=True, null=True)  # Field name made lowercase.
    moneda = models.CharField(db_column='Moneda', max_length=6, blank=True, null=True)  # Field name made lowercase.
    monto = models.DecimalField(db_column='Monto', max_digits=18, decimal_places=2, blank=True, null=True)  # Field name made lowercase.
    año = models.IntegerField(db_column='Año', blank=True, null=True)  # Field name made lowercase.
    mes = models.CharField(db_column='Mes', max_length=20, blank=True, null=True)  # Field name made lowercase.
    dia = models.IntegerField(db_column='Dia', blank=True, null=True)  # Field name made lowercase.
    sku = models.CharField(db_column='SKU', max_length=1500, blank=True, null=True)  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico', default=0)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ALEORDENVENTA'
        unique_together = (('estadologico', 'canalytiposorden', 'fecha', 'hora', 'idregistro'),)

class Prediccion(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    canalytiposorden = models.CharField(db_column='CanalyTiposOrden', max_length=50, blank=True, null=True)  # Field name made lowercase.
    date = models.IntegerField()
    hour = models.SmallIntegerField()
    last_training = models.CharField(max_length=20)
    prediction = models.DecimalField(max_digits=11, decimal_places=2)
    fechacreacion = models.BigIntegerField(db_column='FechaCreacion', blank=True, null=True)  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'PREDICCION'
        unique_together = (('estadologico', 'canalytiposorden', 'date', 'hour'),)

class Alebitacora(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    fecha = models.IntegerField(db_column='Fecha')  # Field name made lowercase.
    hora = models.IntegerField(db_column='Hora')  # Field name made lowercase.
    idmensaje = models.CharField(db_column='IdMensaje', max_length=10)  # Field name made lowercase.
    criterio = models.CharField(db_column='Criterio', max_length=10)  # Field name made lowercase.
    idlista = models.CharField(db_column='IdLista', max_length=10)  # Field name made lowercase.
    idcontacto = models.CharField(db_column='IdContacto', max_length=40)  # Field name made lowercase.
    telefono = models.CharField(db_column='Telefono', max_length=20)  # Field name made lowercase.
    subject = models.CharField(db_column='Subject', max_length=50)  # Field name made lowercase.
    mensaje = models.CharField(db_column='Mensaje', max_length=160)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=10, default=0)  # Field name made lowercase.
    descerror = models.CharField(db_column='DescError', max_length=200)  # Field name made lowercase.
    estadologico = models.BigIntegerField(db_column='EstadoLogico')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ALEBITACORA'

class Reporteinconsistenciascarrier(models.Model):
    id = models.BigAutoField(db_column='Id',primary_key=True)  # Field name made lowercase.
    salesordernumber = models.CharField(db_column='SalesOrderNumber', max_length=255, blank=True, null=True)  # Field name made lowercase.
    requestedservicelevel = models.CharField(db_column='RequestedServiceLevel', max_length=255, blank=True, null=True)  # Field name made lowercase.
    proship_service_plaintext = models.CharField(db_column='PROSHIP_SERVICE_PLAINTEXT', max_length=255, blank=True, null=True)  # Field name made lowercase.
    billedweight = models.CharField(db_column='BilledWeight', max_length=255, blank=True, null=True)  # Field name made lowercase.
    cambioservicio = models.CharField(db_column='CambioServicio', max_length=15)  # Field name made lowercase.
    fechainsercion = models.DateTimeField(db_column='FechaInsercion', blank=True, null=True)  # Field name made lowercase.
    esnuevo = models.CharField(db_column='EsNuevo', max_length=2)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ReporteInconsistenciasCarrier'

class Promedioservicio(models.Model):
    id = models.IntegerField(db_column='ID',primary_key=True)  # Field name made lowercase.
    servicetype = models.CharField(db_column='ServiceType', max_length=50, blank=True, null=True)  # Field name made lowercase.
    conteo = models.IntegerField(db_column='Conteo', blank=True, null=True)  # Field name made lowercase.
    netchargeamount = models.FloatField(db_column='NetChargeAmount', blank=True, null=True)  # Field name made lowercase.
    promedioservicio = models.FloatField(db_column='PromedioServicio', blank=True, null=True)  # Field name made lowercase.
    fechaingreso = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'PROMEDIOSERVICIO'
        
class Amazonlate(models.Model):
    id = models.AutoField(db_column='ID',primary_key=True)  # Field name made lowercase.
    channel = models.CharField(db_column='Channel', max_length=50, blank=True, null=True)  # Field name made lowercase.
    fulfillmentlocationname = models.CharField(db_column='FulfillmentLocationName', max_length=50, blank=True, null=True)  # Field name made lowercase.
    trackingnumber = models.CharField(db_column='TrackingNumber', max_length=20, blank=True, null=True)  # Field name made lowercase.
    fechaentregasegunchannel = models.DateTimeField(db_column='FechaEntregaSegunChannel', blank=True, null=True)  # Field name made lowercase.
    fechaentregaseguncarrier = models.DateTimeField(db_column='FechaEntregaSegunCarrier', blank=True, null=True)  # Field name made lowercase.
    shipmentdate = models.DateTimeField(db_column='ShipmentDate', blank=True, null=True)  # Field name made lowercase.
    ultimoestado = models.CharField(db_column='UltimoEstado', max_length=250, blank=True, null=True)  # Field name made lowercase.
    ultimaexcepcion = models.CharField(db_column='UltimaExcepcion', max_length=250, blank=True, null=True)  # Field name made lowercase.
    fechaingreso = models.DateTimeField(db_column='FechaIngreso', blank=True, null=True)  # Field name made lowercase.
    stateregion = models.CharField(db_column='StateRegion', max_length=250, blank=True, null=True)  # Field name made lowercase.
    class Meta:
        managed = False
        db_table = 'AMAZONLATE'

class Resumeninsightlate(models.Model):
    id = models.IntegerField(db_column='ID',primary_key=True)  # Field name made lowercase.
    channel = models.CharField(db_column='Channel', max_length=50, blank=True, null=True)  # Field name made lowercase.
    total = models.IntegerField(db_column='Total', blank=True, null=True)  # Field name made lowercase.
    tarde = models.IntegerField(db_column='Tarde', blank=True, null=True)  # Field name made lowercase.
    fechaingreso = models.DateTimeField(db_column='FechaIngreso', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'RESUMENINSIGHTLATE'

class RepDiffquantity(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    fechaingreso = models.DateField(db_column='FechaIngreso')  # Field name made lowercase.
    sku = models.CharField(db_column='Sku', max_length=100, blank=True, null=True)  # Field name made lowercase.
    sku_status = models.CharField(db_column='SKU Status', max_length=100, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    listing = models.CharField(db_column='Listing', max_length=100, blank=True, null=True)  # Field name made lowercase.
    listing_status = models.CharField(db_column='Listing Status', max_length=100, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    amazonuomquantity = models.FloatField(db_column='AmazonUomQuantity', blank=True, null=True)  # Field name made lowercase.
    publicationmode = models.CharField(db_column='PublicationMode', max_length=200, blank=True, null=True)  # Field name made lowercase.
    review_state = models.CharField(db_column='Review State', max_length=200, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    availabilitymode = models.CharField(db_column='AvailabilityMode', max_length=200, blank=True, null=True)  # Field name made lowercase.
    number_of_items = models.FloatField(db_column='Number Of Items', blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    item_package_quantity = models.CharField(db_column='Item Package Quantity', max_length=200, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    asin = models.CharField(db_column='ASIN', max_length=200, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Rep_DiffQuantity'

class Latestshipdate(models.Model):
    salesordernumber = models.CharField(db_column='SalesOrderNumber', max_length=25, blank=True, null=True)  # Field name made lowercase.
    salesorderdate = models.DateTimeField(db_column='SalesOrderDate', blank=True, null=True)  # Field name made lowercase.
    latestshipdate = models.DateTimeField(db_column='LatestShipDate', blank=True, null=True)  # Field name made lowercase.
    po = models.CharField(db_column='PO', max_length=25, blank=True, null=True)  # Field name made lowercase.
    totalsales = models.FloatField(db_column='TotalSales', blank=True, null=True)  # Field name made lowercase.
    sku = models.CharField(db_column='SKU', max_length=500, blank=True, null=True)  # Field name made lowercase.
    diassinfin = models.IntegerField(db_column='DiasSinFin', blank=True, null=True)  # Field name made lowercase.
    fulfillmentlocationname = models.CharField(db_column='FulfillmentLocationName', max_length=50, blank=True, null=True)  # Field name made lowercase.
    latency = models.IntegerField(db_column='Latency', blank=True, null=True)  # Field name made lowercase.
    fechainsercion = models.DateTimeField(db_column='FechaInsercion', blank=True, null=True)  # Field name made lowercase.
    shippingserviceslevel = models.CharField(db_column='ShippingServicesLevel', max_length=50, blank=True, null=True)  # Field name made lowercase.
    id = models.BigAutoField(db_column='ID',primary_key=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'LatestShipDate'

class BitacoraDecambios(models.Model):
    id           = models.BigAutoField(db_column='ID',primary_key=True)  # Field name made lowercase.
    fecha        = models.DateTimeField(null=False, default=datetime.now())
    usuario      = CurrentUserField(related_name = 'usuarios')    
    tabla        = models.CharField(max_length=30)
    valores      = models.CharField(max_length=200)
    estadologico = models.BigIntegerField(default=0) 
    accion       = models.CharField(max_length=10, default = 'none')
    
class Locationlatency(models.Model):
    location  = models.CharField(db_column='Location', max_length=38)  # Field name made lowercase.
    latency   = models.IntegerField()
    statecode = models.CharField(db_column='StateCode', max_length=10, blank=True, null=True)  # Field name made lowercase.
    id        = models.BigAutoField(db_column='ID',primary_key=True)  # Field name made lowercase.

    def save(self):
        registro = super(Locationlatency, self).save()

        qs = Locationlatency.objects.values(
                 'location','latency','statecode','id'
            ).filter(id= self.id)
        vjson = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

        BitacoraDecambios.objects.create(
            fecha        = timezone.now(),
            tabla        = 'LocationLatency',
            valores      = vjson,
            accion       = 'save'
        )

    def delete(self):

        qs = Locationlatency.objects.values(
                 'location','latency','statecode','id'
            ).filter(id= self.id)
        vjson = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

        registro = super(Locationlatency, self).delete()

        BitacoraDecambios.objects.create(
            fecha        = timezone.now(),
            tabla        = 'LocationLatency',
            valores   = vjson,
            accion       = 'delete'
        )

    class Meta:
        managed = False
        db_table = 'LocationLatency'

class Staticparams(models.Model):    
    id            = models.BigAutoField(primary_key=True)     
    modulo        = models.CharField(max_length=30)
    nombre        = models.CharField(max_length=30)
    tipoparametro = models.CharField(max_length=3, choices=TipoParam)
    valstr        = models.CharField(max_length=30, blank=True, null=True)
    valint        = models.IntegerField(blank=True, null=True)

    def save(self):
        registro = super(Staticparams, self).save()

        qs = Staticparams.objects.values(
                'valint','valstr','tipoparametro', 'nombre','modulo','id'
            ).filter(id= self.id)
        vjson = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

        BitacoraDecambios.objects.create(
            fecha        = timezone.now(),
            tabla        = 'Staticparams',
            valores   = vjson,
            accion       = 'save'
        )

    def delete(self):
     
        qs = Staticparams.objects.values(
                'valint','valstr','tipoparametro', 'nombre','modulo','id'
            ).filter(id= self.id)
        vjson = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

        registro = super(Staticparams, self).delete()

        BitacoraDecambios.objects.create(
            fecha        = timezone.now(),
            tabla        = 'Staticparams',
            valores   = vjson,
            accion       = 'delete'
        )

class Latestshipdatesku(models.Model):
    id = models.BigAutoField(db_column='ID',primary_key=True)  # Field name made lowercase.
    fechaingreso = models.DateTimeField(db_column='FechaIngreso', blank=True, null=True)  # Field name made lowercase.
    sku = models.CharField(db_column='SKU', max_length=20, blank=True, null=True)  # Field name made lowercase.
    cantidad = models.IntegerField(db_column='Cantidad', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'LatestshipdateSKU'

class LsDiasxcantidad(models.Model):
    id = models.BigAutoField(db_column='Id',primary_key=True)
    fechaingreso = models.DateField(db_column='FechaIngreso', blank=True, null=True)  # Field name made lowercase.
    statecode = models.CharField(db_column='StateCode', max_length=10, blank=True, null=True)  # Field name made lowercase.
    fulfillmentlocationname = models.CharField(db_column='FulfillmentLocationName', max_length=50, blank=True, null=True)  # Field name made lowercase.
    number_0 = models.IntegerField(db_column='0', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_1 = models.IntegerField(db_column='1', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_2 = models.IntegerField(db_column='2', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_3 = models.IntegerField(db_column='3', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_4 = models.IntegerField(db_column='4', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_5 = models.IntegerField(db_column='5', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_6 = models.IntegerField(db_column='6', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_7 = models.IntegerField(db_column='7', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_8 = models.IntegerField(db_column='8', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_9 = models.IntegerField(db_column='9', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_10 = models.IntegerField(db_column='10', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_11 = models.IntegerField(db_column='11', blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    latency = models.IntegerField(db_column='Latency', blank=True, null=True)  # Field name made lowercase.
    
    class Meta:
        managed = False
        db_table = 'LS_DiasXCantidad'    

class LsDiasxmonto(models.Model):
    id = models.BigAutoField(db_column='Id',primary_key=True)
    fechaingreso = models.DateField(db_column='FechaIngreso', blank=True, null=True)  # Field name made lowercase.
    statecode = models.CharField(db_column='StateCode', max_length=10, blank=True, null=True)  # Field name made lowercase.
    fulfillmentlocationname = models.CharField(db_column='FulfillmentLocationName', max_length=50, blank=True, null=True)  # Field name made lowercase.
    number_0 = models.DecimalField(db_column='0', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_1 = models.DecimalField(db_column='1', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_2 = models.DecimalField(db_column='2', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_3 = models.DecimalField(db_column='3', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_4 = models.DecimalField(db_column='4', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_5 = models.DecimalField(db_column='5', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_6 = models.DecimalField(db_column='6', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_7 = models.DecimalField(db_column='7', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_8 = models.DecimalField(db_column='8', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_9 = models.DecimalField(db_column='9', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_10 = models.DecimalField(db_column='10', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    number_11 = models.DecimalField(db_column='11', max_digits=11, decimal_places=2, blank=True, null=True)  # Field renamed because it wasn't a valid Python identifier.
    latency = models.IntegerField(db_column='Latency', blank=True, null=True)  # Field name made lowercase.
    class Meta:
        managed = False
        db_table = 'LS_DiasXMonto'