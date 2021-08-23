"""
Definition of models.
"""

from django.db import models
from .fields import *

# Create your models here.
class Tablaprueba(models.Model):
    idregistro = models.BigAutoField(db_column='IdRegistro',primary_key=True)  # Field name made lowercase.
    tipo       = models.IntegerField(blank=True, null=True)
    nombre     = models.CharField(max_length=20, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tablaPrueba'

TipoLote = [
    (12,"New/Rejected")
]

EstadoLote = [
    (0,"No Disponible"),
    (1,'Generado'),
    (2,"Asignado"),
    (3,'Cerrado'),
    (4,'Revisado')
]

EstadoLoteDetalle = [
    (0,"Sin asignar"),
    (1,'Asignado'),
    (2,"Pendiente de revisar"),
    (3,'Revisado'),
    (4,'Rechazado')
]

EstadoMatch = [
    (0,"No determinado"),
    (1,'Match'),
    (2,"Missmatch")
]

class hdBatch(models.Model):
    id          = models.BigAutoField(db_column='Id', max_length=4,primary_key=True)  # Field name made lowercase.
    codigo      = models.CharField(db_column='codigo',max_length=20, blank=True, null=True)
    descripcion = models.CharField(db_column='descripcion',max_length=60, blank=True, null=True)
    usuario     = models.IntegerField(db_column='usuario', choices=USER_CHOICES)
    fechahora   = models.DateTimeField(db_column='fechahora',max_length=8, blank=True, null=True)
    tipo        = models.IntegerField(db_column='tipo', choices=TipoLote)
    status      = models.IntegerField(db_column='status', choices=EstadoLote)
    porcentajesimilitud =  models.FloatField(db_column='porcentajeSimilitud')

    class Meta:
        managed = False
        db_table = 'hdbatch'

class dtBatch(models.Model):
    id          = models.BigAutoField(db_column='Id', max_length=4,primary_key=True)  # Field name made lowercase.
    batchid     = models.IntegerField(db_column='batchId', blank=True, null=True)
    saleslisting = models.CharField(db_column='salesListing',max_length=64, blank=True, null=True)
    asin     = models.CharField(db_column='asin',max_length=64, blank=True, null=True)
    upc   = models.FloatField(db_column='upc',max_length=8, blank=True, null=True)
    sku        = models.CharField(db_column='sku',max_length=64, blank=True, null=True)
    status      = models.IntegerField(db_column='status', blank=True, null=True, choices=EstadoLoteDetalle)
    answers        = models.CharField(db_column='answers',max_length=64, blank=True, null=True)
    matchstatus      = models.IntegerField(db_column='matchStatus', blank=True, null=True,choices=EstadoMatch)
    operador        = models.CharField(db_column='operador',max_length=20, blank=True, null=True, choices=USER_CHOICES)
    porcentajesimilitud =  models.FloatField(db_column='porcentajeSimilitud')
    fecharealizado   = models.DateField(db_column='fechaRealizado',max_length=8, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dtbatch'

class preguntas(models.Model):
    id          = models.BigAutoField(db_column='Id', max_length=4,primary_key=True)  # Field name made lowercase.
    textual     = models.CharField(db_column='Textual',max_length=512, blank=True, null=True)
    respposibles = models.CharField(db_column='RespPosibles',max_length=5, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'questions'

