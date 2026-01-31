import sys
from datetime import datetime, timedelta
from typing import Dict, Any

import dateutil
import numpy as np
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
from apps.equities.models.lt_td_position import LtTdPosition


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
        ids = [118]
        filters: Dict[str, Any] = {
            "instrument_type":"EQ",
            "exchange":Constants.NSE
        }
        if len(ids):
            filters["id__in"] = ids
        # equities = Equity.objects.filter(id__in=[118], instrument_type="EQ",exchange=Constants.NSE)
        equities = Equity.objects.filter(**filters)
        EMA_WINDOW = 3

        if equities is not None:
            for equity in equities:
                obBulkData = []
                to_date = datetime.today()
                from_date = to_date - timedelta(days=200)
                from_date = from_date.strftime(DATE_FORMAT_YMD)
                to_date = to_date.strftime(DATE_FORMAT_YMD)

                if equity.history.count() > 0:
                    last_added = equity.history.filter(equity_id=equity.id).order_by('-market_date').first().market_date
                    from_date = last_added + timedelta(days=1)
                # sys.exit()
                unit = "days"  # minutes | hours | days | weeks | months
                interval = 1  # string, not int
                histories = get_historical_data(equity.instrument_key, unit, interval, to_date, from_date)
                if len(histories) > 0:
                    self.stdout.write(self.style.SUCCESS(f"{equity.tradingsymbol} history is getting loaded..."))
                    zoneModel = LtObZone()
                    bulkData = []
                    for history in histories:
                        # market_date = datelib.convert_date(history[0],current_format=DATE_FORMAT_YMDTHMSZ, new_format=DATE_FORMAT_YMD)
                        added_date = datelib.convert_date(history[0],current_format=DATE_FORMAT_YMDTHMSZ, new_format=DATE_FORMAT_YMDHMS)
                        bulkData.append(Historical(equity_id = equity.id, open=history[1], high = history[2], low = history[3], close = history[4], volume = history[5], created_at = added_date,updated_at=current_date(True)))
                    Historical.objects.bulk_create(bulkData)

                    self.stdout.write(self.style.SUCCESS(f" - Histories added successfully"))
                    self.stdout.write(self.style.SUCCESS(f" - Positions are loading..."))
                    histories = histories[::-1]
                    df = pd.DataFrame(histories)
                    # sys.exit()
                    closes = df[4].to_numpy()
                    dfData = df.to_numpy()
                    ema = get_ema(closes, EMA_WINDOW)
                    swingHigh = get_swing_hl(ema,EMA_WINDOW)
                    swingLow = get_swing_hl(-ema,EMA_WINDOW, True)
                    swingData = np.sort(np.concatenate((swingHigh,swingLow)))
                    ltPosCount = LtTdPosition.objects.filter(equity_id=equity.id).count()
                    ltPosLastAdded = datetime.today()
                    if ltPosCount > 0:
                        ltPosLastAdded = LtTdPosition.objects.filter(equity_id=equity.id).order_by('-created_at').first().created_at
                    ltPosBulkData = []
                    for index in swingData:
                        item = dfData[index]
                        added_date = datelib.replace_tz(item[0],DATE_FORMAT_YMDTHMSZ)
                        deletedAt = current_date()
                        if (added_date <= ltPosLastAdded) & (ltPosCount > 0):
                            continue
                        posType = Constants.LOW
                        posValue = item[3]
                        if np.any(swingHigh == index):
                            posType = Constants.HIGH
                            posValue = item[2]
                        # Last item should be active else deleted
                        if np.isin(index, [swingHigh[-1],swingLow[-1]]):
                            deletedAt = None
                        ltPosBulkData.append(LtTdPosition(equity_id = equity.id,position=posType,value=posValue,created_at=added_date,updated_at=current_date(True), deleted_at=deletedAt))
                    if len(ltPosBulkData) == 1:
                        LtTdPosition.objects.filter(position=ltPosBulkData[0].position,equity_id=equity.id).update(deleted_at=current_date())
                    LtTdPosition.objects.bulk_create(ltPosBulkData)

                    self.stdout.write(self.style.SUCCESS(f" - Detecting OB Zone..."))
                    obBulkData = zoneModel.get_ob_zone(equity_id=equity.id,df=df)
                    LtObZone.objects.bulk_create(obBulkData)
                    self.stdout.write(self.style.SUCCESS(f" - History added successfully..."))
                else:
                    self.stdout.write(self.style.ERROR(f"{equity.tradingsymbol} no history to load..."))
