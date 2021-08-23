from django import forms
from django.contrib.auth.forms import AuthenticationForm
from django.utils.translation import ugettext_lazy as _

from django.forms import ModelForm
from .models import Alecontactos, Alelistacontacto, Alemensaje,Alechkpoint,Altchkpoint,Category,Locationlatency,Staticparams

#Globales
from .fields import *

class BootstrapAuthenticationForm(AuthenticationForm):
    """Authentication form which uses boostrap CSS."""
    username = forms.CharField(max_length=254,
                               widget=forms.TextInput({
                                   'class': 'form-control',
                                   'placeholder': 'User name'}))
    password = forms.CharField(label=_("Password"),
                               widget=forms.PasswordInput({
                                   'class': 'form-control',
                                   'placeholder':'Password'}))
############################################################################################################
# MÓDULO DE CLASIFICACIONES
############################################################################################################

class CategoryForm(ModelForm):
    
    class Meta:
        model = Category
        fields = ['id','code','title','parent']    
        labels = {'id':'id','code':'Código','title':'Descripción','parent':'Categoría Superior'}
    
    def __init__(self, *args, **kwargs):
        super(CategoryForm,self).__init__(*args, **kwargs)
        self.fields['code'].label = "Código" 
    
    # this function will be used for the validation
    def clean(self):
 
        # data from the form is fetched using super function
        super(CategoryForm, self).clean()
        frm_code = self.cleaned_data.get('code')
        frm_parent_id = self.cleaned_data.get('parent')

        try:
            if(frm_parent_id != None):
                sc = Category.objects.get(parent_id = frm_parent_id.pk , code = frm_code)
            else:
                sc = Category.objects.get(parent_id = None, code = frm_code)

            if not self.instance.pk:
                raise forms.ValidationError("Ya existe categoría")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Category.DoesNotExist:
            pass

        # return any errors if found
        return self.cleaned_data

############################################################################################################
# MÓDULO DE ALERTAS
############################################################################################################
from phonenumber_field.formfields import PhoneNumberField

class ContactoForm(ModelForm):
    telefono = PhoneNumberField()

    class Meta:
        model = Alecontactos
        fields = ['idcontacto','telefono','nombrecompleto','puesto','modocontacto','estado']
        labels = {'idcontacto':'Email','telefono':'Teléfono','nombrecompleto': 'Nombre Completo',
                  'puesto':'Puesto','modocontacto':'Tipo Alerta','estado':'Estado'}
    
    # this function will be used for the validation
    def clean(self):
 
        # data from the form is fetched using super function
        super(ContactoForm, self).clean()
         
        # extract the  field from the data
        #idcontacto = self.cleaned_data.get('idcontacto')
        #telefono = self.cleaned_data.get('telefono')
        #modocontacto = self.cleaned_data.get('modocontacto')        
        #estado =  self.cleaned_data.get('estado')

        nombrecompleto = self.cleaned_data.get('nombrecompleto')
        puesto = self.cleaned_data.get('puesto')
        frm_idcontacto = self.cleaned_data.get('idcontacto')
        frm_telefono = self.cleaned_data.get('telefono')
        
 
        # conditions 
        if nombrecompleto == None or len(nombrecompleto) < 10:
            self._errors['nombrecompleto'] = self.error_class([
                'Nombre Completo debe tener más de 10 caracteres.'])
        if puesto == None or len(puesto) < 2:
            self._errors['puesto'] = self.error_class([
                'El puesto debe tener al menos 2 caracteres'])
 
        try:
            sc = Alecontactos.objects.get(estadologico = 0,idcontacto =frm_idcontacto, telefono = frm_telefono)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe contacto")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Alecontactos.DoesNotExist:
            pass

        # return any errors if found
        return self.cleaned_data

class ListaContactoForm(ModelForm):

    idcontacto  = forms.ChoiceField(choices=tuple(Alecontactos.objects.values_list('idcontacto','nombrecompleto').filter(estadologico = 0).distinct()))    
    idlista     = forms.ChoiceField(choices=LC_Choices)
    descripcion = forms.CharField(widget = forms.HiddenInput(), required = False)
        
    class Meta:
        model = Alelistacontacto
        fields = ['idregistro', 'idlista','descripcion','idcontacto','estado']
        labels = {'idregistro':'idRegistro','idlista':'Código Lista','descripcion':'Descripción','idcontacto':'Código Contacto','estado' : 'Estado'}

    def __init__(self, *args, **kwargs):
        super(ListaContactoForm,self).__init__(*args, **kwargs)
        self.fields['idcontacto'].choices = tuple(Alecontactos.objects.values_list('idcontacto','nombrecompleto').filter(estadologico = 0).distinct())        
        self.initial['idcontacto'] = self.instance.idcontacto 
        self.fields['idcontacto'].label = "Nombre contacto"

        self.fields['idlista'].choices = LC_Choices
        
        if(self.instance.idlista!=None):
            self.initial['idlista'] = self.instance.idlista 
        
        self.fields['idlista'].label = "Lista de Contacto"

    # this function will be used for the validation
    def clean(self): 
        # data from the form is fetched using super function
        super(ListaContactoForm, self).clean()
    
        frm_idcontacto =  self.cleaned_data.get('idcontacto')
        frm_idlista    = self.cleaned_data.get('idlista')
        frm_idregistro = self.cleaned_data.get('idregistro')

        queryset=Alecontactos.objects.values('idcontacto').filter(estadologico = 0, idcontacto =frm_idcontacto)
        if queryset.count() == 0:
             self._errors['idcontacto'] = self.error_class([
                'El contacto debe existir y estar activo'])
        
        try:
            sc = Alelistacontacto.objects.get(estadologico = 0, idcontacto =frm_idcontacto, idlista = frm_idlista)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe contacto en esta lista")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Alelistacontacto.DoesNotExist:
            pass

        return self.cleaned_data

class MensajeForm(ModelForm):
    
    idmensaje = forms.ChoiceField(choices=MN_Choices)           
    idlista = forms.ChoiceField(choices=tuple(Alelistacontacto.objects.values_list('idlista','descripcion').filter(estadologico = 0).distinct()))       
    subject = forms.CharField(widget = forms.HiddenInput(), required = False)
    
    class Meta:
        model = Alemensaje        
        fields = ['idmensaje','criterio','idlista','subject','mensaje','estado']
        labels = {'idmensaje':'Código del Mensaje','criterio':'Criterio','idlista':'Lista de Contactos','subject':'Subject','mensaje':'Contenido','estado':'Estado'}

    def __init__(self, *args, **kwargs):
        super(MensajeForm,self).__init__(*args, **kwargs)
        self.fields['idlista'].choices = tuple(Alelistacontacto.objects.values_list('idlista','descripcion').filter(estadologico = 0).distinct())
        self.initial['idlista'] = self.instance.idlista 
        self.fields ['idlista'].label = "Lista de Contactos"

        self.fields ['idmensaje'].choices = MN_Choices
        
        if(self.instance.idmensaje!=None):
            self.initial['idmensaje'] = self.instance.idmensaje 

        self.fields ['idmensaje'].label = "Lista Mensaje"

    
    # this function will be used for the validation
    def clean(self): 
        # data from the form is fetched using super function
        super(MensajeForm, self).clean()
    
        frm_idlista   = self.cleaned_data.get('idlista')
        frm_idmensaje = self.cleaned_data.get('idmensaje')
        frm_criterio  = self.cleaned_data.get('criterio')
        
        queryset=Alelistacontacto.objects.values('idlista').filter(estadologico = 0, idlista =frm_idlista)
        if queryset.count() == 0:
             self._errors['idlista'] = self.error_class([
                'La lista de contacto debe existir y estar activa'])
        try:
            sc = Alemensaje.objects.get(estadologico = 0, idmensaje =frm_idmensaje, idlista = frm_idlista)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe mensaje con esta lista de contacto")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Ya existe mensaje con esta lista de contacto")


            sc = Alemensaje.objects.get(estadologico = 0, idmensaje =frm_idmensaje,  criterio = frm_criterio)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe mensaje con este criterio")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Alemensaje.DoesNotExist:
            pass

        return self.cleaned_data

class ChkpointForm(ModelForm):
    
    fechavigencia= forms.CharField(widget = forms.HiddenInput(), required = False)
    horainicial  = forms.CharField(widget = forms.HiddenInput(), required = False)
    horafinal    = forms.CharField(widget = forms.HiddenInput(), required = False) 

    datefechavigencia = forms.DateField(initial=datetime.now().strftime("%Y%m%d"), widget=forms.widgets.DateInput(attrs={'type': 'date'}))#forms.DateField();
    fmthorainicial    = forms.ChoiceField(choices = HOUR_CHOICESdt );
    fmthorafinal      = forms.ChoiceField(choices = HOUR_CHOICESdt2);
    
    idchkpoint = forms.ChoiceField(choices=CP_Choices)

    choices = tuple(Alemensaje.objects.values_list('idmensaje','subject').filter(estadologico = 0).distinct())
    idmensaje = forms.ChoiceField(choices=choices)

    descripicion = forms.CharField(widget = forms.HiddenInput(), required = False)

    mensajeinf = forms.ChoiceField(
        choices=tuple(Alemensaje.objects.values_list('criterio').filter(estadologico = 0).distinct()))

    mensajsup = forms.ChoiceField(
        choices=tuple(Alemensaje.objects.values_list('criterio').filter(estadologico = 0).distinct()))

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(ChkpointForm,self).__init__(*args, **kwargs)
        
        self.fields['fmthorainicial'].choices = HOUR_CHOICESdt
        self.fields['fmthorafinal'].choices   = HOUR_CHOICESdt2

        if(self.instance.idchkpoint!=None and self.instance.idchkpoint!= ''):
           self.initial['idchkpoint'] = self.instance.idchkpoint 

        if(self.instance.idmensaje != None and self.instance.idmensaje!=''):
            self.fields['mensajeinf'].choices = tuple(Alemensaje.objects.values_list('criterio','criterio').filter(estadologico = 0, idmensaje = self.instance.idmensaje).distinct())
        else:
            self.fields['mensajeinf'].choices = tuple(Alemensaje.objects.values_list('criterio','criterio').filter(estadologico = 0).distinct())

        self.fields ['mensajeinf'].label = "Criterio Inferior"

        if(self.instance.idmensaje != None and self.instance.idmensaje!=''):
            self.fields['mensajsup'].choices = tuple(Alemensaje.objects.values_list('criterio','criterio').filter(estadologico = 0, idmensaje = self.instance.idmensaje).distinct())
        else:
            self.fields['mensajsup'].choices = tuple(Alemensaje.objects.values_list('criterio','criterio').filter(estadologico = 0).distinct())

        self.fields ['mensajsup'].label = "Criterio Superior"

        self.fields['idmensaje'].choices = tuple(Alemensaje.objects.values_list('idmensaje','subject').filter(estadologico = 0,estado = 'ACTIVO').distinct())        
        self.fields ['idmensaje'].label = "Mensaje asociado"

        self.fields ['idchkpoint'].choices = CP_Choices
       
        self.fields ['idchkpoint'].label = "Punto de Validación"
        self.fields ['datefechavigencia'].label = "Fecha de Vigencia"
        self.fields ['fmthorainicial'].label = "Hora inicial"
        self.fields ['fmthorafinal'].label = "Hora final"

    # this function will be used for the validation
    def clean(self): 
        # data from the form is fetched using super function
        super(ChkpointForm, self).clean()
    
        frm_idchkpoint    = self.cleaned_data.get('idchkpoint')
        frm_idmensaje     = self.cleaned_data.get('idmensaje')
        frm_criterioInf   = self.cleaned_data.get('mensajeinf')
        frm_criterioSup   = self.cleaned_data.get('mensajsup')
        frm_datefechavigencia = self.cleaned_data.get('datefechavigencia')
        frm_fmthorainicial   = self.cleaned_data.get('fmthorainicial')
        frm_fmthorafinal     = self.cleaned_data.get('fmthorafinal')
        frm_unirevision     = self.cleaned_data.get('unirevision')
        frm_periodicidad     = self.cleaned_data.get('periodicidad')
         
        intfechavigencia = date_to_integer(frm_datefechavigencia)
        frm_horainicial = hour_to_integer(frm_fmthorainicial)
        frm_horafinal   = hour_to_integer(frm_fmthorafinal)

        fechaHoy = datetime.now().strftime("%Y%m%d")
        intFechaHoy = int(fechaHoy)

        if(frm_unirevision == 'MINUTO'):
            if(frm_periodicidad < 3 or frm_periodicidad > 60):
                self._errors['periodicidad'] = self.error_class([
                'Ingresar de 3 a 60 minutos'])
        elif(frm_periodicidad == None or frm_periodicidad < 1 or frm_periodicidad > 24):
                self._errors['periodicidad'] = self.error_class([
                'Ingresar de 1 a 24 horas'])

        if(intfechavigencia < intFechaHoy):
            self._errors['datefechavigencia'] = self.error_class([
                'Debe ingresar una fecha de hoy en adelante'])

        if(frm_horainicial>=0 and  frm_horafinal>=0 and frm_horainicial >= frm_horafinal):
            self._errors['fmthorainicial'] = self.error_class([
                'La la hora inicial debe ser menor a la final'])

        queryset=Alemensaje.objects.values('idmensaje').filter(estadologico = 0, idmensaje =frm_idmensaje, criterio = frm_criterioInf)
        if queryset.count() == 0:
             self._errors['mensajeinf'] = self.error_class([
                'El criterio debe estar asociado al mensaje'])

        queryset=Alemensaje.objects.values('idmensaje').filter(estadologico = 0, idmensaje =frm_idmensaje, criterio = frm_criterioSup)
        if queryset.count() == 0:
             self._errors['mensajsup'] = self.error_class([
                'El criterio debe estar asociado al mensaje'])

        try:
            sc = Alechkpoint.objects.get(estadologico = 0,  idchkpoint = frm_idchkpoint, fechavigencia = intfechavigencia, horainicial = frm_horainicial )
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe punto de revisión para fecha de vigencia y hora inicial")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Alechkpoint.DoesNotExist:
            pass

        return self.cleaned_data

    class Meta:
        model = Alechkpoint
        fields = ['idregistro'
                  ,'idchkpoint'
                  ,'descripicion'
                  ,'fechavigencia'
                  ,'datefechavigencia'
                  ,'fmthorainicial'
                  ,'fmthorafinal'
                  ,'horainicial'
                  ,'horafinal'
                  ,'sp_validacion'
                  ,'idmensaje'
                  ,'mensajeinf'
                  ,'mensajsup'
                  ,'unirevision'
                  ,'periodicidad'                  
                  ,'estado'
                  ]
        labels = {'idregistro':'idRegistro'
                  ,'idchkpoint':'Código Checkpoint'                  
                  ,'descripicion':'Descripcion'
                  ,'fechavigencia': 'Fecha de Vigencia'
                  ,'datefechavigencia': 'Fecha de Vigencia'                  
                  ,'horainicial':'Hora inicial'
                  ,'horafinal':'Hora Final'
                  ,'fmthorainicial':'Hora inicial'
                  ,'fmthorafinal':'Hora Final'
                  ,'sp_validacion':'Algoritmo de Validación'
                  ,'idmensaje':'Código del Mensaje'
                  ,'mensajeinf':'Criterio Inferior'
                  ,'mensajsup':'Criterio Superior'
                  ,'unirevision':'Unidad Tiempo'
                  ,'periodicidad' :'Periodicidad'
                  ,'estado':'Estado',
                  }
        
        widgets = {
              'datefechavigencia': forms.DateField(initial=datetime.now().strftime("%Y%m%d"), widget=forms.widgets.DateInput(attrs={'type': 'date'}))
        }


class DetChkpointForm(ModelForm):
    
    choices = tuple(Alechkpoint.objects.values_list('idchkpoint','descripicion').filter(estadologico = 0,estado = 'ACTIVO').distinct())
    idchkpoint = forms.ChoiceField(choices=choices)
    
    canalytiposorden = forms.ChoiceField(choices=PV_Choices)

    fechainicial= forms.CharField(widget = forms.HiddenInput(), required = False)
    fechafinal= forms.CharField(widget = forms.HiddenInput(), required = False)
    toleranciainferior= forms.CharField(widget = forms.HiddenInput(), required = False)
    toleranciasuperior= forms.CharField(widget = forms.HiddenInput(), required = False)
    
    datefechainicial = forms.DateField(initial=datetime.now().strftime("%Y%m%d"), widget=forms.widgets.DateInput(attrs={'type': 'date'}), required = False)#forms.DateField();
    datefechafinal = forms.DateField(initial=datetime.now().strftime("%Y%m%d"), widget=forms.widgets.DateInput(attrs={'type': 'date'}), required = False)#forms.DateField();
    horainicial = forms.ChoiceField(choices = HOUR_CHOICES );
    horafinal   = forms.ChoiceField(choices = HOUR_CHOICES);

    #Existe un inconveniente con la lista de elección cuando difiere el caractér del punto decimal
    #por eso se usa el valor entero para interactual con el usuario.
    INTtoleranciainferior = forms.ChoiceField(choices = PERCENT_CHOICES);
    INTtoleranciasuperior = forms.ChoiceField(choices = PERCENT_CHOICES);

    # this function will be used for the validation
    def clean(self): 
        # data from the form is fetched using super function
        super(DetChkpointForm, self).clean()

        frm_idchkpoint    = self.cleaned_data.get('idchkpoint')
        frm_canalytiposorden = self.cleaned_data.get('canalytiposorden')        
        frm_datefechainicial = self.cleaned_data.get('datefechainicial')
        frm_datefechafinal   = self.cleaned_data.get('datefechafinal')
        frm_horainicial      = self.cleaned_data.get('horainicial')
        frm_horafinal        = self.cleaned_data.get('horafinal')

        intfechainicial = date_to_integer(frm_datefechainicial)
        fechaHoy = datetime.now().strftime("%Y%m%d")
        intFechaHoy = int(fechaHoy)

        if(intfechainicial != 0 and intfechainicial < intFechaHoy):
            self._errors['datefechainicial'] = self.error_class([
                'Debe ingresar una fecha de hoy en adelante'])

        intfechafinal = date_to_integer(frm_datefechafinal)
        
        if(intfechafinal!= 0 and intfechafinal < intFechaHoy):
            self._errors['datefechafinal'] = self.error_class([
                'Debe ingresar una fecha de hoy en adelante'])

        if(intfechafinal < intfechainicial):
            self._errors['datefechainicial'] = self.error_class([
                'La fecha inicial debe ser menor a la final'])
        
        if(frm_horainicial > frm_horafinal):
            self._errors['horainicial'] = self.error_class([
                'La la hora inicial debe ser menor a la final'])

        try:
            sc = Altchkpoint.objects.get(estadologico = 0,  idchkpoint = frm_idchkpoint, fechainicial = intfechainicial, horainicial = frm_horainicial , canalytiposorden =frm_canalytiposorden)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe punto detalle para fecha y hora inicial")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Altchkpoint.DoesNotExist:
            pass

        return self.cleaned_data

    #Actualizando la selección con los datos de la tabla 
    def __init__(self, *args, **kwargs):
        super(DetChkpointForm,self).__init__(*args, **kwargs)

        self.fields ['datefechainicial'].label = "Fecha inicial"
        self.fields ['datefechafinal'].label = "Fecha final"
        self.fields ['idchkpoint'].label = "Punto de Validación"
        self.fields ['canalytiposorden'].label = "Punto de Venta"
        self.fields ['INTtoleranciainferior'].label = "% Tolerancia variación inferior"
        self.fields ['INTtoleranciasuperior'].label = "% Tolerancia variación superior"

        self.fields['horainicial'].label="Hora Inicial"
        self.fields['horafinal'].label  ="Hora Final"
        
        self.fields['idchkpoint'].choices = tuple(Alechkpoint.objects.values_list('idchkpoint','descripicion').filter(estadologico = 0).distinct())
       
        self.fields['canalytiposorden'].choices = PV_Choices

        self.fields['INTtoleranciainferior'].choices = PERCENT_CHOICES
        self.fields['INTtoleranciasuperior'].choices = PERCENT_CHOICES
            
      #  if(self.instance.toleranciasuperior!=None and self.instance.toleranciasuperior!= ''):
      #     self.fields['toleranciasuperior'].initial = self.instance.toleranciasuperior 
      #
      #  if(self.instance and self.instance.toleranciainferior!=None and self.instance.toleranciainferior!= ''):
      #     self.initial['toleranciainferior'] = self.instance.toleranciainferior 

    class Meta:
        model = Altchkpoint
        fields = ['idregistro','idchkpoint','canalytiposorden','fechainicial','fechafinal'
                  ,'horainicial','horafinal','valordifminimo','valordifmaximo','toleranciainferior'
                  ,'toleranciasuperior','estado'
                  ,'datefechainicial', 'datefechafinal'
                  ,'INTtoleranciainferior','INTtoleranciasuperior'
                  ]

        labels = {'idregistro':'idregistro','idchkpoint':'Código Checkpoint'
                  ,'canalytiposorden':'Punto de Venta'
                  ,'fechainicial':'Fecha Inicial','fechafinal': 'Fecha Final'
                  ,'datefechainicial':'Fecha Inicial','datefechafinal': 'Fecha Final'
                  ,'horainicial':'Hora Inicial'
                  ,'horafinal':'Hora Final'
                  ,'valordifminimo': 'Cantidad de Diferencia Mínima'
                  ,'valordifmaximo': 'Cantidad de Diferencia Máximo'
                  ,'toleranciainferior':'% Tolerancia variación inferior'
                  ,'INTtoleranciainferior':'% Tolerancia variación inferior'                  
                  ,'toleranciasuperior':'% Tolerancia variación superior'
                  ,'INTtoleranciasuperior':'% Tolerancia variación superior'
                  ,'estado':'Estado'}
  
        widgets = {
              'datefechainicial': forms.DateField(initial=datetime.now().strftime("%Y%m%d"), widget=forms.widgets.DateInput(attrs={'type': 'date'}))
              ,'datefechafinal': forms.DateField(initial=datetime.now().strftime("%Y%m%d"), widget=forms.widgets.DateInput(attrs={'type': 'date'}))
        }

class Grafica1Form(forms.Form):
   
    fecha = forms.DateField(initial=datetime.now(), widget=forms.widgets.DateInput(attrs={'type': 'date',
                                                                                          'placeholder':'yyyy-mm-dd'
                                                                                          }));
    canalytiposorden = forms.ChoiceField(choices=PV_Choices
                                             ,widget=forms.Select(attrs={'onchange': 'grafica1form.submit();'}))

    frmTiempoRefrescar = forms.ChoiceField(initial = 5*60, choices=WAIT_CHOICES
                                           ,widget=forms.Select(attrs={'onchange': 'grafica1form.submit();'}))

    def __init__(self, *args, **kwargs):
        super(Grafica1Form,self).__init__(*args, **kwargs)

        self.fields ['canalytiposorden'].label = "Punto de Venta"
        self.fields ['frmTiempoRefrescar'].label = "Minutos para Refrescar"
        
        self.fields ['canalytiposorden'].choices = PV_Choices

    class Meta:
        fields = ['fecha', 'canalytiposorden','frmTiempoRefrescar']

        labels = {'canalytiposorden':'Punto de Venta'
                  ,'fecha':'Fecha'
                  ,'frmTiempoRefrescar':'Minutos para Refrescar'
                  }

class Grafica2Form(forms.Form):
   
    fecha_inicial = forms.DateField(initial=datetime.now(), widget=forms.widgets.DateInput(
                        attrs={'type': 'date','placeholder':'yyyy-mm-dd','onchange': 'grafica1form.submit();'
                    }));
    
    fecha_final = forms.DateField(initial=datetime.now(), widget=forms.widgets.DateInput(
                    attrs={'type': 'date','placeholder':'yyyy-mm-dd','onchange': 'grafica1form.submit();'
                  }));

         # this function will be used for the validation
    def clean(self): 
        # data from the form is fetched using super function
        super(Grafica2Form, self).clean()

        frm_datefechainicial = self.cleaned_data.get('fecha_inicial')
        frm_datefechafinal   = self.cleaned_data.get('fecha_final')
        
        intfechainicial = date_to_integer(frm_datefechainicial)
        intfechafinal = date_to_integer(frm_datefechafinal)
        
        if(intfechafinal < intfechainicial):
            self._errors['fecha_final'] = self.error_class([
                'La fecha inicial debe ser menor o igual a la final'])
        
        # return any errors if found
        return self.cleaned_data
   
    class Meta:
        fields = ['fecha_inicial','fecha_final']

        labels = {'fecha_inicial':'Fecha Inicial',
                  'fecha_final':'Fecha Final'}

class Grafica3Form(forms.Form):
   
    fecha_inicial = forms.DateField(initial=datetime.now(), widget=forms.widgets.DateInput(
                        attrs={'type': 'date','placeholder':'yyyy-mm-dd','onchange': 'grafica1form.submit();'
                    }));
    
    fecha_final = forms.DateField(initial=datetime.now(), widget=forms.widgets.DateInput(
                    attrs={'type': 'date','placeholder':'yyyy-mm-dd','onchange': 'grafica1form.submit();'
                  }));

    frmTiempoRefrescar = forms.ChoiceField(initial = 5*60, choices=WAIT_CHOICES
                                           ,widget=forms.Select(attrs={'onchange': 'grafica1form.submit();'}))


         # this function will be used for the validation
    def clean(self): 
        # data from the form is fetched using super function
        super(Grafica3Form, self).clean()

        frm_datefechainicial = self.cleaned_data.get('fecha_inicial')
        frm_datefechafinal   = self.cleaned_data.get('fecha_final')
        
        intfechainicial = date_to_integer(frm_datefechainicial)
        intfechafinal = date_to_integer(frm_datefechafinal)
        
        if(intfechafinal < intfechainicial):
            self._errors['fecha_final'] = self.error_class([
                'La fecha inicial debe ser menor o igual a la final'])
        
        # return any errors if found
        return self.cleaned_data
   
    def __init__(self, *args, **kwargs):
        super(Grafica3Form,self).__init__(*args, **kwargs)
        self.fields ['frmTiempoRefrescar'].label = "Minutos para Refrescar"
        
    class Meta:
        fields = ['fecha_inicial','fecha_final','frmTiempoRefrescar']

        labels = {'fecha_inicial':'Fecha Inicial',
                  'fecha_final':'Fecha Final'
                  ,'frmTiempoRefrescar':'Minutos para Refrescar'}

class LocationlatencyForm(ModelForm):

    statecode = forms.ChoiceField(choices=USA_Choices
                                             ,widget=forms.Select(attrs={'onchange': 'grafica1form.submit();'}))

    def __init__(self, *args, **kwargs):
        super(LocationlatencyForm,self).__init__(*args, **kwargs)
        self.fields ['statecode'].label = "USA State"

    class Meta:
        model = Locationlatency
        fields = ['location','latency','statecode']
        labels = {'location':'Location','latency':'Latency','statecode': 'USA State',}
    
    # this function will be used for the validation
    def clean(self):
 
        # data from the form is fetched using super function
        super(LocationlatencyForm, self).clean()         
        
        frm_location= self.cleaned_data.get('location')
        
        try:
            sc = Locationlatency.objects.get(location = frm_location)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe un registro con esta locacion")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Locationlatency.DoesNotExist:
            pass

        # return any errors if found
        return self.cleaned_data

class StaticparamsForm(ModelForm):

    modulo = forms.ChoiceField(choices=MOD_Choices
                                             ,widget=forms.Select(attrs={'onchange': 'grafica1form.submit();'}))

    def __init__(self, *args, **kwargs):
        super(StaticparamsForm,self).__init__(*args, **kwargs)
        self.fields ['modulo'].label = "Modulo"

    class Meta:
        model = Staticparams
        fields = ['modulo','nombre','tipoparametro','valstr','valint']
        labels = {'modulo':'Modulo','nombre':'Nombre','tipoparametro':'Tipo','valstr':'Valor en Letras','valint':'Valor Numerico',}
    
    # this function will be used for the validation
    def clean(self):
 
        # data from the form is fetched using super function
        super(StaticparamsForm, self).clean()         
        
        frm_modulo= self.cleaned_data.get('modulo')
        frm_nombre= self.cleaned_data.get('nombre')
        frm_tipoparametro= self.cleaned_data.get('tipoparametro')
        frm_valstr= self.cleaned_data.get('valstr')
        frm_valint= self.cleaned_data.get('valint')

        if(frm_tipoparametro == 'INT' and  frm_valstr and frm_valstr != 'None'):
            self._errors['valstr'] = self.error_class([
                'No llenar este campo cuando el tipo es numérico'])

        if (frm_tipoparametro == 'INT' and  (not frm_valint or frm_valint == 'None')):
            self._errors['valint'] = self.error_class([
                'Valor requerido cuando el tipo es numérico'])

        if(frm_tipoparametro == 'STR' and  frm_valint and frm_valint != 'None'):
            self._errors['valint'] = self.error_class([
                'No llenar este campo cuando el tipo letras'])
        
        if(frm_tipoparametro == 'STR' and  (not frm_valstr or frm_valstr == 'None')):
            self._errors['valstr'] = self.error_class([
                'Valor requerido campo cuando el tipo es letras'])

        try:
            sc = Staticparams.objects.get(modulo = frm_modulo, nombre = frm_nombre)
            if not self.instance.pk:
                raise forms.ValidationError("Ya existe un registro con ese modulo y nombre")
            elif self.instance.pk != sc.pk:
                raise forms.ValidationError("Cambio coincide con otro registro")

        except Staticparams.DoesNotExist:
            pass

        # return any errors if found
        return self.cleaned_data