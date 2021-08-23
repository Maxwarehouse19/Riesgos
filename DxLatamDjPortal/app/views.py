"""
Definition of views.
"""

from datetime import datetime, time
from django.shortcuts import render
from django.http import HttpRequest,HttpResponse
from django.shortcuts import redirect
from .models import Tablaprueba, hdBatch, dtBatch, preguntas
from .forms import TablapruebaForm, PreguntasMatchForm, PreguntasSupervisor
from django.db import models
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.db.models import  Count, Q
from django.contrib.auth.models import User
import simplejson as json
from django.db import connections
from django.contrib import messages
from .filters import repLoteFilter
from django.core.paginator import EmptyPage, PageNotAnInteger
import csv

def home(request):
    """Renders the home page."""
    assert isinstance(request, HttpRequest)
    return render(
        request,
        'app/index.html',
        {
            'title':'Home Page',
            'year':datetime.now().year,
        }
    )


@login_required (login_url='login')
#@permission_required('home.add_alecontactos',login_url='home')
def addTablaprueba(request):
    # Creamos un formulario vacío
    form = TablapruebaForm()

    # Comprobamos si se ha enviado el formulario
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        form = TablapruebaForm(request.POST)
        # Si el formulario es válido...
        if form.is_valid():
            # Guardamos el formulario pero sin confirmarlo,
            # así conseguiremos una instancia para manejarla
            instancia = form.save(commit=False)

            # Podemos guardarla cuando queramos
            instancia.save()
            # Después de guardar redireccionamos a la lista
            #return redirect('searchTablaprueba')

    # Si llegamos al final renderizamos el formulario
    return render(request, "app/AddTablaprueba.html", {
        'title':'Listing Contínuo', 
         'message':'Agregar a Tabla',
         'year':datetime.now().year, 
         'form': form})

def RecorreLotes(prLotes_list,user):
    # Retrieve all contacts in the database table
   if user.groups.filter(name__in=['Operador']):
        Lotes_list = tuple(hdBatch.objects.all().values('id','codigo','descripcion','usuario','fechahora','tipo','status').filter(usuario=str(user.id)).order_by('status'))
   elif user.groups.filter(name__in=['Supervisor']):
        Lotes_list = tuple(hdBatch.objects.all().values('id','codigo','descripcion','usuario','fechahora','tipo','status').order_by('-status'))
   for Lotes in Lotes_list:
       if Lotes['tipo'] == 12:
            Lotes['tipo'] = 'New/Rejected'
       if Lotes['status']==0:
           Lotes['status']= 'No Disponible'
       elif Lotes['status']==1:
           Lotes['status']= 'Generado'
       elif Lotes['status']==2:
           Lotes['status']= 'Asignado'
       elif Lotes['status']==3:
           Lotes['status']= 'Cerrado'
       
       
       prLotes_list.append(Lotes)        
   return 1

@login_required (login_url='login')
def searchLote(request): 
   """Renders the ALECONTACTOS page."""
   #assert isinstance(request, HttpRequest) 

   # Retrieve all contacts in the database table
   lotes_list = []
   mensaje=""
   usuario=""
   current_user= request.user
   if current_user.groups.filter(name__in=['Operador']):
        usuario='operador'
        lotes_list = hdBatch.objects.filter(usuario=current_user.id).order_by('status')
   elif current_user.groups.filter(name__in=['Supervisor']):
        usuario='supervisor'
        lotes_list = hdBatch.objects.order_by('-status')
   #RecorreLotes(lotes_list,current_user)
   page = request.GET.get('page', 1)
   paginator = Paginator(lotes_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   if request.method == "POST":
        # Añadimos los datos recibidos al formulario
                          
        cursor= connections['default'].cursor()
        cursor.execute(""" select id from hdbatch 
                        where status!=3 and usuario=%s """,[str(current_user.id)])    
        rows = cursor.fetchone()   
        if rows:
           mensaje = 'Aún tiene lotes pendientes de realizar.'
        else:
            permisos = current_user.get_all_permissions()
            permisosTipoLote = []
            permisosSim = 0
            permisosType = 0
            for permiso in permisos:
                if permiso.find('app.batch_type_')>-1:
                    permisosType = 1
                    permisosTipoLote.append(permiso[-2:])
                elif permiso.find('app.batch_sim_')>-1:
                    permisosSim = 1

            if permisosSim==1: #and permisosType==1#:
                cursor= connections['default'].cursor()
                consulta =""
                if current_user.has_perm('app.batch_lower_30') and current_user.has_perm('app.batch_sim_30_higher'):
                    consulta += ""
                elif current_user.has_perm('app.batch_sim_30_higher'):
                    consulta += "and porcentajeSimilitud>=30"
                elif current_user.has_perm('app.batch_sim_lower_30'):
                   consulta += "and porcentajeSimilitud<30"  
               
                if permisosType!=0:
                    for permiso in permisosTipoLote:
                        if permiso!=permisosTipoLote[0]:
                            consulta+= ' or tipo='+permiso
                        else:
                            consulta+= ' and (tipo='+permiso
                    consulta+= ')'

                print(consulta)
                cursor.execute(""" select min(id)
                                    from hdbatch where status=1 """+consulta)
                resultados = cursor.fetchone()   
                res = resultados[0]
                if res:
                    cursor= connections['default'].cursor()
                    cursor.execute(""" update hdbatch set usuario=%s,status=2
                                where id=(select min(id) from hdbatch where status=1 """+ consulta+")",[current_user.id])
                    cursor.execute(""" update dtbatch set status=1
                                where batchid=(select min(id) from hdbatch where status=2 and usuario=%s) """,[current_user.id])
                    return redirect('searchLote') 
                else:
                    mensaje = 'No hay lotes disponibles.'
            else:
                mensaje = 'No cuenta con los permisos.'


   return render(
      request, 
      'app/searchLote.html', 
      {
         'title':'Lotes', 
         'message':'Lista de Lotes',
         'year':datetime.now().year, 
         'lotes_list': _filter2, # Embed data into the HttpResponse object
         'filter2': _filter2,
         'mensaje' :mensaje,
         'usuario' : usuario
      }
   )

@login_required (login_url='login')
def repLote(request): 
    det_list = dtBatch.objects.values('operador').filter(operador__gte=0).annotate(realizados=Count('id'),match=Count('matchstatus',filter=Q(matchstatus=1)),missmatch=Count('matchstatus',filter=Q(matchstatus=2)),revisados=Count('status',filter=Q(status__gte=3)),correctos=Count('status',filter=Q(status=3)),incorrectos=Count('status',filter=Q(status=4))).order_by('operador').distinct()
    #det_list=dtBatch.objects.all()
    det_filter = repLoteFilter(request.GET, queryset=det_list)

    #Manteniendo los parámetros del filtro en pantalla    
    get_copy = request.GET.copy()
    parameters = get_copy.pop('page', True) and get_copy.urlencode()

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

    vfecha_inicial = datetime.combine(prfecha_inicial, time.min).strftime("%Y-%m-%d")
    vfecha_final   = datetime.combine(prfecha_final, time.max).strftime("%Y-%m-%d")

    page = request.GET.get('page', 1)
    paginator = Paginator(det_filter.qs, 10)

    try:
        _filter2 = paginator.page(page)
    except PageNotAnInteger:
        _filter2 = paginator.page(1)
    except EmptyPage:
        _filter2 = paginator.page(paginator.num_pages)

    return render(request, 'app/RepLote.html'
                    , { 'parameters': parameters,
                        'filter': det_filter,
                        'filter2': _filter2,
                        'title':'', 
                        'message':'Reporte de Operadores',
                        'year':datetime.now().year, 
                        'usuarios': User.objects.all(),
                        'fecha_inicial':vfecha_inicial,
                        'fecha_final':vfecha_final  })

def csvRepLote(request,prfecha_inicial ,prfecha_final ):
    #Generando informació para archivo csv
        
    if(not prfecha_inicial or prfecha_inicial == 'None'):
        fecha_inicial = datetime.now()
        fecha_final =   datetime.now()
    else:
        fecha_inicial = datetime.strptime(prfecha_inicial, "%Y-%m-%d").date()
        if(not prfecha_final or prfecha_final == 'None'):
            fecha_final =   datetime.now()
        else:
            fecha_final =  datetime.strptime(prfecha_final, "%Y-%m-%d").date()

    det_list = dtBatch.objects.values('operador').filter(operador__gte=0,
        fecharealizado__range = [datetime.combine(fecha_inicial, time.min),
                                datetime.combine(fecha_final, time.max)]  ).annotate(
        realizados=Count('id'),match=Count('matchstatus',filter=Q(matchstatus=1)),
        missmatch=Count('matchstatus',filter=Q(matchstatus=2)),
        revisados=Count('status',filter=Q(status__gte=3)),correctos=Count('status',filter=Q(status=3)),
        incorrectos=Count('status',filter=Q(status=4))).order_by('operador').distinct()
     
    
 
    filename = "{}-RepLote.csv".format(datetime.now().strftime("%Y%m%d_%H%M%S"))
     
    response = HttpResponse(
        content_type='text/csv',            
    )        
     
    response['Content-Disposition'] = 'attachment; filename="{}"'.format(filename)
     
    writer = csv.writer(response)
    writer.writerow((
        'Operador', 'Realizados','Match','MissMatch','Revisados','Correctos','Incorrectos'
        ))
    
    for row in det_list:
        writer.writerow((
            (User.objects.values('username').get(id=row['operador']))['username'],
            row['realizados'],row['match'],row['missmatch'],
            row['revisados'],row['correctos'],row['incorrectos']
            ))

    return response

@login_required (login_url='login')
def revisarOperadores(request): 
   """Renders the ALECONTACTOS page."""
   #assert isinstance(request, HttpRequest) 
   current_user= request.user
   if current_user.groups.filter(name__in=['Supervisor']):
       lotes_list = []  
       lote_list = dtBatch.objects.values('operador').annotate(
            faltarevisar=Count('status',filter=Q(status=2))).filter(operador__gte=0, faltarevisar__gte=1).order_by('-faltarevisar').distinct()
       for res in lote_list:
           try:
                res['operadorname'] = (User.objects.values('username').get(id=res['operador']))['username']
                lotes_list.append(res) 
           except:
               print("usuario no encontrado")
       page = request.GET.get('page', 1)
       paginator = Paginator(lotes_list, 10)
       try:
           _filter2 = paginator.page(page)
       except PageNotAnInteger:
           _filter2 = paginator.page(1)
       except EmptyPage:
           _filter2 = paginator.page(paginator.num_pages)
       return render(
        request, 
          'app/revisarOperadores.html', 
          {
             'title':'', 
             'message':'Pendientes de Revisión',
             'year':datetime.now().year, 
             'lotes_list': _filter2, # Embed data into the HttpResponse object
             'filter2': _filter2
          }
   )
   else:
       #retornar a home
       return redirect('home')

@login_required (login_url='login')
def revisarOperador(request, pr_IdOperador): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 
   current_user= request.user
   if current_user.groups.filter(name__in=['Supervisor']):
       detalles_lote_list = dtBatch.objects.filter(operador=pr_IdOperador,status=2).order_by('id')
       page = request.GET.get('page', 1)
       paginator = Paginator(detalles_lote_list, 10)
       try:
           _filter2 = paginator.page(page)
       except PageNotAnInteger:
           _filter2 = paginator.page(1)
       except EmptyPage:
           _filter2 = paginator.page(paginator.num_pages)

       return render(
          request, 
          'app/revisarOperador.html', 
          {
             'title': (User.objects.values('username').get(id=pr_IdOperador))['username'], 
             'message':'Pendientes de Revision',
             'year':datetime.now().year, 
             'detalles_lote_list': _filter2, # Embed data into the HttpResponse object
             'filter2': _filter2
          }
       )
   else:
       #retornar a home
       return redirect('home')

@login_required (login_url='login')
def listingCorrecto(request, pr_Id, pr_IdOperador):
    # Recuperamos la instancia de la persona
    cursor= connections['default'].cursor()
    cursor.execute(""" update dtbatch set status=3
                        where id=%s """,[pr_Id])  
    return redirect('revisarOperador',pr_IdOperador)

@login_required (login_url='login')
def listingIncorrecto(request, pr_Id, pr_IdOperador):
    # Recuperamos la instancia de la persona
    cursor= connections['default'].cursor()
    cursor.execute(""" update dtbatch set status=4
                        where id=%s """,[pr_Id])  
    return redirect('revisarOperador',pr_IdOperador)

@login_required (login_url='login')
def searchLoteDetalle(request, pr_IdRegistro): 
   """Renders the ALECONTACTOS page."""
   assert isinstance(request, HttpRequest) 
   current_user= request.user
   if current_user.groups.filter(name__in=['Operador']):
        usuario='operador'
   elif current_user.groups.filter(name__in=['Supervisor']):
        usuario='supervisor'
   # Retrieve all contacts in the database table
   detalles_lote_list = dtBatch.objects.filter(batchid=pr_IdRegistro).order_by('id')
   #detalles_lote_list = User.objects.order_by('id')

   page = request.GET.get('page', 1)
   paginator = Paginator(detalles_lote_list, 10)
   try:
       _filter2 = paginator.page(page)
   except PageNotAnInteger:
       _filter2 = paginator.page(1)
   except EmptyPage:
       _filter2 = paginator.page(paginator.num_pages)

   return render(
      request, 
      'app/searchLoteDetalle.html', 
      {
         'title':'Lotes Detalle', 
         'message':'Lista de detalles de Lotes',
         'year':datetime.now().year, 
         'detalles_lote_list': _filter2, # Embed data into the HttpResponse object
         'filter2': _filter2, 'usuario': usuario
      }
   )


@login_required (login_url='login')
def searchRegistro(request,pr_IdRegistro): 
    current_user= request.user
    usuario = ''
    unido=[]
    if current_user.groups.filter(name__in=['Operador']):
        form = PreguntasMatchForm()
        usuario='operador'
    elif current_user.groups.filter(name__in=['Supervisor']):
        form = PreguntasSupervisor()
        usuario='supervisor'
        questions = preguntas.objects.order_by('id')
        respuestasDato = dtBatch.objects.get(id=pr_IdRegistro)
        if respuestasDato.answers!=None:
            respuestas=[]
            for i in range(0,len(respuestasDato.answers)):
                if respuestasDato.answers[i]=='1':
                    respuestas.append('NO ENCONTRADO')
                elif respuestasDato.answers[i]=='2':
                    respuestas.append('VERIFICADO')
                else:
                    respuestas.append('NO COINCIDE')
            contador = 0 
            for question in questions:
                unido.append([question.textual,respuestas[contador]])
                contador = contador+1
            if respuestasDato.matchstatus==1:
                unido.append(['Respuesta Final','MATCH'])
            else:
                unido.append(['Respuesta Final','MISSMATCH'])
        else:
            contador = 0 
            for question in questions:
                unido.append([question.textual,'NO INGRESADA AÚN'])
                contador = contador+1
            unido.append(['Respuesta Final','NO INGRESADA AÚN'])
    try:
        cursor= connections['default'].cursor()
        cursor.execute(""" select i.[asin], i.title,i.brand, i.manufacturer, i.itempackagequantity, i.partnumber, 
                        i.productdimensions, i.itemweight, i.price,  i.color,  
                        i.material, i.itemmodelnumber, i.linkimagen, d.batchid 
                        from InfoArtAMZ i 
                        join dtbatch d on d.[asin]=i.asinoriginal and d.upc=i.upcoriginal 
                        where d.id=%s """,[pr_IdRegistro])    
        rows = cursor.fetchone()   
        if rows:
            asin, title,brand,manufacturer,itempackagequantity,partnumber,productdimensions,itemweight,price,color,material,itemmodelnumber,linkimagen,batchid = rows 
            if brand.startswith('Brand:'):
                brand=brand[6:]
        else:
            asin= "" 
            title= "" 
            price= "" 
            brand= "" 
            partnumber= "" 
            color= "" 
            itemweight= "" 
            manufacturer= "" 
            productdimensions= "" 
            itempackagequantity= "" 
            material= "" 
            itemmodelnumber= "" 
            linkimagen = ""  
            batchid = ""

        cursor.execute(""" select l.upc,l.[asin], l.title, l.brand, c.manufacturer,l.[Item Package Quantity], c.[Part #], 
                        coalesce(trim(str(s.OM_Length)),'')+'x'+ coalesce(trim(str(s.OM_Width)),'')+'x'+coalesce(trim(str(s.OM_Height)),''),
                        s.OM_Weight, l.sku, l.UOMquantity,l.[Sales Listing], c.[Master Sku],
                        coalesce(trim(str(i.[EJDUOMQTY])),'')+'/'+coalesce(trim(str(i.[aceuomqty])),''),
                        s.Search_Desc, s.Image_URL_High_Res
                        from tmpListingInventoryAmazon l
                        join dtbatch d on d.[asin]=l.[asin] and d.upc=l.upc
	                    left join tmpCatalogEVP c on l.upc=c.upc
                        left join tmpEVPSkuInventory i on c.upc=i.upc and c.[Master Sku]=i.Sku
                        left join wUniStorages s on l.upc=s.Item_UPC_Code where d.id=%s """,[pr_IdRegistro])    
        rows = cursor.fetchone()   
        if rows:
            upc,asin2, title2, brand2, manufacturer2, itempackagequantity2, partnumber2, productdimensions2, itemweight2, sku,uomquantity,saleslisting,mastersku,ejdace,searchdesc,linkimg = rows    
        else:
            upc = ""
            asin2 = ""
            title2= ""
            brand2= ""
            manufacturer2 = ""
            itempackagequantity2 = ""
            partnumber2= ""
            productdimensions2 = ""
            itemweight2= ""
            sku= ""
            uomquantity = ""
            saleslisting= ""
            mastersku= ""
            ejdace= ""
            searchdesc= ""
            linkimg = ""

    finally:
        cursor.close()
    
    if request.method == "POST":
        # Añadimos los datos recibidos al formulario
        if current_user.groups.filter(name__in=['Operador']):
            form = PreguntasMatchForm(request.POST)
            if form.is_valid():  
                cadenaRespuesta = ""
                for respuesta in form.cleaned_data:
                    if respuesta!='veredicto':
                        cadenaRespuesta+= form.cleaned_data[respuesta]
                cursor= connections['default'].cursor()
                cursor.execute(""" update dtbatch set answers=%s, matchStatus=%s, status=2, operador=%s, fechaRealizado=getDate()
                            where id=%s """,[cadenaRespuesta,form.cleaned_data['veredicto'],current_user.id,pr_IdRegistro])
                cursor.execute(""" select case
	                                    when count(id) = (select count(id) from dtbatch where matchstatus in(1,2) and batchid=%s) then 1
	                                    else 0
	                                    end
                                    from dtbatch where batchid=%s """,[batchid,batchid])
                resultados = cursor.fetchone()   
                res = resultados[0]
                if res==1:
                    cursor= connections['default'].cursor()
                    cursor.execute(""" update hdbatch set status=3
                                where id=%s """,[batchid])
                return redirect('searchLoteDetalle',batchid)
        else:
            form = PreguntasSupervisor(request.POST)
            if form.is_valid():  
                cursor= connections['default'].cursor()
                cursor.execute(""" update dtbatch set status=%s
                            where id=%s """,[int(form.cleaned_data['veredicto'])+2,pr_IdRegistro])
                cursor.execute(""" select case
	                                    when count(id) = (select count(id) from dtbatch where status in(3,4) and batchid=%s) then 1
	                                    else 0
	                                    end
                                    from dtbatch where batchid=%s """,[batchid,batchid])
                resultados = cursor.fetchone()   
                res = resultados[0]
                if res==1:
                    cursor= connections['default'].cursor()
                    cursor.execute(""" update hdbatch set status=4
                                where id=%s """,[batchid])
                # Guardamos el formulario pero sin confirmarlo,
                # así conseguiremos una instancia para manejarla
                #instancia = form.save(commit=False)
                # Podemos guardarla cuando queramos
                #instancia.save()
                # Después de guardar redireccionamos a la lista
                #return redirect('searchLoteDetalle',batchid)
                return redirect('searchLoteDetalle',batchid)
        # Si el formulario es válido...
        
    return render(
        request, 
        'app/comparacion.html', 
        {  
            'title':'UPC: '+str(upc), 
            'message':'Comparación de Listing',
            'asin': asin, 'tittle': title.strip(), 'price': price, 'brand': brand.strip(),
            'partnumber': partnumber.strip(),'color': color.strip(),'itemweight': itemweight.strip(),'manufacturer':manufacturer.strip(),
            'productdimensions':productdimensions.strip(), 'itempackagequantity':itempackagequantity.strip(), 
            'material': material.strip(), 'itemmodelnumber': itemmodelnumber.strip(),'linkimagen': linkimagen,
            'upc':upc,'asin2': asin2, 'tittle2': title2.strip(), 'brand2': brand2.strip(),
            'itemweight2': itemweight2,'manufacturer2':manufacturer2.strip(), 'partnumber2':partnumber2.strip(),
            'productdimensions2':productdimensions2.strip(), 'itempackagequantity2':itempackagequantity2, 
            'sku':sku,'uomquantity':uomquantity,'saleslisting':saleslisting.strip(),'mastersku':mastersku,
            'ejdace':ejdace,'searchdesc':searchdesc,'linkimg':linkimg,
            'year':datetime.now().year,'form': form, 'union':unido, 'usuario':usuario
        }
        )
