from django.urls import path
from . import views
from django.contrib.auth.views import LoginView, LogoutView

from datetime import datetime
from home import forms#, PlotlyGraph

urlpatterns = [
    path('',views.home, name='home'),
    path('login/',
         LoginView.as_view
         (
             template_name='home/login.html',
             authentication_form=forms.BootstrapAuthenticationForm,
             extra_context=
             {
                 'title': 'Log in',
                 'year' : datetime.now().year,
             }
         ),
         name='login'),
    path('logout/', LogoutView.as_view(next_page='/'), name='logout'),
    path('home/',views.home, name='home'),

    path('dashboard/',views.dashboard, name='dashboard'),

    path('searchContacto/', views.searchContacto, name='searchContacto'),
    path('addContacto/', views.addContacto, name='addContacto'),
    path('editContacto/<str:pr_IdRegistro>', views.editContacto, name='editContacto'),
    path('deleteContacto/<str:pr_IdRegistro>', views.deleteContacto, name='deleteContacto'),

    path('searchListaContacto/', views.searchListaContacto, name='searchListaContacto'),
    path('addListacontacto/', views.addListaContacto, name='addListacontacto'),
    path('editListacontacto/<str:pr_IdRegistro>', views.editListaContacto, name='editListacontacto'),
    path('deleteListacontacto/<str:pr_IdRegistro>', views.deleteListaContacto, name='deleteListacontacto'),

    path('searchMensaje/', views.searchMensaje, name='searchMensaje'),
    path('addMensaje/', views.addMensaje, name='addMensaje'),
    path('editMensaje/<str:pr_IdRegistro>', views.editMensaje, name='editMensaje'),
    path('deleteMensaje/<str:pr_IdRegistro>', views.deleteMensaje, name='deleteMensaje'),
    
    path('searchChkPoint/', views.searchChkPoint, name='searchChkPoint'),
    path('addChkPoint/', views.addChkPoint, name='addChkPoint'),
    path('editChkPoint/<str:pr_IdRegistro>', views.editChkPoint, name='editChkPoint'),
    path('deleteChkPoint/<str:pr_IdRegistro>', views.deleteChkPoint, name='deleteChkPoint'),
    
    path('searchDetChkPoint/', views.searchDetChkPoint, name='searchDetChkPoint'),
    path('addDetChkPoint/', views.addDetChkPoint, name='addDetChkPoint'),
    path('editDetChkPoint/<str:pr_IdRegistro>', views.editDetChkPoint, name='editDetChkPoint'),
    path('deleteDetChkPoint/<str:pr_IdRegistro>', views.deleteDetChkPoint, name='deleteDetChkPoint'),

    path('filterDetChkPoint/', views.filterDetChkPoint, name='filterDetChkPoint'),
    
    path('searchCategory/', views.searchCategory, name='searchCategory'),
    path('editCategory/<str:pr_Id>', views.editCategory, name='editCategory'),
    path('addCategory/', views.addCategory, name='addCategory'),
    path('deleteCategory/<str:pr_Id>', views.deleteCategory, name='deleteCategory'),

    path('Grafica1', views.Grafica1, name='Grafica1'),

    path('RepDetalleMensajes/', views.RepDetalleMensajes, name='RepDetalleMensajes'),    
    path('csvRepDetalleMensajes/', views.csvRepDetalleMensajes, name='csvRepDetalleMensajes'),

    path('RepReqVsActual/', views.RepReqVsActual, name='RepReqVsActual'),    
    path('csvRepReqVsActual/', views.csvRepReqVsActual, name='csvRepReqVsActual'),    
  
    path('RepPromedioServicio/', views.RepPromedioServicio, name='RepPromedioServicio'),    
    path('RepAmazonlate/', views.RepAmazonlate, name='RepAmazonlate'),    
   
    path('Grafica2/', views.Grafica2, name='Grafica2'),

    path('RepListingMismatch/', views.RepListingMismatch, name='RepListingMismatch'),    
    path('csvRepListingMismatch/<str:prfecha_inicial>/<str:prfecha_final>', views.csvRepListingMismatch, name='csvRepListingMismatch'),    

    path('Grafica3/', views.Grafica3, name='Grafica3'),
    path('RepLatestShipDate/', views.RepLatestShipDate, name='RepLatestShipDate'),
    path('csvRepLatestShipDate/<str:prfecha_inicial>/<str:prfecha_final>', views.csvRepLatestShipDate, name='csvRepLatestShipDate'),    
    path('RepBitacoraDecambios/', views.RepBitacoraDecambios, name='RepBitacoraDecambios'),
    path('RepLatestshipdatesku/', views.RepLatestshipdatesku, name='RepLatestshipdatesku'),
    path('csvRepLatestshipdatesku/<str:prfecha_inicial>/<str:prfecha_final>', views.csvRepLatestshipdatesku, name='csvRepLatestshipdatesku'),

    path('addLocationLatency/' , views.addLocationLatency, name='addLocationLatency'),
    path('deleteLocationLatency/<str:pr_Id>', views.deleteLocationLatency, name='deleteLocationLatency'),
    path('editLocationLatency/<str:pr_Id>', views.editLocationLatency, name='editLocationLatency'),
    path('searchLocationLatency/', views.searchLocationLatency, name='searchLocationLatency'),

    path('addStaticparams/' , views.addStaticparams, name='addStaticparams'),
    path('deleteStaticparams/<str:pr_Id>', views.deleteStaticparams, name='deleteLocationLatency'),
    path('editStaticparams/<str:pr_Id>', views.editStaticparams, name='editStaticparams'),
    path('searchStaticparams/<str:pr_modulo>', views.searchStaticparams, name='searchStaticparams'),
   
]

