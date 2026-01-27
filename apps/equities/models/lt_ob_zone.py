# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from datetime import datetime
from typing import Any

from django.db import models
from apps.common import datelib
from apps.common.dateformat import *
from apps.config.constants import Constants

from apps.common.datelib import current_date


class LtObZone(models.Model):

    equity_id = models.IntegerField()
    zone_low = models.FloatField()
    zone_high = models.FloatField()
    irl_type = models.CharField(max_length=20)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    deleted_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'lt_ob_zone'

    def soft_delete(self):
        self.deleted_at = current_date()
        self.save()

    def get_ob_zone(self,equity_id,df):
        obBulkData = []
        # df["created_at"] = datelib.convert_date(df[0], current_format=DATE_FORMAT_YMDTHMSZ,new_format=DATE_FORMAT_YMDHMS)
        df["P2_H"] = df[2].shift(2)
        df["P2_L"] = df[3].shift(2)
        df["Gap_Up"] = df[3] > df["P2_H"]
        df["Gap_Down"] = df["P2_L"] > df[2]
        obDf = df[df["Gap_Up"] | df["Gap_Down"]]
        obData = obDf.to_numpy()
        for ob in obData:
            added_on = datelib.convert_date(ob[0], current_format=DATE_FORMAT_YMDTHMSZ, new_format=DATE_FORMAT_YMDHMS)
            if LtObZone.objects.filter(equity_id=equity_id).count() > 0:
                lastAddedDate = LtObZone.objects.filter(equity_id=equity_id).order_by('-created_at').first().created_at
                dt = datelib.replace_tz(ob[0], DATE_FORMAT_YMDTHMSZ)
                if dt <= lastAddedDate:
                    continue
            if ob[9]:
                obBulkData.append(LtObZone(equity_id=equity_id, zone_high=ob[3], zone_low=ob[7],
                                           irl_type=Constants.BULLISH, created_at=added_on,
                                           updated_at=current_date(True)))
            elif ob[10]:
                obBulkData.append(LtObZone(equity_id=equity_id, zone_high=ob[8], zone_low=ob[2],
                                           irl_type=Constants.BEARISH, created_at=added_on,
                                           updated_at=current_date(True)))
        return obBulkData