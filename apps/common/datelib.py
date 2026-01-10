from datetime import datetime
from django.utils import timezone
from apps.config.constants import Constants
from apps.systems.models.system_lookup import SystemLookup

DEMO = True

def get_system_lookup_value(lookup):
    sysValue = {}
    sysModel = SystemLookup.objects.filter(field_name__in = lookup).values("field_name","field_value")

    for item in sysModel:
        sysValue[item["field_name"]] = item["field_value"]
    return sysValue

def get_last_run_date():
    lastRunModel = get_system_lookup_value([Constants.LAST_RUN_DATE,Constants.INC_MINUTE])
    result = datetime.strptime(lastRunModel[Constants.LAST_RUN_DATE], "%Y-%m-%d")
    minutes = int(result.timestamp() / 60) + 555 + int(lastRunModel[Constants.INC_MINUTE])
    newDate = result.fromtimestamp(minutes * 60)
    return newDate

def current_date(force = False):
    if force:   #it will return current date
        return datetime.today().strftime("%Y-%m-%d %H:%M:%S")

    if DEMO:
        result = get_last_run_date()
    else:
        result = datetime.today().strftime("%Y-%m-%d %H:%M:%S")
    timezone.make_aware(result)
    return result

def convert_date(value, current_format, new_format):
    new_date = datetime.strptime(value, current_format)
    return new_date.strftime(new_format)