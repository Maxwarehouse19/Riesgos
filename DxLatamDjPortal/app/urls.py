
from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('',views.home, name='home'),
    path('addTablaprueba/', views.addTablaprueba, name='addTablaprueba'),

    path('searchLote/', views.searchLote, name='searchLote'),
    path('searchLoteDetalle/<int:pr_IdRegistro>', views.searchLoteDetalle, name='searchLoteDetalle'),
    path('comparacion/<int:pr_IdRegistro>', views.searchRegistro, name='comparacion'),
    path('repLote/', views.repLote, name='repLote'),
    path('csvRepLote/<str:prfecha_inicial>/<str:prfecha_final>', views.csvRepLote, name='csvRepLote'),
    path('revisarOperadores/', views.revisarOperadores, name='revisarOperadores'),
    path('revisarOperador/<int:pr_IdOperador>', views.revisarOperador, name='revisarOperador'),
    path('listingCorrecto/<str:pr_Id>/<int:pr_IdOperador>', views.listingCorrecto, name='listingCorrecto'),
    path('listingIncorrecto/<str:pr_Id>/<int:pr_IdOperador>', views.listingIncorrecto, name='listingIncorrecto'),

    path('password_change/', auth_views.PasswordChangeView.as_view(template_name='registration/password_change.html'), 
        name='password_change'),
    path('password_change/done/', auth_views.PasswordChangeDoneView.as_view(template_name='registration/password_changed.html'), 
        name='password_change_done'),

]