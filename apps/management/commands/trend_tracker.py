import sys
from datetime import timedelta

import pandas as pd
from django.core.management.base import BaseCommand
import talib
from apps.equities.models.equity import Equity
from apps.equities.models.historical import Historical
from apps.equities.models.lt_ob_zone import LtObZone
from apps.common.datelib import current_date,convert_date
from apps.common.dateformat import *
from apps.config.constants import Constants
from apps.equities.models.lt_td_position import LtTdPosition
from apps.common.trader import get_ohlc,get_history


class Command(BaseCommand):
    TEST = "My test Cmd"
    def handle(self, *args, **options):
        print(self.TEST)
        TYPE = 'EQ'
        PARAMS = {
            "EQ":{
                "MULTIFRAME":[
                    "D","1h","15min","5min"
                ]
            },
            "FO":{
                "MULTIFRAME": [
                    "5min", "3min", "1min"
                ]
            }
        }
        query = """
        SELECT pos.*,e.instrument_key,%s as today_date FROM equity e 
                              INNER JOIN (SELECT td.id,td.equity_id, td.value, td.created_at  
                                          FROM lt_td_position td WHERE td.id IN 
                                                                       (SELECT MAX(id) FROM lt_td_position WHERE created_at < %s AND position = %s GROUP BY equity_id) ) pos 
                                         ON (pos.equity_id = e.id AND e.instrument_type = %s)
        """
        params = [current_date(), current_date(), Constants.LOW, TYPE]
        results = LtTdPosition.objects.raw(query, params)
        for obj in results:
            ohlc = None
            obZoneModel = LtObZone.objects.filter(
                equity_id = obj.equity_id,
                zone_high__gte = obj.value,
                zone_low__lte = obj.value,
                created_at__lte = obj.created_at
            ).order_by('-created_at')

            previousHighs = LtTdPosition.objects.filter(
                equity_id = obj.equity_id,
                position=Constants.HIGH,
                created_at__lte = obj.created_at
            ).order_by('-created_at').values('value','created_at')

            ohlc = get_ohlc(obj.equity_id, current_date().strftime(DATE_FORMAT_YMD))

            df = pd.DataFrame(previousHighs)
            latestHigh = df.iloc[0]['value']
            latestHighDate = df.iloc[0]['created_at']
            df["high"] =  ohlc.high
            df["high_gap"] =  df["value"] - latestHigh
            df["close_gap"] = df["value"] - ohlc.close
            df["close_gap_per"] = ((df["value"] - ohlc.close)/ohlc.close) * 100
            # Get only the higher highs including the last high
            hhDf = df[(df["created_at"] == latestHighDate) | (df["high_gap"] > 0)]

            unit = 'minutes'
            interval = 1
            to_date = current_date().strftime(DATE_FORMAT_YMD)
            # from_date = obj.created_at.strftime(DATE_FORMAT_YMD)
            # to_date = (current_date() - timedelta(days=4)).strftime(DATE_FORMAT_YMD)
            from_date = (current_date() - timedelta(days=10)).strftime(DATE_FORMAT_YMD)
            history = get_history(instrument_key=obj.instrument_key,
                                  unit=unit,
                                  interval=interval,
                                  to_date=to_date,
                                  from_date=from_date)
            hisDf = pd.DataFrame(history)[::-1]
            hisDf = hisDf.rename(columns={
                0:'created_at',
                1:'open',
                2:'high',
                3:'low',
                4:'close',
                5:'volume'
            })
            # hisDf["created_at"] = hisDf[convert_date(hisDf["created_at"],DATE_FORMAT_YMDTHMSZ,DATE_FORMAT_YMDHMS)]
            hisDf['created_at'] = pd.to_datetime(hisDf['created_at'],format=DATE_FORMAT_YMDTHMSZ)
            hisDf = hisDf.sort_index()
            hisDf.set_index('created_at',inplace=True)
            hisDf = hisDf.between_time("09:15", "15:30")

            # for time in PARAMS["EQ"]["MULTIFRAME"]:
            multiframe = hisDf.resample('1D', origin='start_day', offset='9h15min').agg({
                'open':'first',
                'high':'max',
                'low':'min',
                'close':'last',
            }).dropna()
            talib.RSI
            print(multiframe)
