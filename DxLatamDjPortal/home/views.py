from django.shortcuts import render
from django.http import HttpRequest
from django.shortcuts import redirect
from django.contrib.auth.decorators import login_required
from datetime import datetime, time
import datetime as dt
from .forms import ContactoForm,ListaContactoForm,MensajeForm,ChkpointForm,DetChkpointForm,CategoryForm,Grafica1Form, Grafica2Form, Grafica3Form,LocationlatencyForm,StaticparamsForm
from .models import Alecontactos, Alelistacontacto, Alemensaje,Alechkpoint,Altchkpoint, Category,Altchkpoint,Alebitacora,Reporteinconsistenciascarrier,Promedioservicio,Amazonlate,Resumeninsightlate,RepDiffquantity,Latestshipdate
from .models import Locationlatency,Staticparams,BitacoraDecambios,Latestshipdatesku,LsDiasxcantidad,LsDiasxmonto
from django.contrib import messages
from .filters import AltchkpointFilter,AlebitacoraFilter,RequestedVsActualFilter,RepPromedioServicioFilter,AmazonlateFilter,RepListingMismatchFilter,LatestshipdateFilter, RepBitacoraDecambiosFilter,RepLatestshipdateskuFilter
from django.core.paginator import Paginator
from django.db import connections
import simplejson as json

from django.utils import timezone
from .fields import id_LC001,id_MN001,id_CP001,datestr_to_integer,hourstr_to_integer,PV_Category,last_day_of_month,DatetimeEncoder
from django.utils.dateparse import parse_date

from .seguridad import active_user_required
# Method check to see if User has permissions to add Store model
from django.contrib.auth.decorators import permission_required
from django.db.models import Count,Sum,F
from django.core import serializers
from django.db.models.functions import Cast,ExtractDay,ExtractMonth,Concat
from django.db.models import CharField,Value,FloatField,Case, When
######################################################################################################
##   CATEGORY
######################################################################################################
def RecorreHijos(IdPadre,prCategory_list):
    # Retrieve all contacts in the database table
   Parent_list = tuple(Category.objects.all().values('id','code','title','parent').filter(parent = IdPadre))
   
   for Parent in Parent_list:
       
       if Parent['parent'] != None:
            resNombre = Category.objects.all().values('title').filter(id = Parent['parent'])
            Parent['ParentName'] = resNombre[0]['title'] 
       else:
            Parent['ParentName'] ="Ninguno"

       prCategory_list.append(Parent)
       RecorreHijos(Parent['id'],prCategory_list)          
   
   return 1

@login_required (login_url='login')
@permission_required('home.view_category',login_url='home')
def searchCategory(request): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   Category_list = []

   IdPadre = None
   RecorreHijos(IdPadre,Category_list)

   page = request.GET.get('page', 1)
   paginator = Paginator(Category_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'home/SearchCategory.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento de Categorías',
         'year':datetime.now().year, 
         'Category_list': _filter2 , # Embed data into the HttpResponse object
         'filter2': _filter2,
      }
   )

@login_required (login_url='login')
@permission_required('home.delete_category',login_url='home')
def deleteCategory(request,pr_Id): 
    instancia = Category.objects.get(pk = pr_Id)
    instancia.delete()
    return redirect('searchCategory') 

@login_required (login_url='login')
@permission_required('home.change_category',login_url='home')
def editCategory(request,pr_Id):
    # Creamos un formulario vacío
    form = CategoryForm()

    # Recuperamos la instancia de la persona
    instancia = Category.objects.get(pk = pr_Id)

    # Creamos el formulario con los datos de la instancia
    form = CategoryForm(instance=instancia)

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        action = request.POST.get('action')        
        form = CategoryForm(request.POST, instance=instancia)

        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)
            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            #return redirect('searchContacto')
            messages.add_message(request, messages.INFO, 'Operación %s realizada' % action)

            return redirect('searchCategory') 

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditCategory.html", {
        'title':'Modulo de Alertas', 
         'message':'Editar Categoría',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.add_category',login_url='home')
def addCategory(request):
    # Creamos un formulario vacío
    form = CategoryForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":

        action = request.POST.get('action')
        form = CategoryForm(request.POST)

        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)
            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            #return redirect('searchContacto')
            messages.add_message(request, messages.INFO, 'Operación %s realizada' % action)

            return redirect('searchCategory') 

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddCategory.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar Categoría',
         'year':datetime.now().year, 
         'form': form})

######################################################################################################
##   CONTACTO
######################################################################################################
@login_required (login_url='login')
@permission_required('home.delete_alecontactos',login_url='home')
def deleteContacto(request, pr_IdRegistro):
    # Recuperamos la instancia de la persona
    instancia = Alecontactos.objects.get(idregistro=pr_IdRegistro)

    instancia.delete()

    return redirect('searchContacto') 

@login_required (login_url='login')
@permission_required('home.change_alecontactos',login_url='home')
def editContacto(request, pr_IdRegistro):
    
     # Recuperamos la instancia de la persona
    instancia = Alecontactos.objects.get(idregistro=pr_IdRegistro)

    # Creamos el formulario con los datos de la instancia
    form = ContactoForm(instance=instancia)

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = ContactoForm(request.POST, instance=instancia)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.fechamodificacion = int(timezone.now().strftime("%Y%m%d"))
            instancia.horamodifcacion = int(timezone.now().strftime("%H%M%S"))

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchContacto')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditContacto.html", {
        'title':'Modulo de Alertas', 
         'message':'Editar Contacto',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.add_alecontactos',login_url='home')
def addContacto(request):
    # Creamos un formulario vacío
    form = ContactoForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = ContactoForm(request.POST)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.fechacreacion = int(timezone.now().strftime("%Y%m%d"))
            instancia.horacreacion  = int(timezone.now().strftime("%H%M%S"))

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchContacto')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddContacto.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar Contacto',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.view_alecontactos',login_url='home')
def searchContacto(request): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   ALECONTACTOS_list = Alecontactos.objects.order_by('nombrecompleto').filter(estadologico = 0) 

   page = request.GET.get('page', 1)
   paginator = Paginator(ALECONTACTOS_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'home/SearchContacto.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento de Contactos',
         'year':datetime.now().year, 
         'ALECONTACTOS_list': _filter2, # Embed data into the HttpResponse object
         'filter2': _filter2,
      }
   )

######################################################################################################
##   LISTA CONTACTO
######################################################################################################
@login_required (login_url='login')
@permission_required('home.view_alelistacontacto',login_url='home')
def searchListaContacto(request): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   LISTACONTACTOS_list = Alelistacontacto.objects.order_by('idlista').filter(estadologico = 0)
  
   page = request.GET.get('page', 1)
   paginator = Paginator(LISTACONTACTOS_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'home/SearchListaContacto.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento de Listas de Contactos',
         'year':datetime.now().year, 
         'LISTACONTACTOS_list': _filter2, # Embed data into the HttpResponse object
         'filter2':_filter2
      }
   )

@login_required (login_url='login')
@permission_required('home.add_alelistacontacto',login_url='home')
def addListaContacto(request):
    # Creamos un formulario vacío
    form = ListaContactoForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = ListaContactoForm(request.POST)
        # Si el formulario es válido...
        if form.is_valid():           
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.fechacreacion = int(timezone.now().strftime("%Y%m%d"))
            instancia.horacreacion  = int(timezone.now().strftime("%H%M%S"))

            #Actualizando con el valor de la llave y no con la descripción
            instancia.idlista = form.cleaned_data['idlista']

            vid_LC001 = id_LC001()
            DescIdLista = Category.objects.values_list('title', flat=True).filter(parent_id = vid_LC001[0] , code = instancia.idlista)
            if(DescIdLista.count() > 0):
                instancia.descripcion = DescIdLista[0];
            
            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchListaContacto')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddListaContacto.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar Contacto una Lista',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.change_alelistacontacto',login_url='home')
def editListaContacto(request, pr_IdRegistro):
    
     # Recuperamos la instancia de la persona
    instancia = Alelistacontacto.objects.get(idregistro= pr_IdRegistro)

    # Creamos el formulario con los datos de la instancia
    form = ListaContactoForm(instance=instancia)

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = ListaContactoForm(request.POST, instance=instancia)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.fechamodificacion = int(timezone.now().strftime("%Y%m%d"))
            instancia.horamodifcacion = int(timezone.now().strftime("%H%M%S"))

            vid_LC001 = id_LC001()
            DescIdLista = Category.objects.values_list('title', flat=True).filter(parent_id = vid_LC001[0] , code = instancia.idlista)
            if(DescIdLista.count() > 0):
                instancia.descripcion = DescIdLista[0];

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchListaContacto')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditListaContacto.html", {
        'title':'Modulo de Alertas', 
         'message':'Editar Contacto de una Lista',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.delete_alelistacontacto',login_url='home')
def deleteListaContacto(request, pr_IdRegistro):
    # Recuperamos la instancia de la persona
    instancia = Alelistacontacto.objects.get(idregistro= pr_IdRegistro)

    instancia.delete()

    return redirect('searchListaContacto') 

######################################################################################################
##   MENSAJE
######################################################################################################
@login_required (login_url='login')
@permission_required('home.view_alemensaje',login_url='home')
def searchMensaje(request): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   MENSAJE_list = Alemensaje.objects.order_by('idmensaje').filter(estadologico = 0) 

   page = request.GET.get('page', 1)
   paginator = Paginator(MENSAJE_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'home/SearchMensaje.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento de Mensajes',
         'year':datetime.now().year, 
         'MENSAJE_list': _filter2, # Embed data into the HttpResponse object
         'filter2':_filter2,
      }
   )

@login_required (login_url='login')
@permission_required('home.add_alemensaje',login_url='home')
def addMensaje(request):
    # Creamos un formulario vacío
    form = MensajeForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = MensajeForm(request.POST)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.fechacreacion = int(timezone.now().strftime("%Y%m%d"))
            instancia.horacreacion  = int(timezone.now().strftime("%H%M%S"))

            vid_MN001 = id_MN001()
            DescIdLista = Category.objects.values_list('title', flat=True).filter(parent_id = vid_MN001[0] , code = instancia.idmensaje)
            if(DescIdLista.count() > 0):
                instancia.subject = DescIdLista[0];

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchMensaje')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddMensaje.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar Mensaje',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.change_alemensaje',login_url='home')
def editMensaje(request, pr_IdRegistro):
    
     # Recuperamos la instancia de la persona
    instancia = Alemensaje.objects.get(idregistro= pr_IdRegistro)

    # Creamos el formulario con los datos de la instancia
    form = MensajeForm(instance=instancia)

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = MensajeForm(request.POST, instance=instancia)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.fechamodificacion = int(timezone.now().strftime("%Y%m%d"))
            instancia.horamodifcacion = int(timezone.now().strftime("%H%M%S"))

            vid_MN001 = id_MN001()
            DescIdLista = Category.objects.values_list('title', flat=True).filter(parent_id = vid_MN001[0] , code = instancia.idmensaje)
            if(DescIdLista.count() > 0):
                instancia.subject = DescIdLista[0];

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchMensaje')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditMensaje.html", {
        'title':'Modulo de Alertas', 
         'message':'Editar Mensaje',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.delete_alemensaje',login_url='home')
def deleteMensaje(request, pr_IdRegistro):
    # Recuperamos la instancia de la persona
    instancia = Alemensaje.objects.get(idregistro= pr_IdRegistro)

    instancia.delete()

    return redirect('searchMensaje') 

######################################################################################################
##   CHECK POINT - MAESTRO
######################################################################################################
@login_required (login_url='login')
@permission_required('home.view_alechkpoint',login_url='home')
def searchChkPoint(request): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   ChkPoint_list = Alechkpoint.objects.order_by('idchkpoint').filter(estadologico = 0) 

   page = request.GET.get('page', 1)
   paginator = Paginator(ChkPoint_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'home/SearchChkpoint.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento de Puntos de Validación',
         'year':datetime.now().year, 
         'ChkPoint_list': _filter2, # Embed data into the HttpResponse object
         'filter2':_filter2
      }
   )

@login_required (login_url='login')
@permission_required('home.add_alechkpoint',login_url='home')
def addChkPoint(request):
    # Creamos un formulario vacío
    form = ChkpointForm()
    
    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = ChkpointForm(request.POST)
        frm_FechaVigencia = request.POST.get('datefechavigencia')
        frm_fmtHoraInicial = request.POST.get('fmthorainicial')        
        frm_fmtHoraFinal   = request.POST.get('fmthorafinal')        
      
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            vid_CP001 = id_CP001()
            DescIdLista = Category.objects.values_list('title', flat=True).filter(parent_id = vid_CP001[0] , code = instancia.idchkpoint)
            if(DescIdLista.count() > 0):
                instancia.descripicion = DescIdLista[0];

            instancia.fechavigencia = datestr_to_integer(frm_FechaVigencia) 
            instancia.horainicial   = hourstr_to_integer(frm_fmtHoraInicial)
            instancia.horafinal     = hourstr_to_integer(frm_fmtHoraFinal)

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchChkPoint')
    
    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddChkpoint.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar punto de validación',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.change_alechkpoint',login_url='home')
def editChkPoint(request, pr_IdRegistro):
    
     # Recuperamos la instancia de la persona
    instancia = Alechkpoint.objects.get(idregistro= pr_IdRegistro)

    # Creamos el formulario con los datos de la instancia
    form =ChkpointForm(instance=instancia)
   
    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = ChkpointForm(request.POST, instance=instancia)

        frm_FechaVigencia = request.POST.get('datefechavigencia')        
        frm_fmtHoraInicial = request.POST.get('fmthorainicial')        
        frm_fmtHoraFinal   = request.POST.get('fmthorafinal')        

        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)
            
            vid_CP001 = id_CP001()
            DescIdLista = Category.objects.values_list('title', flat=True).filter(parent_id = vid_CP001[0] , code = instancia.idchkpoint)
            if(DescIdLista.count() > 0):
                instancia.descripicion = DescIdLista[0];

            instancia.fechavigencia = datestr_to_integer(frm_FechaVigencia) 
            instancia.horainicial   = hourstr_to_integer(frm_fmtHoraInicial)
            instancia.horafinal     = hourstr_to_integer(frm_fmtHoraFinal)

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchChkPoint')

    else :
            frm_FechaVigencia  = instancia.fechavigencia #request.GET.get('fechavigencia')
            frm_HoraInicial    = instancia.horainicial   #request.GET.get('horainicial')        
            frm_HoraFinal      = instancia.horafinal     #request.GET.get('horafinal')        

            Anio = int(frm_FechaVigencia/10000)
            Mes  = int((frm_FechaVigencia%10000)/100)
            Dia  = int(frm_FechaVigencia%100)
            datefechavigencia = dt.date( Anio,Mes,Dia)#.strftime("%Y%m%d");
            form.fields ['datefechavigencia'].initial =datefechavigencia 

            Hora   = int(frm_HoraInicial/100)
            Minuto = int(frm_HoraInicial%100)        
            fmtHoraInicial= dt.time(hour=Hora) #[(dt.time(hour=Hora), '{:02d}:00'.format(Hora)) ]
            form.fields ['fmthorainicial'].initial = fmtHoraInicial
        
            Hora   = int(frm_HoraFinal/100)
            Minuto = int(frm_HoraFinal%100)
            fmtHoraFinal = dt.time(hour=Hora, minute =Minuto) #[(dt.time(hour=Hora), '{:02d}:59'.format(Hora)) ]
            form.fields ['fmthorafinal'].initial = fmtHoraFinal
    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditChkpoint.html", {
        'title':'Modulo de Alertas', 
         'message':'Editar punto de validación',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.delete_alechkpoint',login_url='home')
def deleteChkPoint(request, pr_IdRegistro):
    # Recuperamos la instancia de la persona
    instancia = Alechkpoint.objects.get(idregistro= pr_IdRegistro)

    instancia.delete()

    return redirect('searchChkPoint') 

######################################################################################################
##   CHECK POINT - DETALLE
######################################################################################################
@login_required (login_url='login')
@permission_required('home.view_altchkpoint',login_url='home')
def searchDetChkPoint(request): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   DetChkPoint_list = Altchkpoint.objects.order_by('idchkpoint').filter(estadologico = 0) 

   return render(
      request, 
      'home/SearchDetChkpoint.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento del Detalle de Puntos de Validación',
         'year':datetime.now().year, 
         'DetChkPoint_list': DetChkPoint_list, # Embed data into the HttpResponse object
      }
   )

@login_required (login_url='login')
@permission_required('home.add_altchkpoint',login_url='home')
def addDetChkPoint(request):
    # Creamos un formulario vacío
    form = DetChkpointForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = DetChkpointForm(request.POST)

        frm_datefechainicial = request.POST.get('datefechainicial')
        frm_datefechafinal = request.POST.get('datefechafinal')
        frm_toleranciainferior = request.POST.get('INTtoleranciainferior')
        frm_toleranciasuperior = request.POST.get('INTtoleranciasuperior')

        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.toleranciainferior = int(frm_toleranciainferior)/100
            instancia.toleranciasuperior = int(frm_toleranciasuperior)/100

            if(frm_datefechainicial and frm_datefechainicial != None):
                instancia.fechainicial = datestr_to_integer(frm_datefechainicial) 
            else:
                instancia.fechainicial = 0

            if(frm_datefechafinal and frm_datefechafinal != None):
                instancia.fechafinal = datestr_to_integer(frm_datefechafinal) 
            else:
                instancia.fechafinal = 0

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('filterDetChkPoint')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddDetChkpoint.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar Detalle a punto de validación',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.change_altchkpoint',login_url='home')
def editDetChkPoint(request, pr_IdRegistro):
    
     # Recuperamos la instancia de la persona
    instancia = Altchkpoint.objects.get(idregistro= pr_IdRegistro)

    # Creamos el formulario con los datos de la instancia
    form =DetChkpointForm(instance=instancia)

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = DetChkpointForm(request.POST, instance=instancia)

        frm_datefechainicial = request.POST.get('datefechainicial')
        frm_datefechafinal = request.POST.get('datefechafinal')        
        frm_toleranciainferior = request.POST.get('INTtoleranciainferior')
        frm_toleranciasuperior = request.POST.get('INTtoleranciasuperior')

        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            instancia.toleranciainferior = int(frm_toleranciainferior)/100
            instancia.toleranciasuperior = int(frm_toleranciasuperior)/100

            if(frm_datefechainicial and frm_datefechainicial != None):
                instancia.fechainicial = datestr_to_integer(frm_datefechainicial) 
            else:
                instancia.fechainicial = 0

            if(frm_datefechafinal and frm_datefechafinal != None):
                instancia.fechafinal = datestr_to_integer(frm_datefechafinal) 
            else:
                instancia.fechafinal = 0

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('filterDetChkPoint')
    else:
            frm_datefechainicial = instancia.fechainicial 
            frm_datefechafinal = instancia.fechafinal 

            #Existe un inconveniente con la lista de elección cuando difiere el caractér del punto decimal
            #po eso se usa el valor entero para interactual con el usuario.
            form.fields ['INTtoleranciainferior'].initial = int(instancia.toleranciainferior *100)
            form.fields ['INTtoleranciasuperior'].initial = int(instancia.toleranciasuperior *100)

            if(frm_datefechainicial and frm_datefechainicial!=None and frm_datefechainicial >0):
                Anio = int(frm_datefechainicial/10000)
                Mes  = int((frm_datefechainicial%10000)/100)
                Dia  = int(frm_datefechainicial%100)
                datefecha = dt.date( Anio,Mes,Dia)
                form.fields ['datefechainicial'].initial =datefecha 
            else:
                form.fields ['datefechainicial'].initial =None;

            if(frm_datefechafinal and frm_datefechafinal!=None and frm_datefechafinal >0):
                Anio = int(frm_datefechafinal/10000)
                Mes  = int((frm_datefechafinal%10000)/100)
                Dia  = int(frm_datefechafinal%100)
                datefecha = dt.date( Anio,Mes,Dia)
                form.fields ['datefechafinal'].initial =datefecha 
            else:
                form.fields ['datefechafinal'].initial =None;

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditDetChkpoint.html", {
        'title':'Modulo de Alertas', 
         'message':'Editar Detalle de punto de validación',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.delete_altchkpoint',login_url='home')
def deleteDetChkPoint(request, pr_IdRegistro):
    # Recuperamos la instancia de la persona
    instancia = Altchkpoint.objects.get(idregistro= pr_IdRegistro)

    instancia.delete()

    return redirect('filterDetChkPoint') 

@login_required (login_url='login')
@permission_required('home.view_altchkpoint',login_url='home')
def filterDetChkPoint(request):
    detchkpoint_list = Altchkpoint.objects.all()
    detchkpoint_filter = AltchkpointFilter(request.GET, queryset=detchkpoint_list)
    
    #Manteniendo los parámetros del filtro en pantalla
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    page = request.GET.get('page', 1)
    paginator = Paginator(detchkpoint_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/DetChkPontFiltered.html'
                  , {'parameters':parameters,
                     'filter': detchkpoint_filter,
                     'filter2': _filter2,
                     'title':'Modulo de Alertas', 
                     'message':'Mantenimiento Detalle de Punto de Validación',
                     'year':datetime.now().year, })

######################################################################################################
##   DASHBOARD
######################################################################################################

# Create your views here.
@login_required (login_url='login')
@permission_required('home.graph_salesorders',login_url='home')
def dashboard(request):
    return redirect('Grafica1') 
    
# Create your views here.
@login_required (login_url='login')
def home(request):

    #if request.user and not request.user.is_superuser :
        #group = request.user.groups.filter(user=request.user)[0]
        #if group.name=="SalesOrders":
            #return redirect('Grafica1') 

    return render(request,'home/welcome.html',{   
        'title':'Modulo de Alertas', 
        'message':'Bienvenidos',
        'date_field':datetime.now()
        })

@login_required (login_url='login')
@permission_required('home.graph_salesorders',login_url='home')
def Grafica1(request):
    form = Grafica1Form();

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = Grafica1Form(request.POST)

        frmfecha = request.POST.get('fecha')
        prfecha = datestr_to_integer(frmfecha)
        prCanal = request.POST.get('canalytiposorden')
        query = None
        frm_TiempoRefrescar = int(request.POST.get('frmTiempoRefrescar'))

        # Si el formulario es válido...
        #if form.is_valid():

    else:
        #query = """SELECT date, Prediccion, ToleranciaInferior, ToleranciaSuperior, Cantidad REAL FROM [ChkPoint_CantidadVentas2] ('CANTORD', 20210201,'Amazon') order by Hora"""
        prfecha = int(datetime.now().strftime("%Y%m%d"))
        prCanal = 'Amazon'    
        #
        get_TiempoRefrescar = request.GET.get('TiempoRefrescar')
        if(get_TiempoRefrescar == None):
            frm_TiempoRefrescar = int(form.fields ['frmTiempoRefrescar'].initial);
        else:
            frm_TiempoRefrescar = int(request.GET.get('TiempoRefrescar'))


    Anio = int(prfecha/10000)
    Mes  = int((prfecha%10000)/100)
    Dia  = int(prfecha%100)
    datefecha = dt.date( Anio,Mes,Dia).strftime("%d-%m-%Y")

    try:
        cursor= connections['default'].cursor()
        keys = ('date','Prediccion','ToleranciaInferior','ToleranciaSuperior','REAL','Maximo','Minimo')

        cursor.execute("""SELECT date, Prediccion, ToleranciaInferior, ToleranciaSuperior, Cantidad REAL 
                       , CASE WHEN Deteccion = 'MAXIMO' then  Cantidad END Maximo
                       , CASE WHEN Deteccion = 'MINIMO' then  Cantidad END Minimo
                       FROM [ChkPoint_CantidadVentas2] ('CANTORD',%s,%s) order by Hora""",[prfecha,prCanal])    
        rows = cursor.fetchall()    
        result = []
        for row in rows:
            result.append(dict(zip(keys,row)))
            
        json_data = json.dumps(result, use_decimal=True).replace('null', '"none"')

        keys = ('category','cantidad')
        cursor.execute("""SELECT  Deteccion category, sum(Cantidad) cantidad FROM ( SELECT Deteccion, Cantidad FROM [ChkPoint_CantidadVentas2] ('CANTORD', %s,%s) UNION SELECT 'MAXIMO' Deteccion, 0 UNION	SELECT 'MINIMO' Deteccion, 0 UNION SELECT 'OK' Deteccion, 0 )X GROUP BY Deteccion """,[prfecha,prCanal])
        rows = cursor.fetchall()    
        result = []
        for row in rows:
            result.append(dict(zip(keys,row)))
            
        json_data2 = json.dumps(result, use_decimal=True)

        keys = ('category','OK','MAXIMO','MINIMO')
        cursor.execute("""SELECT category, ISNULL(OK,0) OK, ISNULL(MAXIMO,0) MAXIMO, ISNULL(MINIMO,0) MINIMO FROM (SELECT CanalyTiposOrden category, Deteccion, Cantidad FROM [ChkPoint_CantidadVentas2] ('CANTORD',%s,'')) AS SourceTable PIVOT(  SUM(Cantidad) FOR Deteccion IN ([OK], [MAXIMO], [MINIMO])) AS PivotTable""",[prfecha])
        rows = cursor.fetchall()    
        result = []
        for row in rows:
            result.append(dict(zip(keys,row)))
            
        json_data3 = json.dumps(result, use_decimal=True)

        keys = ('date', 'Variacion', 'varToleranciaInferior', 'varToleranciaSuperior' )
        cursor.execute("""SELECT date, Variacion,  varToleranciaInferior * -1 varToleranciaInferior, varToleranciaSuperior FROM [ChkPoint_CantidadVentas2] ('CANTORD', %s,%s) order by Hora""",[prfecha,prCanal])
        rows = cursor.fetchall()    
        result = []
        for row in rows:
            result.append(dict(zip(keys,row)))
            
        json_data4 = json.dumps(result, use_decimal=True)

        keys = ('date', 'Diferencia', 'DifMaxInf', 'DifMaxSup' )
        cursor.execute("""SELECT date, Diferencia, ValorDifMaximo DifMaxSup, ValorDifMinimo*-1 DifMaxInf FROM [ChkPoint_CantidadVentas2] ('CANTORD', %s,%s) order by Hora""",[prfecha,prCanal])
        rows = cursor.fetchall()    
        result = []
        for row in rows:
            result.append(dict(zip(keys,row)))
            
        json_data5 = json.dumps(result, use_decimal=True)


        keys = ('DiaMes','Fecha','OK','MAXIMO','MINIMO')
        cursor.execute("""SELECT DiaMes, Fecha, OK, ISNULL(MAXIMO,0) MAXIMO, ISNULL(MINIMO,0)MINIMO FROM (SELECT category, DiaMes, Fecha, Deteccion, Cantidad FROM [ChkPoint_CantidadVentasXMes]('CANTORD', %s,%s) ) AS SourceTable PIVOT(  SUM(Cantidad) FOR Deteccion IN ([OK], [MAXIMO], [MINIMO])) AS PivotTable ORDER BY Fecha""",[prfecha,prCanal])
        rows = cursor.fetchall()    
        result = []
        for row in rows:
            result.append(dict(zip(keys,row)))
            
        json_data6 = json.dumps(result, use_decimal=True)

    finally:
        cursor.close()
        
    return render(request, 'home/Grafica1.html', {        
        'TiempoRefrescar': frm_TiempoRefrescar,
        'data': json_data,
        'data2': json_data2,
        'data3': json_data3,
        'data4': json_data4,
        'data5': json_data5,
        'data6': json_data6,
        'form': form,
        'PuntoVenta':prCanal ,
        'fechaDet':datefecha ,
        'title':'Modulo de Alertas', 
        'message':'Dashboard',
        'year':datetime.now().year,
    })

@login_required (login_url='login')
@permission_required('home.graph_shipping',login_url='home')
def Grafica2(request):
    form = Grafica2Form();
 
    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = Grafica2Form(request.POST)
        if form.is_valid():
            prfechastr  = request.POST.get('fecha_inicial')        
            prfecha_inicial = parse_date(prfechastr)

            prfechastr  = request.POST.get('fecha_final')        
            prfecha_final = parse_date(prfechastr)            
        else:
             return render(request, 'home/Grafica2.html', {        
                'form': form,        
                'title':'Modulo de Alertas', 
                'message':'Shipping Dashboard',
                'year':datetime.now().year,
            })
    else:        
        prfecha_inicial = datetime.now()
        prfecha_final = datetime.now()

    try:

        prfecha_inicial = datetime.combine(prfecha_inicial, time.min)
        prfecha_final = datetime.combine(prfecha_final, time.max)

        cursor= connections['default'].cursor()
        keys = ('category','Walmart', 'Quokka', 'Shopify','eBay','Amazon','Google_Shopping','Etail'
                )

        cursor.execute(""" SELECT category, ISNULL(Walmart,0) Walmart, ISNULL(Quokka,0) Quokka, ISNULL(Shopify,0) Shopify 
               , ISNULL(eBay,0) eBay, ISNULL(Amazon,0) Amazon, ISNULL(Google_Shopping,0) Google_Shopping 
               , ISNULL(Etail,0)Etail FROM (select Channel, CASE WHEN UltimaExcepcion IS NULL OR UltimaExcepcion = '' THEN 'NINGUNA' ELSE UltimaExcepcion END category
               , count(*) cantidad from AMAZONLATE (nolock) WHERE FechaIngreso BETWEEN %s AND %s
               group by Channel, UltimaExcepcion 
               ) AS SourceTable PIVOT(SUM(cantidad) FOR Channel IN ([Walmart], [Quokka], [Shopify],[eBay],[Amazon],[Google_Shopping],[Etail])) AS PivotTable 
        """,[prfecha_inicial, prfecha_final])    
        rows = cursor.fetchall()    
        result = []
        for row in rows:
            result.append(dict(zip(keys,row)))
            
        json_data = json.dumps(result, use_decimal=True).replace('null', '"none"')      

        
    finally:
        cursor.close()

    Excepciones = PV_Category();#Amazonlate.objects.values('ultimaexcepcion').annotate(Count('id'))        
          
    qs = Amazonlate.objects.values('ultimaexcepcion').filter(
        channel = 'Amazon',
        ultimaexcepcion__isnull=False,
        fechaingreso__range = [datetime.combine(prfecha_inicial, time.min),
                               datetime.combine(prfecha_final, time.max)]).annotate(            
            cantidad=Count('*')
        )

    json_Amazon = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    qs = Amazonlate.objects.values('ultimaexcepcion').filter(
        channel = 'eBay',
        ultimaexcepcion__isnull=False,
        fechaingreso__range = [datetime.combine(prfecha_inicial, time.min),
                               datetime.combine(prfecha_final, time.max)]).annotate(            
            cantidad=Count('*')
        )

    json_eBay = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    qs = Amazonlate.objects.values('ultimaexcepcion').filter(
        channel = 'Shopify',
        ultimaexcepcion__isnull=False,
        fechaingreso__range = [datetime.combine(prfecha_inicial, time.min),
                               datetime.combine(prfecha_final, time.max)]).annotate(            
            cantidad=Count('*')
        )

    json_Shopify = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    qs = Amazonlate.objects.values('ultimaexcepcion').filter(
        channel = 'Walmart',
        ultimaexcepcion__isnull=False,
        fechaingreso__range = [datetime.combine(prfecha_inicial, time.min),
                               datetime.combine(prfecha_final, time.max)]).annotate(            
            cantidad=Count('*')
        )
    json_Walmart = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    qs = Amazonlate.objects.values('ultimaexcepcion').filter(
        channel = 'Google_Shopping',
        ultimaexcepcion__isnull=False,
        fechaingreso__range = [datetime.combine(prfecha_inicial, time.min),
                               datetime.combine(prfecha_final, time.max)]).annotate(            
            cantidad=Count('*')
        )
    json_Google_Shopping = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    qs = Resumeninsightlate.objects.values('channel'
              ).filter(
                    tarde__gte = 1,
                    fechaingreso__range = [datetime.combine(prfecha_inicial, time.min),
                               datetime.combine(prfecha_final, time.max)],                              
              ).annotate(
                      sum_total=Sum('total')
                     ,sum_tarde=Sum('tarde')
                     ,sum_entiempo = Sum(F('total') - F('tarde'))
                    # ,sum_porcentarde = sum(F('tarde') / F('total'))
              )

    Resumeninsightlate_json = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    prfechaM_inicial = datetime(prfecha_inicial.year,prfecha_inicial.month, 1)
    prfechaM_final = last_day_of_month(prfecha_inicial)

    qs = Resumeninsightlate.objects.values('fechaingreso').filter(
        fechaingreso__range = [datetime.combine(prfechaM_inicial, time.min),
                               datetime.combine(prfechaM_final, time.max)]).annotate(            
            day=Cast(ExtractDay('fechaingreso'), CharField()),
            month=Cast(ExtractMonth('fechaingreso'), CharField()),
            str_fechaingreso=Concat(
                'day',Value('-'), 'month',
                output_field=CharField()
            )
            ,sum_total=Sum('total')
            ,sum_tarde=Sum('tarde')
            ,sum_entiempo = Sum(F('total') - F('tarde'))
        )
    
    Resumeninsightlate_json2 = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    qs = Amazonlate.objects.values('fulfillmentlocationname').filter(
        fechaingreso__range = [datetime.combine(prfecha_inicial, time.min),
                               datetime.combine(prfecha_final, time.max)]).annotate(            
            cantidad=Count('*')
        )

    #Resumeninsightlate_json = serializers.serialize('json', qs)                                                     
    Amazonlate_json = json.dumps(list(qs), cls=DatetimeEncoder).replace('null', '"none"')

    return render(request, 'home/Grafica2.html', {        
        'Excepciones' : Excepciones,
        'data': json_data,
        'json_Amazon': json_Amazon,
        'json_eBay': json_eBay,
        'json_Shopify': json_Shopify,
        'json_Walmart': json_Walmart,
        'json_Google_Shopping':json_Google_Shopping,
        'resResumeninsightlate':Resumeninsightlate_json,
        'resResumeninsightlate2':Resumeninsightlate_json2,
        'Amazonlate_json':Amazonlate_json,
        'form': form,        
        'prfecha_inicial':prfecha_inicial ,
        'prfecha_final':prfecha_final ,
        'title':'Modulo de Alertas', 
        'message':'Shipping Dashboard',
        'year':datetime.now().year,
    })


######################################################################################################
##   REPORTES DE SHIPPING
######################################################################################################
from django.http import HttpResponse
import csv

@login_required (login_url='login')
@permission_required('home.reports_alerts',login_url='home')
def csvRepDetalleMensajes(request):

    template_name = 'home/RepMensajesEnviados.html'
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()
    get_Var = request.GET.get('criterio')

    det_list = Alebitacora.objects.filter(estadologico = 0).order_by('-idregistro')    

    det_filter = AlebitacoraFilter(request.GET, queryset=det_list).qs

    filename = "{}-DetalleMensajes.csv".format(datetime.now().strftime("%Y%m%d_%H%M%S"))

    response = HttpResponse(
        content_type='text/csv',            
    )        
    response['Content-Disposition'] = 'attachment; filename="{}"'.format(filename)

    writer = csv.writer(response)
    writer.writerow(('idmensaje', 'criterio', 'idlista','estado' ,                   
            'fecha','hora',
            'idcontacto','mensaje'))
    
    for row in det_filter:
        writer.writerow((
            row.idmensaje   ,row.criterio   , row.idlista    ,row.estado,
            row.fecha       ,row.hora       , row.idcontacto ,row.mensaje
            ))
        
    return response

@login_required (login_url='login')
@permission_required('home.reports_alerts',login_url='home')
def RepDetalleMensajes(request):
    det_list = Alebitacora.objects.filter(estadologico = 0).order_by('-idregistro') 
    det_filter = AlebitacoraFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)

    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/RepMensajesEnviados.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte Mensajes Enviados',
                        'year':datetime.now().year, })

@login_required (login_url='login')
@permission_required('home.reports_shipping',login_url='home')
def csvRepReqVsActual(request):
    #Generando informació para archivo csv
    det_list = Reporteinconsistenciascarrier.objects.all()
    det_filter = RequestedVsActualFilter(request.POST, queryset=det_list)

    filename = "{}-RepReqVsActual.csv".format(datetime.now().strftime("%Y%m%d_%H%M%S"))

    response = HttpResponse(
        content_type='text/csv',            
    )        
    response['Content-Disposition'] = 'attachment; filename="{}"'.format(filename)

    writer = csv.writer(response)
    writer.writerow(('salesordernumber', 'requestedservicelevel', 'proship_service_plaintext','billedweight' ,                   
            'cambioservicio','fechainsercion',))
    for row in det_filter.qs:
        writer.writerow((
            row.salesordernumber   ,row.requestedservicelevel   , row.proship_service_plaintext    ,row.billedweight,
            row.cambioservicio       ,row.fechainsercion
            ))

    return response

@login_required (login_url='login')
@permission_required('home.reports_shipping',login_url='home')
def RepReqVsActual(request):
    det_list = Reporteinconsistenciascarrier.objects.all()
    det_filter = RequestedVsActualFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    #Manejo de pagineo
    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/RepReqVsActual.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte Requested vs Actual',
                        'year':datetime.now().year, 
                        })

@login_required (login_url='login')
@permission_required('home.reports_shipping',login_url='home')
def RepPromedioServicio(request):
    det_list = Promedioservicio.objects.all().order_by('fechaingreso','id')
    det_filter =RepPromedioServicioFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    #Manejo de pagineo
    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/RepPromedioServicio.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte Promedio Servicio',
                        'year':datetime.now().year, 
                        })

@login_required (login_url='login')
@permission_required('home.reports_shipping',login_url='home')
def RepAmazonlate(request):
    det_list = Amazonlate.objects.all().order_by('fechaingreso','id')
    det_filter =AmazonlateFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    #Manejo de pagineo
    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/RepAmazonlate.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte Late',
                        'year':datetime.now().year, 
                        })

######################################################################################################
##   Latest Shipdate
######################################################################################################
@login_required (login_url='login')
@permission_required('home.view_locationlatency',login_url='home')
def searchLocationLatency(request): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   Locationlatency_list = Locationlatency.objects.order_by('statecode')

   page = request.GET.get('page', 1)
   paginator = Paginator(Locationlatency_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'home/SearchLocationlatency.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento de Latencia por Ubicacion',
         'year':datetime.now().year, 
         'Locationlatency_list': _filter2, # Embed data into the HttpResponse object
         'filter2': _filter2,
      }
   )

@login_required (login_url='login')
@permission_required('home.delete_locationlatency',login_url='home')
def deleteLocationLatency(request, pr_Id):
    # Recuperamos la instancia de la persona
    instancia = Locationlatency.objects.get(id=pr_Id)

    instancia.delete()
    return redirect('searchLocationLatency') 

@login_required (login_url='login')
@permission_required('home.add_locationlatency',login_url='home')
def addLocationLatency(request):
    # Creamos un formulario vacío
    form = LocationlatencyForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = LocationlatencyForm(request.POST)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchLocationLatency')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddLocationlatency.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar Latencia por Ubicacion',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.change_locationlatency',login_url='home')
def editLocationLatency(request, pr_Id):
    
     # Recuperamos la instancia de la persona
    instancia = Locationlatency.objects.get(id=pr_Id)

    # Creamos el formulario con los datos de la instancia
    form = LocationlatencyForm(instance=instancia)

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = LocationlatencyForm(request.POST, instance=instancia)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchLocationLatency')

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditLocationlatency.html", {
        'title':'Modulo de Alertas', 
         'message':'Editar Latencia por Ubicacion',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.view_staticparams',login_url='home')
def searchStaticparams(request,pr_modulo): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   Staticparams_list = Staticparams.objects.filter(modulo=pr_modulo).order_by('id')

   page = request.GET.get('page', 1)
   paginator = Paginator(Staticparams_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'home/SearchStaticparams.html', 
      {
         'title':'Modulo de Alertas', 
         'message':'Mantenimiento Parametros',
         'year':datetime.now().year, 
         'Staticparams_list': _filter2, # Embed data into the HttpResponse object
         'filter2': _filter2,
      }
   )

@login_required (login_url='login')
@permission_required('home.delete_staticparams',login_url='home')
def deleteStaticparams(request, pr_Id):
    # Recuperamos la instancia de la persona
    instancia = Staticparams.objects.get(id=pr_Id)
    vmodulo = instancia.modulo
    instancia.delete()
    return redirect('searchStaticparams', pr_modulo=vmodulo )

@login_required (login_url='login')
@permission_required('home.add_staticparams',login_url='home')
def addStaticparams(request):
    # Creamos un formulario vacío
    form = StaticparamsForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = StaticparamsForm(request.POST)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchStaticparams', pr_modulo=instancia.modulo)

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/AddStaticparams.html", {
        'title':'Modulo de Alertas', 
         'message':'Agregar Parametro',
         'year':datetime.now().year, 
         'form': form})

@login_required (login_url='login')
@permission_required('home.change_staticparams',login_url='home')
def editStaticparams(request, pr_Id):
    
     # Recuperamos la instancia de la persona
    instancia = Staticparams.objects.get(id=pr_Id)

    # Creamos el formulario con los datos de la instancia
    form = StaticparamsForm(instance=instancia)

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = StaticparamsForm(request.POST, instance=instancia)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            return redirect('searchStaticparams', pr_modulo=instancia.modulo)

    # Si llegamos al final renderizamos el formulario
    return render(request, "home/EditStaticparams.html", {
        'title':'Modulo de Alertas', 
         'message':'Parametros',
         'year':datetime.now().year, 
         'form': form})

def csvRepLatestShipDate(request,prfecha_inicial ,prfecha_final ):
    #Generando informació para archivo csv
        
    if(not prfecha_inicial or prfecha_inicial == 'None'):
        fecha_inicial = datetime.now()
        fecha_final =   datetime.now()
    else:
        fecha_inicial = datetime.strptime(prfecha_inicial, "%Y%m%d").date()
        if(not prfecha_final or prfecha_final == 'None'):
            fecha_final =   datetime.now()
        else:
            fecha_final =  datetime.strptime(prfecha_final, "%Y%m%d").date()
     
    det_list = Latestshipdate.objects.filter(
            fechainsercion__range = [datetime.combine(fecha_inicial, time.min),
                                datetime.combine(fecha_final, time.max)]       
        ).order_by('fechainsercion','id')
 
    filename = "{}-RepLatestShipDate.csv".format(datetime.now().strftime("%Y%m%d_%H%M%S"))
     
    response = HttpResponse(
        content_type='text/csv',            
    )        
     
    response['Content-Disposition'] = 'attachment; filename="{}"'.format(filename)
     
    writer = csv.writer(response)
    writer.writerow((
        'Analysis Date', 'PO Date','PO Number','SO Date','SO Number','Purchase Locations','Shipping Service Level'
        ,'Item Summary','Total','DiasSinFin','Latency'
        ))
    
    for row in det_list:
        writer.writerow((
            row.fechainsercion,row.latestshipdate,row.po,row.salesorderdate
            ,row.salesordernumber,row.fulfillmentlocationname
            ,row.shippingserviceslevel,row.sku,row.totalsales,row.diassinfin
            ,row.latency
            ))

    return response

@login_required (login_url='login')
@permission_required('home.reports_lateshidate',login_url='home')
def RepLatestShipDate(request):
    det_list = Latestshipdate.objects.all().order_by('fechainsercion','id')
    det_filter =LatestshipdateFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    #filtro de fecha para csv
    if(det_filter.form['fecha_inicial'].value()):
        prfecha = det_filter.form['fecha_inicial'].value()
        if(type(prfecha)!=datetime):
            prfecha_inicial = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_inicial = prfecha;
    else:
        prfecha_inicial = datetime.now()
    
    if(det_filter.form['fecha_final'].value()):         
        prfecha = det_filter.form['fecha_final'].value()
        if(type(prfecha)!=datetime):
            prfecha_final = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_final = prfecha;
    else:
        prfecha_final = datetime.now()

    vfecha_inicial = datetime.combine(prfecha_inicial, time.min).strftime("%Y%m%d")
    vfecha_final   = datetime.combine(prfecha_final, time.max).strftime("%Y%m%d")

    #Manejo de pagineo
    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/RepLatestShipDate.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte Latest Shipdate',
                        'year':datetime.now().year, 
                        'fecha_inicial':vfecha_inicial,
                        'fecha_final':vfecha_final  
                        })

@login_required (login_url='login')
@permission_required('home.graph_lateshidate',login_url='home')
def Grafica3(request):
    form = Grafica3Form();
 
    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = Grafica3Form(request.POST)
        if form.is_valid():
            prfechastr  = request.POST.get('fecha_inicial')        
            prfecha_inicial = parse_date(prfechastr)

            prfechastr  = request.POST.get('fecha_final')        
            prfecha_final = parse_date(prfechastr)       
            
            frm_TiempoRefrescar = int(request.POST.get('frmTiempoRefrescar'))
        else:
             return render(request, 'home/Grafica3.html', {        
                'form': form,        
                'title':'Modulo de Alertas', 
                'message':'Shipping Dashboard',
                'year':datetime.now().year,
            })
    else:        
        prfecha_inicial = datetime.now()
        prfecha_final = datetime.now()
        get_TiempoRefrescar = request.GET.get('TiempoRefrescar')
        if(get_TiempoRefrescar == None):
            frm_TiempoRefrescar = int(form.fields ['frmTiempoRefrescar'].initial);
        else:
            frm_TiempoRefrescar = int(request.GET.get('TiempoRefrescar'))

    prfecha_inicial = datetime.combine(prfecha_inicial, time.min)
    prfecha_final = datetime.combine(prfecha_final, time.max)
     
    CantSKU_List = Latestshipdatesku.objects.filter(
            fechaingreso__range = [prfecha_inicial,prfecha_final]       
        ).order_by('fechaingreso','-cantidad')[:10] 

    MaxTotalSale_list = Latestshipdate.objects.filter(
           fechainsercion__range = [prfecha_inicial,prfecha_final]            
        ).order_by('fechainsercion','-totalsales')[:10] 
 
    LsDiasxcantidad_List = LsDiasxcantidad.objects.filter(
            fechaingreso__range = [prfecha_inicial,prfecha_final]              
        ).annotate(                    
            total = Cast(F('number_0') + F('number_1')+ F('number_2')+
                    F('number_3') + F('number_4')+ F('number_5')+
                    F('number_6') + F('number_7')+ F('number_8')+
                    F('number_9') + F('number_10')+ F('number_11'), FloatField()),

            totalOK=Cast(Case(
                When(latency =1, then=F('number_0')),
                When(latency =2, then=F('number_0')+F('number_1')),
                When(latency =3, then=F('number_0')+F('number_1')+F('number_2')),
                When(latency =4, then=F('number_0')+F('number_1')+F('number_2')+F('number_3')),
                default=F('number_0')), FloatField())
        ).annotate(
            pOK = (F('totalOK')/F('total'))*100,
            pLate = (1 - (F('totalOK')/F('total')))*100
        ).order_by('statecode','fulfillmentlocationname')

    TotLsDiasxcantidad_List = LsDiasxcantidad.objects.values('fechaingreso').filter(
                    fechaingreso__range = [prfecha_inicial,prfecha_final]       
                ).annotate(                
                    sum_number_0 = Sum('number_0'),
                    sum_number_1 = Sum('number_1'),
                    sum_number_2 = Sum('number_2'),
                    sum_number_3 = Sum('number_3'),
                    sum_number_4 = Sum('number_4'),
                    sum_number_5 = Sum('number_5'),
                    sum_number_6 = Sum('number_6'),
                    sum_number_7 = Sum('number_7'),
                    sum_number_8 = Sum('number_8'),
                    sum_number_9 = Sum('number_9'),
                    sum_number_10 = Sum('number_10'),
                    sum_number_11 = Sum('number_11')                     
                )

    LsDiasxmonto_List = LsDiasxmonto.objects.filter(
                    fechaingreso__range = [prfecha_inicial,prfecha_final]                                               
                ).order_by('statecode','fulfillmentlocationname')

    TotLsDiasxmonto_List = LsDiasxmonto.objects.values('fechaingreso').filter(
                    fechaingreso__range = [prfecha_inicial,prfecha_final]             
                ).annotate(                
                    sum_number_0 = Sum('number_0'),
                    sum_number_1 = Sum('number_1'),
                    sum_number_2 = Sum('number_2'),
                    sum_number_3 = Sum('number_3'),
                    sum_number_4 = Sum('number_4'),
                    sum_number_5 = Sum('number_5'),
                    sum_number_6 = Sum('number_6'),
                    sum_number_7 = Sum('number_7'),
                    sum_number_8 = Sum('number_8'),
                    sum_number_9 = Sum('number_9'),
                    sum_number_10 = Sum('number_10'),
                    sum_number_11 = Sum('number_11')                     
                )
    
    LsCantX1Dia_List = LsDiasxcantidad.objects.values('statecode','fulfillmentlocationname').filter(
            fechaingreso__range = [prfecha_inicial,prfecha_final]         
        ).annotate(                    
            totalOK=Case(
                When(latency =1, then=F('number_0')),
                When(latency =2, then=F('number_1')),
                When(latency =3, then=F('number_2')),
                When(latency =4, then=F('number_3')),
                default=F('number_0'))
        ).values( 'statecode','fulfillmentlocationname', sumTotalOK = Sum('totalOK')
        ).filter(totalOK__gt = 0
        ).order_by('statecode','fulfillmentlocationname')

    return render(request, 'home/Grafica3.html', {        
        'form': form,        
        'prfecha_inicial':prfecha_inicial ,
        'prfecha_final':prfecha_final ,
        'title':'Modulo de Alertas', 
        'message':'Latest Shipdate',
        'year':datetime.now().year,
        'TiempoRefrescar': frm_TiempoRefrescar,
        'CantSKU_List':CantSKU_List,
        'MaxTotalSale_list':MaxTotalSale_list,
        'LsDiasxcantidad_List':LsDiasxcantidad_List,
        'LsDiasxmonto_List':LsDiasxmonto_List,
        'TotLsDiasxcantidad_List':TotLsDiasxcantidad_List,
        'TotLsDiasxmonto_List':TotLsDiasxmonto_List,
        'LsCantX1Dia_List':LsCantX1Dia_List
    })

@login_required (login_url='login')
@permission_required('home.reports_lateshidate',login_url='home')
def RepBitacoraDecambios(request):
    det_list = BitacoraDecambios.objects.all().order_by('fecha','id')
    det_filter =RepBitacoraDecambiosFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    #filtro de fecha para csv
    if(det_filter.form['fecha_inicial'].value()):
        prfecha = det_filter.form['fecha_inicial'].value()
        if(type(prfecha)!=datetime):
            prfecha_inicial = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_inicial = prfecha;
    else:
        prfecha_inicial = datetime.now()
    
    if(det_filter.form['fecha_final'].value()):         
        prfecha = det_filter.form['fecha_final'].value()
        if(type(prfecha)!=datetime):
            prfecha_final = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_final = prfecha;
    else:
        prfecha_final = datetime.now()

    vfecha_inicial = datetime.combine(prfecha_inicial, time.min).strftime("%Y%m%d")
    vfecha_final   = datetime.combine(prfecha_final, time.max).strftime("%Y%m%d")

    #Manejo de pagineo
    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/RepBitacoraDecambios.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte Bitacora de Cambios',
                        'year':datetime.now().year, 
                        'fecha_inicial':vfecha_inicial,
                        'fecha_final':vfecha_final  
                        })

@login_required (login_url='login')
@permission_required('home.reports_lateshidate',login_url='home')
def RepLatestshipdatesku(request):
    det_list = Latestshipdatesku.objects.all().order_by('fechaingreso','id')
    det_filter =RepLatestshipdateskuFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    #filtro de fecha para csv
    if(det_filter.form['fecha_inicial'].value()):
        prfecha = det_filter.form['fecha_inicial'].value()
        if(type(prfecha)!=datetime):
            prfecha_inicial = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_inicial = prfecha;
    else:
        prfecha_inicial = datetime.now()
    
    if(det_filter.form['fecha_final'].value()):         
        prfecha = det_filter.form['fecha_final'].value()
        if(type(prfecha)!=datetime):
            prfecha_final = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_final = prfecha;
    else:
        prfecha_final = datetime.now()

    vfecha_inicial = datetime.combine(prfecha_inicial, time.min).strftime("%Y%m%d")
    vfecha_final   = datetime.combine(prfecha_final, time.max).strftime("%Y%m%d")

    #Manejo de pagineo
    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'home/RepLatestshipdatesku.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte SKU Repetidos',
                        'year':datetime.now().year, 
                        'fecha_inicial':vfecha_inicial,
                        'fecha_final':vfecha_final  
                        })

def csvRepLatestshipdatesku(request,prfecha_inicial ,prfecha_final ):
    #Generando informació para archivo csv
        
    if(not prfecha_inicial or prfecha_inicial == 'None'):
        fecha_inicial = datetime.now()
        fecha_final =   datetime.now()
    else:
        fecha_inicial = datetime.strptime(prfecha_inicial, "%Y%m%d").date()
        if(not prfecha_final or prfecha_final == 'None'):
            fecha_final =   datetime.now()
        else:
            fecha_final =  datetime.strptime(prfecha_final, "%Y%m%d").date()
     
    det_list = Latestshipdatesku.objects.filter(
            fechaingreso__range = [datetime.combine(fecha_inicial, time.min),
                                datetime.combine(fecha_final, time.max)]       
        ).order_by('fechaingreso','-cantidad')
 
    filename = "{}-RepLatestshipdatesku.csv".format(datetime.now().strftime("%Y%m%d_%H%M%S"))
     
    response = HttpResponse(
        content_type='text/csv',            
    )        
     
    response['Content-Disposition'] = 'attachment; filename="{}"'.format(filename)
     
    writer = csv.writer(response)
    writer.writerow((
        'fechaingreso','sku','cantidad'
        ))
    
    for row in det_list:
        writer.writerow((
            row.fechaingreso     ,row.sku               ,row.cantidad          
            ))

    return response

######################################################################################################
##   REPORTES DE LISTING
######################################################################################################
def csvRepListingMismatch(request,prfecha_inicial ,prfecha_final ):
    #Generando informació para archivo csv
        
    if(not prfecha_inicial or prfecha_inicial == 'None'):
        fecha_inicial = datetime.now()
        fecha_final =   datetime.now()
    else:
        fecha_inicial = datetime.strptime(prfecha_inicial, "%Y%m%d").date()
        if(not prfecha_final or prfecha_final == 'None'):
            fecha_final =   datetime.now()
        else:
            fecha_final =  datetime.strptime(prfecha_final, "%Y%m%d").date()
     
    det_list = RepDiffquantity.objects.filter(
            fechaingreso__range = [datetime.combine(fecha_inicial, time.min),
                                datetime.combine(fecha_final, time.max)]       
        ).order_by('fechaingreso','idregistro')
 
    filename = "{}-RepListingMismatch.csv".format(datetime.now().strftime("%Y%m%d_%H%M%S"))
     
    response = HttpResponse(
        content_type='text/csv',            
    )        
     
    response['Content-Disposition'] = 'attachment; filename="{}"'.format(filename)
     
    writer = csv.writer(response)
    writer.writerow((
        'fechaingreso','sku','sku_status','listing','listing_status','amazonuomquantity'
        ,'publicationmode','review_state','availabilitymode','number_of_items','item_package_quantity','asin'
        ))
    
    for row in det_list:
        writer.writerow((
            row.fechaingreso     ,row.sku               ,row.sku_status            ,row.listing
            ,row.listing_status   ,row.amazonuomquantity ,row.publicationmode       ,row.review_state
            ,row.availabilitymode ,row.number_of_items   ,row.item_package_quantity ,row.asin
            ))

    return response

@login_required (login_url='login')
@permission_required('home.reports_shipping',login_url='home')
def RepListingMismatch(request):

    det_list = RepDiffquantity.objects.all().order_by('fechaingreso','idregistro')

    det_filter = RepListingMismatchFilter(request.GET, queryset=det_list)
        
    if(det_filter.form['fecha_inicial'].value()):
        prfecha = det_filter.form['fecha_inicial'].value()
        if(type(prfecha)!=datetime):
            prfecha_inicial = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_inicial = prfecha;
    else:
        prfecha_inicial = datetime.now()
    
    if(det_filter.form['fecha_final'].value()):         
        prfecha = datetime.strptime(det_filter.form['fecha_final'].value(), "%Y-%m-%d").date()
        if(type(prfecha)!=datetime):
            prfecha_final = datetime.strptime(prfecha, "%Y-%m-%d").date()        
        else:
            prfecha_inicial = prfecha;
    else:
        prfecha_final = datetime.now()

    vfecha_inicial = datetime.combine(prfecha_inicial, time.min).strftime("%Y%m%d")
    vfecha_final = datetime.combine(prfecha_final, time.max).strftime("%Y%m%d")

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

    #Manejo de pagineo
    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)
    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    
    return render(request, 'home/RepListingMismatch.html'                    , { 
                        'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'Modulo de Alertas', 
                        'message':'Reporte Listing Mismatch',
                        'year':datetime.now().year, 
                        'fecha_inicial': vfecha_inicial,
                        'fecha_final'  : vfecha_final ,
                        })
