from datetime import datetime, timedelta
from django.core.management.base import BaseCommand
from apps.common import datelib
from apps.common.datelib import current_date
from django.utils import timezone
from apps.common.trader import get_history, get_ema, get_swing_hl
from django.contrib.auth.models import User
from apps.common.dateformat import *
from apps.config.constants import Constants
from apps.equities.models.equity import Equity
from apps.equities.models.historical import Historical
import pandas as pd
from scipy.signal import find_peaks

from apps.equities.models.lt_ob_zone import LtObZone


def get_historical_data(instrument_key, unit, interval, to_date, from_date):
    history = get_history(instrument_key=instrument_key,
                      unit=unit,
                      interval=interval,
                      to_date=to_date,
                      from_date=from_date)
    return history

class Command(BaseCommand):
    message = "Loads history from database"
    def handle(self, *args, **options):
        equities = Equity.objects.filter(id=118, instrument_type="EQ",exchange=Constants.NSE)
        to_date = datetime.today()
        from_date = to_date - timedelta(days=200)
        to_date = to_date.strftime(DATE_FORMAT_YMD)
        from_date = from_date.strftime(DATE_FORMAT_YMD)
        EMA_WINDOW = 3

        if equities is not None:
            for equity in equities:
                if equity.history.count() > 0:
                    last_added = equity.history.order_by('-market_date').first().market_date
                    from_date = last_added + timedelta(days=1)
                unit = "days"  # minutes | hours | days | weeks | months
                interval = 1  # string, not int
                histories = get_historical_data(equity.instrument_key, unit, interval, to_date, from_date)
                if histories is not None:
                    bulkData = []
                    for history in histories:
                        market_date = datelib.convert_date(history[0],current_format=DATE_FORMAT_YMDTHMSZ, new_format=DATE_FORMAT_YMD)
                        added_date = datelib.convert_date(history[0],current_format=DATE_FORMAT_YMDTHMSZ, new_format=DATE_FORMAT_YMDHMS)
                        bulkData.append(Historical(equity_id = equity.id,market_date = market_date, open=history[1], high = history[2], low = history[3], close = history[4], volume = history[5], created_at = added_date))
                    # Historical.objects.bulk_create(bulkData)
                    histories = histories[::-1]
                    df = pd.DataFrame(histories)
                    # df.columns = ['market_date','open','high','low','close','volume']
                    closes = df[4].to_numpy()
                    ema = get_ema(closes, EMA_WINDOW)
                    swingHigh = get_swing_hl(ema,EMA_WINDOW)
                    swingLow = get_swing_hl(-ema,EMA_WINDOW, True)
                    # print(ema[swingLow],df[0][swingLow])

                    # df["created_at"] = datelib.convert_date(df[0], current_format=DATE_FORMAT_YMDTHMSZ,new_format=DATE_FORMAT_YMDHMS)
                    df["P2_H"] = df[2].shift(2)
                    df["P2_L"] = df[3].shift(2)
                    df["Gap_Up"] = df[3] > df["P2_H"]
                    df["Gap_Down"] = df["P2_L"] > df[2]
                    obDf = df[df["Gap_Up"] | df["Gap_Down"]]

                    # if df["Gap_Up"] > 0:
                    #     df["OB_Model"] = df[LtObZone(equity_id=equity.id, zone_low=df["P2_H"], zone_high=df[3], irl_type=Constants.BULLISH, created_at=df["created_at"])]
                    #     df["Gap_Down"] = None
                    # if df["Gap_Down"] > 0:
                    #     df["OB_Model"] = None
                    #     df["Gap_Down"] = df[LtObZone(equity_id=equity.id, zone_low=df["P2_H"], zone_high=df[3], irl_type=Constants.BULLISH, created_at=df["created_at"])]

                    print(obDf)