# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Equity(models.Model):
    instrument_key = models.CharField(max_length=50)
    exchange_token = models.CharField(max_length=20)
    tradingsymbol = models.CharField(max_length=100)
    name = models.CharField(max_length=100)
    last_price = models.FloatField(blank=True, null=True)
    expiry = models.IntegerField(blank=True, null=True)
    strike = models.CharField(max_length=10, blank=True, null=True)
    tick_size = models.IntegerField(blank=True, null=True)
    lot_size = models.IntegerField(blank=True, null=True)
    instrument_type = models.CharField(max_length=20, blank=True, null=True)
    option_type = models.CharField(max_length=20, blank=True, null=True)
    exchange = models.CharField(max_length=20, blank=True, null=True)
    is_active = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'equity'
