from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import datetime
from apps.common.trader import get_history
from apps.equities.models.equity import Equity
from apps.equities.models.historical import Historical
from django.contrib.auth.models import User
from apps.users.models.user_app import UserApp


class Command(BaseCommand):
    message = "Loads history from database"
    def handle(self, *args, **options):
        # print(Historical._meta.get_field("equity").related_model)
        # self.stdout.write(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        # print(dir(Equity.objects.get(id=118).history.first()))
        # print (timezone.get_current_timezone())
        # print(UserApp._meta.get_field("user").related_model)
        # print(Equity.objects.get(id=118).history.first())
        print(User.objects.get(id=3).app.first())
        print(get_history())
