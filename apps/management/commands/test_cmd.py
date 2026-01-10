from django.core.management.base import BaseCommand
from apps.users.models.user_app import UserApp
from django.utils import timezone
from datetime import datetime
from apps.equities.models.equity import Equity
from apps.equities.models.historical import Historical
from apps.common.datelib import *
from  django.core.cache import cache

class Command(BaseCommand):

    TEST = "My test Cmd"
    def handle(self, *args, **options):
        print(self.TEST)
        # print(Historical._meta.get_field("equity").related_model)
        # self.stdout.write(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        # print(dir(Equity.objects.get(id=118).history.first()))
        # print (timezone.get_current_timezone())
        # print(UserApp._meta.get_field("user").related_model)
        # print(Equity.objects.get(id=118).history.first())
        print(cache.get('API_ACCESS_TOKEN'))
        # cache.set('API_ACCESS_TOKEN','khjkh', timeout=60*60*24)

