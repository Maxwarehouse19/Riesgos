from django import forms
from .models import Altchkpoint,Alechkpoint,Category,TipoEstado,Alebitacora,Alemensaje,Alelistacontacto,Alecontactos,Reporteinconsistenciascarrier,Promedioservicio,Amazonlate,RepDiffquantity,Latestshipdate,BitacoraDecambios,Latestshipdatesku
import django_filters
from django_filters import NumberFilter
from datetime import datetime 

from .fields import HOUR_CHOICES ,HOUR_CHOICES2,HOUR_CHOICES3,HOUR_CHOICES4,Month_choice,Year_choice,chkpoint_choices,PV_Choices,LC_Choices,EsBitacora_choice,date_to_integer,LateDays_choice,USR_Choices,get_LatestShipdate_MaxSKU

class AltchkpointFilterForm(forms.Form):

    def clean(self):
       cleaned_data = super(AltchkpointFilterForm, self).clean()
       frm_Anio = cleaned_data.get("Anio")
       frm_Mes  = cleaned_data.get("Mes")
    
       if ((frm_Mes != None and frm_Mes != '' ) and (frm_Anio == None or frm_Anio == '')):
           self._errors['Anio'] = self.error_class(['Valor requerido'])
    
       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(AltchkpointFilterForm,self).__init__(*args, **kwargs)
        self['idchkpoint'].label="Checkpoint igual a:"
        self['canalytiposorden'].label="Punto Venta igual a:"   
        self['horaini_desde'].label="Hora Inicial desde:"
        self['horainicial_hasta'].label="Hora Inicial hasta:"
        #self['horafinal'].label="Hora final igual a:"
        self['estado'].label="Estado igual a:"        

class AltchkpointFilter(django_filters.FilterSet):
    
    horaini_desde = django_filters.ChoiceFilter(choices=HOUR_CHOICES     
                                               ,field_name="horainicial", lookup_expr='gte'
                                               ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
    horainicial_hasta = django_filters.ChoiceFilter(choices=HOUR_CHOICES2    
                                             ,field_name="horainicial", lookup_expr='lte'
                                             ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
    idchkpoint =  django_filters.ChoiceFilter(choices=chkpoint_choices 
                                              ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
    canalytiposorden = django_filters.ChoiceFilter(choices=PV_Choices 
                                              ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))

    Anio = django_filters.ChoiceFilter(choices=Year_choice
        ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'})
        ,field_name='fechainicial', lookup_expr= 'icontains', label="Del Año")

    Mes = django_filters.ChoiceFilter(field_name='fechainicial'
                                      ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'})
                                      , method='get_fechainicial_anio',choices=Month_choice, label = "Desde el mes" )
    
    estado = django_filters.ChoiceFilter(choices=TipoEstado
                                               ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
    
    def get_fechainicial_anio(self, queryset, field_name, value):        

        if self.form.is_valid():
            frm_Anio = int(self.form.cleaned_data.get('Anio')) 
            frm_Mes  = int(value)
            if (not frm_Anio or frm_Anio == None or frm_Anio == 0):
                fechasAnioIni = frm_Anio * 10000 + 101  # enero de ese año 
            else :
                fechasAnioIni = frm_Anio * 10000 + (frm_Mes * 100) + 1  # primer día de ese mes

            fechasAnioFin = frm_Anio * 10000 + 1231 # diiembre de ese año 

            return queryset.filter(fechainicial__range=[fechasAnioIni, fechasAnioFin])
        else:
            return queryset

    class Meta:
        model = Altchkpoint
        fields = [ 'idchkpoint' 
                  ,'canalytiposorden'                   
                  ,'estado' ]

        form = AltchkpointFilterForm

######################################################################################################
##   REPORTES DE SHIPPING
######################################################################################################

##   Reporte de mensajes enviados
class AlebitacoraFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final','hora_desde','hora_hasta',            
                       'idmensaje', 'criterio', 'idlista'                    
                        'idcontacto','mensaje','estado'                    
                    ]
    
    def clean(self):
       cleaned_data = super(AlebitacoraFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       ifrm_fechainicial = date_to_integer(frm_fechainicial)
       if(ifrm_fechainicial>0):
            self.cleaned_data['fecha_inicial'] = ifrm_fechainicial
       
       frm_fechafinal = cleaned_data.get("fecha_final")
       ifrm_fechafinal = date_to_integer(frm_fechafinal)
       if(ifrm_fechafinal>0):
            self.cleaned_data['fecha_final'] = ifrm_fechafinal
    
       if (ifrm_fechafinal>= 0  and ifrm_fechainicial>= 0 and ifrm_fechafinal < ifrm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])

       frm_horainicial = cleaned_data.get("hora_desde")
       frm_horafinal   = cleaned_data.get("hora_hasta")

       if (frm_horafinal!= '' and frm_horainicial!= '' and int(frm_horafinal) < int(frm_horainicial)):
           self._errors['hora_desde'] = self.error_class(['Hora inicial mayor a final'])


       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(AlebitacoraFilterForm,self).__init__(*args, **kwargs)
        self['hora_desde'].label="Hora desde:"
        self['hora_hasta'].label="Hora hasta:"        
        self['estado'].label="Estado igual a:"        
        self['idmensaje'] .label = "Mensaje: "
        self['criterio']  .label = "Criterio: "
        self['idlista']   .label = "Lista de contacto:"
        self['idcontacto'].label = "Contacto:" 
        self['fecha_inicial'].label ="Fecha desde:"
        self['fecha_final'].label ="Fecha hasta"
        self['mensaje'].label ="Mensaje contiene"

class AlebitacoraFilter(django_filters.FilterSet):
    
    hora_desde = django_filters.ChoiceFilter(choices=HOUR_CHOICES3     
                                               ,field_name="hora", lookup_expr='gte'
                                               ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
    hora_hasta = django_filters.ChoiceFilter(choices=HOUR_CHOICES4    
                                             ,field_name="hora", lookup_expr='lte'
                                             ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
   
    fecha_inicial = django_filters.DateFilter(field_name='fecha', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fecha', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    estado = django_filters.ChoiceFilter(choices=EsBitacora_choice
                                               ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
    
    idmensaje= django_filters.ChoiceFilter(choices=tuple(Alemensaje.objects.values_list('idmensaje','subject').filter(estadologico = 0).distinct())
                                            ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))

    criterio= django_filters.ChoiceFilter(choices=tuple(Alemensaje.objects.values_list('criterio','criterio').filter(estadologico = 0).distinct())
                                           ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))

    idlista = django_filters.ChoiceFilter(choices=LC_Choices
                                           ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))
    
    idcontacto = django_filters.ChoiceFilter(choices=tuple(Alecontactos.objects.values_list('idcontacto','nombrecompleto').filter(estadologico = 0).distinct())
                                              ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))    

    mensaje = django_filters.CharFilter(field_name="mensaje", lookup_expr='contains')

    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()          
        super().__init__(data, *args, **kwargs)
    
    class Meta:
        model = Alebitacora
        fields = [ 'estado','idmensaje','criterio'  ,'idlista','idcontacto']

        field_order = ['fecha_inicial','fecha_final','hora_desde','hora_hasta',            
                       'idmensaje', 'criterio', 'idlista'                    
                        'idcontacto','mensaje','estado'                    
                    ]

        form = AlebitacoraFilterForm

##   Reporte de Requested vs Actual
class RequestedVsActualFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final','cambioservicio'
                   ,'salesordernumber','requestedservicelevel','proship_service_plaintext',]


    def clean(self):
       cleaned_data = super(RequestedVsActualFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       frm_fechafinal = cleaned_data.get("fecha_final")
            
       if (frm_fechafinal and frm_fechainicial and frm_fechafinal < frm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])

    
       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(RequestedVsActualFilterForm,self).__init__(*args, **kwargs)
        self['salesordernumber'].label = "Salesorder Number"
        self['requestedservicelevel'].label = 	"Requested Service Level"
        self['proship_service_plaintext'].label = "Actual Service"
        self['cambioservicio'].label = "Cambio Servicio"
        self['fecha_inicial'].label ="Fecha desde"
        self['fecha_final'].label ="Fecha hasta"

class RequestedVsActualFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fechainsercion', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fechainsercion', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    requestedservicelevel = django_filters.CharFilter(field_name="requestedservicelevel", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

    proship_service_plaintext = django_filters.CharFilter(field_name="proship_service_plaintext", lookup_expr='contains'
                                     , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

    salesordernumber = django_filters.CharFilter(field_name="salesordernumber", lookup_expr='contains'
                                    , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
   
    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()         
        super().__init__(data, *args, **kwargs)

    class Meta:
        model = Reporteinconsistenciascarrier
        fields = [ 'salesordernumber','requestedservicelevel','proship_service_plaintext',
            'cambioservicio']

        field_order = ['fecha_inicial','fecha_final','cambioservicio'
                   ,'salesordernumber','requestedservicelevel','proship_service_plaintext',]

        form = RequestedVsActualFilterForm

##   Reporte de Requested vs Actual
class RepPromedioServicioFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final'
                       ,'servicetype'
                       #,'conteo','promedioservicio',
                       ]

    def clean(self):
       cleaned_data = super(RepPromedioServicioFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       frm_fechafinal = cleaned_data.get("fecha_final")
            
       if (frm_fechafinal and frm_fechainicial and frm_fechafinal < frm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])
    
       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(RepPromedioServicioFilterForm,self).__init__(*args, **kwargs)        
        self['servicetype'].label = "Service Type"
        self['fecha_inicial'].label ="Fecha desde"
        self['fecha_final'].label ="Fecha hasta"

class RepPromedioServicioFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))
 
    servicetype = django_filters.CharFilter(field_name="servicetype", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

   
    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()         
        super().__init__(data, *args, **kwargs)

    class Meta:
        model = Promedioservicio
        fields = [ 'fecha_inicial','fecha_final','servicetype'
                  #,'conteo','netchargeamount','promedioservicio','fechaingreso'
                  ]

        field_order = ['fecha_inicial','fecha_final'
                                              ,'servicetype'
                       #,'conteo','promedioservicio',
                       ]

        form = RepPromedioServicioFilterForm

#Reporte Amazon Late 
class AmazonlateFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final'            
                       ,'channel', 'trackingnumber','ultimoestado'
                  ,'ultimaexcepcion','fechaentregasegunchannel', 'fechaentregaseguncarrier'
                  ,'shipmentdate','fulfillmentlocationname','stateregion'
                       ]

    def clean(self):
       cleaned_data = super(AmazonlateFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       frm_fechafinal = cleaned_data.get("fecha_final")
            
       if (frm_fechafinal and frm_fechainicial and frm_fechafinal < frm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])
    
       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(AmazonlateFilterForm,self).__init__(*args, **kwargs)        
        self['fecha_inicial'].label ="Fecha desde"
        self['fecha_final'].label ="Fecha hasta"
        self['channel'             ].label = "Channel"
        self['trackingnumber'      ].label = "Tracking Number"
        self['ultimoestado'        ].label = "Ultimo Estado"
        self['ultimaexcepcion'     ].label = "Ultima Excepcion"
        self['fechaentregasegunchannel'].label = "Entrega Channel"
        self['fechaentregaseguncarrier'].label = "Entrega Carrier"
        self['shipmentdate'            ].label = "Shipment"
        self['fulfillmentlocationname' ].label = "Fulfillment Location"
        self['stateregion' ].label = "State Region"        

class AmazonlateFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fechaentregasegunchannel = django_filters.DateFilter(field_name='fechaentregasegunchannel', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                               'onchange': 'grafica2form.submit();'}))

    fechaentregaseguncarrier = django_filters.DateFilter(field_name='fechaentregaseguncarrier', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))
    
    shipmentdate = django_filters.DateFilter(field_name='shipmentdate', lookup_expr='gte'
                                  , initial=datetime.now()
                                  , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))
    
    channel = django_filters.CharFilter(field_name="channel", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

    trackingnumber = django_filters.CharFilter(field_name="trackingnumber", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

    ultimoestado = django_filters.CharFilter(field_name="ultimoestado", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

    ultimaexcepcion = django_filters.CharFilter(field_name="ultimaexcepcion", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

    fulfillmentlocationname = django_filters.CharFilter(field_name="fulfillmentlocationname", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))

    stateregion = django_filters.CharFilter(field_name="stateregion", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    
    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()         
        super().__init__(data, *args, **kwargs)

    class Meta:
        model = Amazonlate
        fields = [ 'channel', 'trackingnumber','ultimoestado'
                  ,'ultimaexcepcion','fechaentregasegunchannel', 'fechaentregaseguncarrier'
                  ,'shipmentdate',
                   'fecha_inicial','fecha_final','stateregion'
                  ]

        field_order = ['fecha_inicial','fecha_final'            
                       ,'channel', 'trackingnumber','ultimoestado'
                  ,'ultimaexcepcion','fechaentregasegunchannel', 'fechaentregaseguncarrier'
                  ,'shipmentdate','fulfillmentlocationname','stateregion'
                       ]

        form = AmazonlateFilterForm
######################################################################################################
##   Latest Shipdate
######################################################################################################

class LatestshipdateFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final'
                   ,'latestshipdate','po','salesorderdate','salesordernumber',
                   'fulfillmentlocationname','shippingserviceslevel',
                    'sku','totalsales','diassinfin','latency'
                   ]

    def clean(self):
       cleaned_data = super(LatestshipdateFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       frm_fechafinal = cleaned_data.get("fecha_final")
            
       if (frm_fechafinal and frm_fechainicial and frm_fechafinal < frm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])
    
       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(LatestshipdateFilterForm,self).__init__(*args, **kwargs)        
        self['fecha_inicial'].label           ="Fecha ingreso desde"
        self['fecha_final'].label             ="Fecha ingreso hasta"        
        self['salesordernumber'].label        = "SO Number"
        self['salesorderdate'].label          = "SO Date"
        self['latestshipdate'].label          = "PO Date"
        self['po'].label                      = "PO Number"
        self['fulfillmentlocationname'].label = "Purchase Locations"
        self['shippingserviceslevel'].label   = "Shipping Service Level"
        self['sku'].label                     = "Item Summary"
        self['totalsales'].label              = "Total"        
        self['diassinfin'].label              = "Días Transcurridos"        
        self['latency'].label                 = "Latencia"

class LatestshipdateFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fechainsercion', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fechainsercion', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))


    salesorderdate         = django_filters.DateFilter(field_name='salesorderdate', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))
    latestshipdate         = django_filters.DateFilter(field_name='latestshipdate', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    salesordernumber       = django_filters.CharFilter(field_name="salesordernumber", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    po                     = django_filters.CharFilter(field_name="po", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    totalsales             = django_filters.CharFilter(field_name="totalsales", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    sku 			       = django_filters.CharFilter(field_name="sku", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    
    #diassinfin 		       = django_filters.CharFilter(field_name="diasinfin", lookup_expr='contains'
    #                                  , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    
    diassinfin = django_filters.ChoiceFilter(choices=LateDays_choice    
                                             ,field_name="diassinfin", lookup_expr='iexact'
                                             ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'})
                                             , method='get_diassinfin'
                                             )
    

    fulfillmentlocationname= django_filters.CharFilter(field_name="fulfillmentlocationname", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    latency 		       = django_filters.CharFilter(field_name="latency", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    shippingserviceslevel  = django_filters.CharFilter(field_name="shippingserviceslevel", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))


    
    def get_diassinfin(self, queryset, field_name, value):        

        if self.form.is_valid():
            frm_diassinfin = int(self.form.cleaned_data.get('diassinfin')) 
            
            if (frm_diassinfin and frm_diassinfin >= 11):
                return queryset.filter(diassinfin__gte=11)
            else:
                return queryset.filter(diassinfin__iexact=frm_diassinfin)

    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()         
        super().__init__(data, *args, **kwargs)

    class Meta:
        model = Latestshipdate
        fields = [ 'fecha_inicial','fecha_final'
                    ,'salesordernumber','salesorderdate','latestshipdate','po',
                    'totalsales','sku','diassinfin','fulfillmentlocationname',
                    'latency','shippingserviceslevel'
                  ]

        field_order = ['fecha_inicial','fecha_final'
                   ,'latestshipdate','po','salesorderdate','salesordernumber',
                   'fulfillmentlocationname','shippingserviceslevel',
                    'sku','totalsales','diassinfin','latency'
                   ]

        form = LatestshipdateFilterForm

class RepBitacoraDecambiosFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final','usuario', 'tabla', 'valores', 'accion']

    def clean(self):
       cleaned_data = super(RepBitacoraDecambiosFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       frm_fechafinal = cleaned_data.get("fecha_final")
            
       if (frm_fechafinal and frm_fechainicial and frm_fechafinal < frm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])
    
       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(RepBitacoraDecambiosFilterForm,self).__init__(*args, **kwargs)        
        self['fecha_inicial'].label ="Fecha desde"
        self['fecha_final'].label ="Fecha hasta"    

class RepBitacoraDecambiosFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fecha', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fecha', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    usuario = django_filters.ChoiceFilter(choices=USR_Choices    
                                             ,field_name="usuario"
                                             ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'})                                          
                                             )
    
    tabla       =  django_filters.CharFilter(field_name="tabla", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    
    valores  =  django_filters.CharFilter(field_name="valores", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
        
    accion      =  django_filters.CharFilter(field_name="accion", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))


    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()         
        super().__init__(data, *args, **kwargs)

    class Meta:
        model = BitacoraDecambios
        fields = [ 'fecha_inicial','fecha_final', 'usuario', 'tabla', 'valores', 'accion'
                  ]

        field_order = ['fecha_inicial','fecha_final', 'usuario', 'tabla', 'valores', 'accion'            
                      ]

        form = RepBitacoraDecambiosFilterForm

class RepLatestshipdateskuFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final','sku', 'cantidad_min','cantidad_max']

    def clean(self):
       cleaned_data = super(RepLatestshipdateskuFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       frm_fechafinal = cleaned_data.get("fecha_final")
       frm_cantidad_min = cleaned_data.get('cantidad_min')
       frm_cantidad_max = cleaned_data.get('cantidad_max')
              
       if (frm_fechafinal and frm_fechainicial and frm_fechafinal < frm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])
    
       if (frm_cantidad_max and frm_cantidad_min and frm_cantidad_max < frm_cantidad_min):
           self._errors['cantidad_min'] = self.error_class(['cantidad desde mayor a cantidad hasta'])
    

       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(RepLatestshipdateskuFilterForm,self).__init__(*args, **kwargs)        
        self['fecha_inicial'].label ="Fecha desde"
        self['fecha_final'].label ="Fecha hasta"
        self['cantidad_min'].label ="Cantidad desde"
        self['cantidad_max'].label ="Cantidad hasta"
        self['sku'].label ="SKU"
      

class RepLatestshipdateskuFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    sku =  django_filters.CharFilter(field_name="sku", lookup_expr='contains'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))                                         
    
    cantidad_min   =  django_filters.NumberFilter(field_name='cantidad', lookup_expr='gte'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    
    cantidad_max   =  django_filters.NumberFilter(field_name='cantidad', lookup_expr='lte'
                                      , widget=forms.widgets.DateInput(attrs={'onchange': 'grafica2form.submit();'}))
    
    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()   
        
        if not data.get('cantidad_min'):                        
            data = data.copy()
            data['cantidad_min'] =  get_LatestShipdate_MaxSKU()   

        super().__init__(data, *args, **kwargs)

    class Meta:
        model = Latestshipdatesku
        fields = ['fecha_inicial','fecha_final','sku', 'cantidad_min', 'cantidad_max']
        field_order = ['fecha_inicial','fecha_final','sku', 'cantidad_min','cantidad_max']
        form = RepLatestshipdateskuFilterForm

######################################################################################################
##   REPORTES DE LISTING MISMATCH
######################################################################################################
#Reporte Quantity Mismatch
class RepListingMismatchFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final']

    def clean(self):
       cleaned_data = super(RepListingMismatchFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       frm_fechafinal = cleaned_data.get("fecha_final")
            
       if (frm_fechafinal and frm_fechainicial and frm_fechafinal < frm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])
    
       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(RepListingMismatchFilterForm,self).__init__(*args, **kwargs)        
        self['fecha_inicial'].label ="Fecha desde"
        self['fecha_final'].label ="Fecha hasta"
      

class RepListingMismatchFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fechaingreso', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()         
        super().__init__(data, *args, **kwargs)

    class Meta:
        model = RepDiffquantity
        fields = [ 'fecha_inicial','fecha_final'
                  ]

        field_order = ['fecha_inicial','fecha_final'            
                      ]

        form = RepListingMismatchFilterForm