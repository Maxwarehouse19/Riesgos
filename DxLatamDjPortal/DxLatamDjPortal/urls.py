"""
Definition of urls for DxLatamDjPortal.
"""

from datetime import datetime
from django.urls import path, include
from django.contrib import admin
from django.contrib.auth.views import LoginView, LogoutView
from app import forms, views


urlpatterns = [
    #path('', views.home, name='home'),
    #path('login/',
    #     LoginView.as_view
    #     (
    #         template_name='home/login.html',
    #         authentication_form=forms.BootstrapAuthenticationForm,
    #         extra_context=
    #         {
    #             'title': 'Log in',
    #             'year' : datetime.now().year,
    #         }
    #     ),
    #     name='login'),
    path('logout/', LogoutView.as_view(next_page='/'), name='logout'),
    path('admin/', admin.site.urls),
    path('',include('home.urls')),
    path('',include('app.urls')),
    path('django_plotly_dash/', include('django_plotly_dash.urls')),
]
