from django.forms import ModelForm
from datetime import datetime 
import datetime as dt
import calendar
from django.contrib.auth.models import User

######################################################################################################
##   FUNCIONES GENERALES
######################################################################################################


######################################################################################################
##   CLASIFICACIONES GENERALES
######################################################################################################

PREGUNTA_CHOICES23 = [(0,'----'),(2,'VERIFICADO'),(3,'NO COINCIDE')]
PREGUNTA_CHOICES123 = [(0,'----'),(1,'NO ENCONTRADO'),(2,'VERIFICADO'),(3,'NO COINCIDE')]
VEREDICTO_CHOICES = [(0,'----'),(1,'MATCH'),(2,'MISSMATCH')]
SUPERVISOR_CHOICES = [(0,'----'),(1,'CORRECTO'),(2,'INCORRECTO')]

USER_CHOICES = tuple(User.objects.values_list('id','username'))

Month_choice = [(i, calendar.month_name[i]) for i in range(1,12)]
Year_choice = [(x, '{:04d}'.format(x)) for x in range(2020, 2050)]
def date_to_integer(pr_fecha):
    if(pr_fecha == None):
        return -1
    else:
        return pr_fecha.year * 10000 + pr_fecha.month *100 + pr_fecha.day
#SUPERVISORES CORRECTO INCORRECTO


