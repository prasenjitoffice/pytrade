import sys
from datetime import timedelta

import pandas as pd
from django.core.management.base import BaseCommand
import talib
from numpy.core.defchararray import upper
import numpy as np
from apps.equities.models.equity import Equity
from apps.equities.models.historical import Historical
from apps.equities.models.lt_ob_zone import LtObZone
from apps.common.datelib import current_date,convert_date
from apps.common.dateformat import *
from apps.config.constants import Constants
from apps.equities.models.lt_td_position import LtTdPosition
from apps.common.trader import get_ohlc, get_history, get_patterns, get_db_history
# import pandas_ta as  ta
import apps.common.indicators as ind
import re

TYPE = 'EQ'
ORDER_TYPE = "CNC"
PARAMS = {
    "CNC": {
        "PAST_LIMIT":60,
        "MULTIFRAME": [
            "1D", "1h", "15min", "5min"
        ]
    },
    "MIS": {
        "PAST_LIMIT": 2,
        "MULTIFRAME": [
            "5min", "3min", "1min"
        ]
    }
}
ABBR = {
    "D": "days",
    "h": "hours",
    "min": "minutes"
}

def get_units(time):
    result = re.search('(\d+)(\w+)', time)
    interval = result.group(1)
    unitGroup = result.group(2)
    unit = ABBR[unitGroup]
    # unit = 'days'
    # interval = 1
    return [unit, interval]

def get_ob_zone(obj):
    return LtObZone.objects.filter(
        equity_id=obj.equity_id,
        zone_high__gte=obj.value,
        zone_low__lte=obj.value,
        created_at__lte=obj.created_at
    ).order_by('-created_at')


def get_previous_highs(obj):
    return LtTdPosition.objects.filter(
        equity_id=obj.equity_id,
        position=Constants.HIGH,
        created_at__lte=obj.created_at
    ).order_by('-created_at').values('value', 'created_at')


def fetch_history(obj, from_date, to_date, force_mis = False):
    if (ORDER_TYPE == "CNC") & (force_mis == False):
        history = get_db_history(equity_id=obj.equity_id,
                                 to_date=to_date,
                                 from_date=from_date)
        df = pd.DataFrame(history)
    else:
        unit, interval = get_units('1min')
        history = get_history(instrument_key=obj.instrument_key,
                              unit=unit,
                              interval=interval,
                              to_date=to_date,
                              from_date=from_date)
        df = pd.DataFrame(history)[::-1]

    df = df.rename(columns={
        0: 'created_at',
        1: 'open',
        2: 'high',
        3: 'low',
        4: 'close',
        5: 'volume'
    })
    df['created_at'] = pd.to_datetime(df['created_at'], format=DATE_FORMAT_YMDTHMSZ)
    # df = df.sort_index()
    df.set_index('created_at', inplace=True)
    return df

class Command(BaseCommand):
    TEST = "My test Cmd"
    def handle(self, *args, **options):
        print(self.TEST)
        query = """
        SELECT pos.*,e.instrument_key,%s as today_date FROM equity e 
                              INNER JOIN (SELECT td.id,td.equity_id, td.value, td.created_at  
                                          FROM lt_td_position td WHERE td.id IN 
                                                                       (SELECT MAX(id) FROM lt_td_position WHERE created_at < %s AND position = %s GROUP BY equity_id) ) pos 
                                         ON (pos.equity_id = e.id AND e.instrument_type = %s)
        """
        params = [current_date(), current_date(), Constants.LOW, TYPE]
        results = LtTdPosition.objects.raw(query, params)
        patterns = get_patterns(Constants.BULLISH)
        # unit, interval = get_units('1D')
        # print(unit,interval)
        # sys.exit()
        count = 1
        for obj in results:
            if obj.equity_id != 3957:
                continue
            breakOut = None
            preBreakOut = None
            moreBack = None
            ohlc = None
            obZoneModel = get_ob_zone(obj)
            previousHighs = get_previous_highs(obj)
            ohlc = get_ohlc(obj.equity_id, current_date().strftime(DATE_FORMAT_YMD))
            hdf = pd.DataFrame(previousHighs)
            latestHigh = hdf.iloc[0]['value']
            latestHighDate = hdf.iloc[0]['created_at']
            hdf["high_gap"] = hdf["value"] - latestHigh
            hdf = hdf[(hdf["created_at"] == latestHighDate) | (hdf["high_gap"] > 0)]
                            # hdf["high"] =  ohlc.high
            # hdf["high_gap"] =  hdf["value"] - latestHigh
            # hdf["close_gap"] = hdf["value"] - ohlc.close
            # hdf["close_gap_per"] = ((hdf["value"] - ohlc.close)/ohlc.close) * 100
            # # Get only the higher highs including the last high
            # hhhdf = hdf[(hdf["created_at"] == latestHighDate) | (hdf["high_gap"] > 0)]

            to_date = current_date().strftime(DATE_FORMAT_YMD)
            from_date = (current_date() - timedelta(days=PARAMS[ORDER_TYPE]["PAST_LIMIT"])).strftime(DATE_FORMAT_YMD)

            df = fetch_history(obj=obj,from_date=from_date,to_date=to_date)
            o = df["open"]
            h = df["high"]
            l = df["low"]
            c = df["close"]

            # df["created_at"] = df[convert_date(df["created_at"],DATE_FORMAT_YMDTHMSZ,DATE_FORMAT_YMDHMS)]
            # df['created_at'] = pd.to_datetime(df['created_at'],format=DATE_FORMAT_YMDTHMSZ)
            # # df = df.sort_index()
            # df.set_index('created_at',inplace=True)
            # df['candle'] = ind.candle_type(o,h,l,c)
            # df["prev_high"] = np.where(h.isin(df['value']),1,0)
            # df['doji'] = ind.get_doji(o,h,l,c)
            # df['tws'] = ind.three_white_soldiers(o,h,l,c)
            # df['es'] = ind.evening_star(o,h,l,c)
            # df['ema'] = talib.EMA(c.astype(float).values,20)
            # df["test"] = df.index[df["prev_high"].eq(1)].max()
            df["break_out"] = np.where( (ind.is_bullish(o=o,c=c) & (c > latestHigh) & (df.index.values > latestHighDate)), 1, 0)
            # df["exist"] = df.loc[df.index.values > latestHighDate,"break_out"].any()

            if df["break_out"].iloc[-1]:
                breakOut = df.iloc[-1]
                preBreakOut = df.iloc[-2]
                moreBack = df.iloc[-3] #this needs to be corrected
            mdf = None
            if (breakOut is not None) & (preBreakOut is not None):
                # breakOut.name/preBreakOut.name is the index name here i.e. created_at
                to_date = pd.to_datetime(breakOut.name,format=DATE_FORMAT_YMDTHMSZ).strftime(DATE_FORMAT_YMD)
                from_date = pd.to_datetime(moreBack.name,format=DATE_FORMAT_YMDTHMSZ).strftime(DATE_FORMAT_YMD)
                mdf = fetch_history(obj=obj,from_date=from_date, to_date=to_date,force_mis=True)

            if mdf is not None:
                secondTimeFrame = PARAMS[ORDER_TYPE]["MULTIFRAME"][1]
                mdf = mdf.between_time("09:15", "15:30")
                multiframe = mdf.resample(secondTimeFrame,label="left", closed="left", origin='start_day', offset='9h15min').agg({
                    'open':'first',
                    'high':'max',
                    'low':'min',
                    'close':'last',
                }).dropna()
                m_o = multiframe["open"]
                m_h = multiframe["high"]
                m_l = multiframe["low"]
                m_c = multiframe["close"]

                multiframe['ema_3'] = (talib.EMA(m_c.astype(float).values,3))
                multiframe['ema_3'] = round(multiframe['ema_3'],2)
                multiframe['candle'] = ind.candle_type(m_o, m_h, m_l, m_c)
                # multiframe['tws'] = ind.three_white_soldiers(m_o, m_h, m_l, m_c)
                # multiframe['es'] = ind.evening_star(m_o, m_h, m_l, m_c)
                multiframe['three_bullish'] = ind.three_bullish_candle(m_o, m_h, m_l, m_c)
                # multiframe['growth'] = ind.check_growth(multiframe)
                # multiframe['ema_3'] = ta.ema(df['close'], length=3).shift(1)
                junction = pd.concat([
                    multiframe.loc["2026-02-04"].tail(2),
                    multiframe.loc["2026-02-05"].head(2),
                ])
                print(multiframe)
            sys.exit()

            # multiframe["CDL3WHITESOLDIERS"] = getattr(talib,'CDL3WHITESOLDIERS')(multiframe["open"],multiframe["high"],multiframe["low"],multiframe["close"])
            # multiframe = multiframe[multiframe["CDL3WHITESOLDIERS"] != 0]
            # pd.set_option("display.max_rows", None)
            # pd.set_option("display.max_columns", None)
            # print(talib.get_functions())
            # for f in talib.get_functions():
            #     if f.startswith('CDL'):
            #         multiframe[f] = getattr(talib, f)(multiframe["open"],multiframe["high"],multiframe["low"],multiframe["close"])
            # sys.exit()
            # for pattern in patterns:
            #     multiframe[pattern.function_key.upper()] = getattr(talib,pattern.function_key.upper())(multiframe["open"],multiframe["high"],multiframe["low"],multiframe["close"])
            # print(multiframe.to_csv("multiframe.csv"))

            # pd.set_option("display.max_columns", None)
            # pd.set_option("display.max_rows", None)
            # print(multiframe)
