from datetime import datetime
from apps.config.constants import Constants
from apps.systems.models.system_lookup import SystemLookup

DEMO = False

def get_system_lookup_value(lookup):
    sysModel = SystemLookup.objects.get(field_name=lookup)
    return sysModel.field_value

def get_last_run_date():
    lastRunDate = get_system_lookup_value(Constants.LAST_RUN_DATE)
    return lastRunDate

def current_date():
    if DEMO:
        result = datetime.strptime(get_last_run_date(), "%Y-%m-%d")
    else:
        result = datetime.today().strftime("%Y-%m-%d %H:%M:%S")
    return result

