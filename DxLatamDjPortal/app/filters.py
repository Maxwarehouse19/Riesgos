from django import forms
from .models import  dtBatch
import django_filters
from django_filters import NumberFilter
from datetime import datetime 
from .fields import date_to_integer
from .fields import *

class repLoteFilterForm(forms.Form):

    field_order = ['fecha_inicial','fecha_final','operador']
    
    def clean(self):
       cleaned_data = super(repLoteFilterForm, self).clean()

       frm_fechainicial = cleaned_data.get("fecha_inicial")
       ifrm_fechainicial = date_to_integer(frm_fechainicial)
       #if(ifrm_fechainicial>0):
        #    self.cleaned_data['fecha_inicial'] = ifrm_fechainicial
       
       frm_fechafinal = cleaned_data.get("fecha_final")
       ifrm_fechafinal = date_to_integer(frm_fechafinal)
       #if(ifrm_fechafinal>0):
        #    self.cleaned_data['fecha_final'] = ifrm_fechafinal
    
       if (ifrm_fechafinal>= 0  and ifrm_fechainicial>= 0 and ifrm_fechafinal < ifrm_fechainicial):
           self._errors['fecha_inicial'] = self.error_class(['Fecha inicial mayor a final'])

       return cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(repLoteFilterForm,self).__init__(*args, **kwargs)
        
        self['fecha_inicial'].label ="Fecha desde:"
        self['fecha_final'].label ="Fecha hasta"

class repLoteFilter(django_filters.FilterSet):
   
    fecha_inicial = django_filters.DateFilter(field_name='fecharealizado', lookup_expr='gte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))

    fecha_final = django_filters.DateFilter(field_name='fecharealizado', lookup_expr='lte'
                                      , initial=datetime.now()
                                      , widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                              'onchange': 'grafica2form.submit();'}))
    operador = django_filters.ChoiceFilter(choices=USER_CHOICES
                                               ,widget=forms.Select(attrs={'onchange': 'grafica2form.submit();'}))

    def __init__(self, data, *args, **kwargs):
        if not data.get('fecha_inicial'):
            data = data.copy()
            data['fecha_inicial'] =  datetime.now()          
        super().__init__(data, *args, **kwargs)
    
    class Meta:
        model = dtBatch
        fields = [ 'fecha_inicial','fecha_final','operador']

        field_order = ['fecha_inicial','fecha_final','operador'          
                    ]

        form = repLoteFilterForm