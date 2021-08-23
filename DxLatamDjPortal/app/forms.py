"""
Definition of forms.
"""

from django import forms
from django.forms import ModelForm
from .models import Tablaprueba, preguntas
from .fields import *

class TablapruebaForm(ModelForm):
 
    class Meta:
        model = Tablaprueba
        fields = ['tipo','nombre']
        labels = {'tipo':'Tipo','nombre':'Nombre'}
    
    # this function will be used for the validation
    def clean(self):
 
        # data from the form is fetched using super function
        super(TablapruebaForm, self).clean()
         
        nombrecompleto = self.cleaned_data.get('nombre')
        
 
        # conditions 
        if nombrecompleto == None or len(nombrecompleto) < 10:
            self._errors['nombre'] = self.error_class([
                'Nombre Completo debe tener más de 10 caracteres.'])
        
 
        try:
            sc = Tablaprueba.objects.get(nombre = nombrecompleto)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe ")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Tablaprueba.DoesNotExist:
            pass

        # return any errors if found
        return self.cleaned_data

class PreguntasMatchForm(forms.Form):

    questions = preguntas.objects.values_list('id','textual','respposibles')
    for question in questions:
        if question[2]=='23':
            locals()["pregunta" + str(question[0])] = forms.ChoiceField(label=question[1],choices=PREGUNTA_CHOICES23)
        else:
            locals()["pregunta" + str(question[0])] = forms.ChoiceField(label=question[1],choices=PREGUNTA_CHOICES123)   
    veredicto  = forms.ChoiceField(label="Estado Final",choices=VEREDICTO_CHOICES)
    
    # this function will be used for the validation
    def clean(self):
        for resp in self.cleaned_data:
            if self.cleaned_data.get(resp)=='0':
                self._errors[resp] = self.error_class([
                'Debe de elegir una respuesta'])
        # data from the form is fetched using super function
        super(PreguntasMatchForm, self).clean()

        # return any errors if found
        return self.cleaned_data

class PreguntasSupervisor(forms.Form):
  
    veredicto  = forms.ChoiceField(label="Luego de analizar la información. Respuesta Final del Supervisor:",choices=SUPERVISOR_CHOICES)

    # this function will be used for the validation
    def clean(self):
        if self.cleaned_data.get('veredicto') == '0':
            self._errors[resp] = self.error_class([
                'Debe de elegir una respuesta'])
        # data from the form is fetched using super function
        super(PreguntasSupervisor, self).clean()

        # return any errors if found
        return self.cleaned_data