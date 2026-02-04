import talib
from django.core.management.base import BaseCommand
from apps.users.models.user_app import UserApp
from django.utils import timezone
from datetime import datetime
from apps.equities.models.equity import Equity
from apps.equities.models.historical import Historical
from apps.common.datelib import *
from  django.core.cache import cache
import pandas as pd
import pandas_ta as ta
import warnings
import yfinance as yf

class Command(BaseCommand):

    TEST = "My test Cmd"
    def handle(self, *args, **options):
        warnings.filterwarnings("ignore", category=UserWarning)
        print(ta)
        # print(Historical._meta.get_field("equity").related_model)
        # self.stdout.write(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        # print(dir(Equity.objects.get(id=118).history.first()))
        # print (timezone.get_current_timezone())
        # print(UserApp._meta.get_field("user").related_model)
        # print(Equity.objects.get(id=118).history.first())
        # print(cache.get('API_ACCESS_TOKEN'))
        # cache.set('API_ACCESS_TOKEN','khjkh', timeout=60*60*24)
        df = yf.download("RELIANCE.NS",
                         period="1y",
                         interval="1d")
        print(df.dtypes)
        # tolerance = 0.002  # 0.1% difference
        # df['doji1'] = abs(df['Open'] - df['Close']) <= (df['Close'] * tolerance)
        # df['TWS'] = talib.CDL3WHITESOLDIERS(df['Open'], df['High'], df['Low'], df['Close'])
        #
        # df_new= df[(df.index >= pd.to_datetime("2025-12-31")) & (df.index <= pd.to_datetime("2026-01-02"))]
        # df_new["ths"] = (df["Open"] > df["Close"]) & (df["Open"].shift(1) > df["Close"].shift(1)) & (df["Open"].shift(2) < df["Close"].shift(2))
        #                 & (df["Open"] > df["Open"])
        print(df)
