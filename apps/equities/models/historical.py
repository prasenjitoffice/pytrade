# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.db.models import PROTECT

from apps.equities.models.equity import Equity


class Historical(models.Model):
    equity = models.ForeignKey(
        Equity,
        db_column='equity_id',
        # on_delete=models.CASCADE,
        on_delete=PROTECT,
        related_name='history'  # ✅ now we have a clear reverse name
    )
    # equity_id = models.IntegerField()
    # market_date = models.DateField()
    open = models.FloatField()
    high = models.FloatField()
    low = models.FloatField()
    close = models.FloatField(blank=True, null=True)
    volume = models.BigIntegerField(blank=True, null=True)
    created_at = models.DateTimeField(primary_key=True, blank=True, null=False)
    updated_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'historical'
        unique_together = ("equity_id", "created_at")
