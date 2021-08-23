from django.forms import ModelForm
import simplejson as json
from .models import Alechkpoint, Category,Staticparams
from datetime import datetime, timedelta 
import datetime as dt


######################################################################################################
##   FUNCIONES GENERALES
######################################################################################################
def last_day_of_month(date):
    if date.month == 12:
        return date.replace(day=31)
    return date.replace(month=date.month+1, day=1) - timedelta(days=1)

def date_to_integer(pr_fecha):
    if(pr_fecha == None):
        return -1
    else:
        return pr_fecha.year * 10000 + pr_fecha.month *100 + pr_fecha.day

def hour_to_integer(pr_hourSTR):

    if(pr_hourSTR == None):
       return -1

    hourSTR=pr_hourSTR.split(":")    
    return int(hourSTR[0] + hourSTR[1])

def datestr_to_integer(pr_fechaSTR):

    if(pr_fechaSTR == None):
       return -1

    fechaSTR=pr_fechaSTR.split("-")    
    return int(fechaSTR[0] + fechaSTR[1] + fechaSTR[2])

def hourstr_to_integer(pr_hourSTR):

    if(pr_hourSTR == None):
       return -1

    hourSTR=pr_hourSTR.split(":")    
    return int(hourSTR[0] + hourSTR[1])

######################################################################################################
##   CLASIFICACIONES GENERALES
######################################################################################################

HOUR_CHOICES  = [(x, '{:02d}:00'.format(x)) for x in range(0, 24)]
HOUR_CHOICES2 = [(x, '{:02d}:59'.format(x)) for x in range(0, 24)]
HOUR_CHOICES3 = [(x*10000, '{:02d}:00'.format(x)) for x in range(0, 24)]
HOUR_CHOICES4 = [(x*10000, '{:02d}:59'.format(x)) for x in range(0, 24)]

PERCENT_CHOICES =  [(x, '{:d}%'.format(x)) for x in range(0, 101)] #que incluya el 100%
WAIT_CHOICES =  [(x*60, '{:02d}'.format(x)) for x in range(0, 101)] #que incluya el 100%

HOUR_CHOICESdt  = [(None, '------')] + [(dt.time(hour=x), '{:02d}:00'.format(x)) for x in range(0, 24)]
HOUR_CHOICESdt2 = [(None, '------')] + [(dt.time(hour=x, minute = 59), '{:02d}:59'.format(x)) for x in range(0, 24)]


Month_choice = [(1,'ENERO'),(2,'FEBRERO'),(3,'MARZO'),(4,'ABRIL'),(5,'MAYO'),(6,'JUNIO'),
                (7,'JULIO'),(8,'AGOSTO'),(9,'SEPTIEMBRE'),(10,'OCTUBRE'),(11,'NOVIEMBRE'),(12,'DICIEMBRE')]

Year_choice = [(x, '{:04d}'.format(x)) for x in range(2020, 2050)]

EsBitacora_choice = [('ENVIADO','Enviado'),('ERROR','Error')]

LateDays_choice = [(1,'1 Day'),(2,'2 Days'),(3,'3 Days'),(4,'4 Days'),(5,'5 Days'),(6,'6 Days'),
                (7,'7 Days'),(8,'8 Days'),(9,'9 Days'),(10,'10 Days'),(11,'11+ Days')]


def chkpoint_choices():
    vchkpoint_choices = tuple(Alechkpoint.objects.values_list('idchkpoint','descripicion').filter(estadologico = 0,estado = 'ACTIVO').distinct())
    return vchkpoint_choices

def id_PV001():
    vid_PV001 = Category.objects.values_list('id', flat=True).filter(parent = None, code = 'PV001')
    return vid_PV001

def PV_Choices():
    vid_PV001 = id_PV001()
    if(vid_PV001.count() >0):
        vPV_Choices =  tuple(Category.objects.values_list('title','title').filter(parent_id=vid_PV001[0]).distinct())
    else:
        vPV_Choices = [(None, '------')]
    return vPV_Choices

def PV_Category():
    vid_PV001 = id_PV001()
    if(vid_PV001.count() >0):
        vPV_Category =  Category.objects.filter(parent_id=vid_PV001[0]).all()
    else:
        vPV_Category = None

    return vPV_Category


def id_LC001():
    vid_LC001 = Category.objects.values_list('id', flat=True).filter(parent = None, code = 'LC001')
    return vid_LC001 

def LC_Choices():
    vid_LC001 = id_LC001()
    if(vid_LC001.count() >0):
        vLC_Choices = tuple(Category.objects.values_list('code','title').filter(parent_id=vid_LC001[0]).distinct())
    else:
        vLC_Choices = [(None, '------')]
    return vLC_Choices 

def id_MN001():
    vid_MN001 = Category.objects.values_list('id', flat=True).filter(parent = None, code = 'MN001')
    return vid_MN001 

def MN_Choices():
    vid_MN001 = id_MN001()
    if(vid_MN001.count() >0):
       vMN_Choices = tuple(Category.objects.values_list('code','title').filter(parent_id=vid_MN001[0]).distinct())
    else:
       vMN_Choices = [(None, '------')]
    return vMN_Choices

def id_CP001():
    vid_CP001 = Category.objects.values_list('id', flat=True).filter(parent = None, code = 'CP001')
    return vid_CP001

def CP_Choices():
    vid_CP001 = id_CP001()
    if(vid_CP001.count() >0):
       vCP_Choices = tuple(Category.objects.values_list('code','title').filter(parent_id=vid_CP001[0]).distinct())
    else:
       vCP_Choices = [(None, '------')]
    return vCP_Choices

def id_USA001():
    vid_USA001 = Category.objects.values_list('id', flat=True).filter(parent = None, code = 'USA001')
    return vid_USA001

def USA_Choices():
    vid_USA001 = id_USA001()
    if(vid_USA001.count() >0):
       vUSA_Choices = tuple(Category.objects.values_list('code','title').filter(parent_id=vid_USA001[0]).distinct())
    else:
       vUSA_Choices = [(None, '------')]
    return vUSA_Choices

class DatetimeEncoder(json.JSONEncoder):
    def default(self, obj):
        try:
            return super().default(obj)
        except TypeError:
            return str(obj)

def id_MOD001():
    vid_MOD001 = Category.objects.values_list('id', flat=True).filter(parent = None, code = 'MOD001')
    return vid_MOD001

def MOD_Choices():
    vid_MOD001 = id_MOD001()
    if(vid_MOD001.count() >0):
       vMOD_Choices = tuple(Category.objects.values_list('code','title').filter(parent_id=vid_MOD001[0]).distinct())
    else:
       vMOD_Choices = [(None, '------')]
    return vMOD_Choices

from django.contrib.auth import get_user_model
def USR_Choices():
    user = get_user_model()
    vUSR_Choices = tuple(user.objects.values_list('id','username'))
    return vUSR_Choices

def get_LatestShipdate_MaxSKU():
    vLS_MaxSKU = Staticparams.objects.values_list('valint', flat=True).filter(modulo='LShipdate', nombre='MaxSKU').last()
    if(vLS_MaxSKU):
        return vLS_MaxSKU
    else:    
        return 0
