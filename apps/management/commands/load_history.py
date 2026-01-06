from django.core.management.base import BaseCommand
from apps.common.trader import get_history
from django.contrib.auth.models import User


class Command(BaseCommand):
    message = "Loads history from database"
    def handle(self, *args, **options):

        instrument_key = "NSE_EQ|INE848E01016"
        unit = "days"  # minutes | hours | days | weeks | months
        interval = 1  # string, not int
        to_date = "2025-03-22"
        from_date = "2025-01-01"

        print(get_history(instrument_key=instrument_key,
                          unit=unit,
                          interval=interval,
                          to_date=to_date,
                          from_date=from_date))

        print(User.objects.get(id=3).app.first())

