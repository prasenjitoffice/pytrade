import django.contrib.auth.models
from django.db import models
from django.contrib.auth.models import User
from apps.users.models.user_app import UserApp


class ApiLogs(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(User, models.DO_NOTHING, related_name="api_log")
    endpoint = models.CharField(max_length=255)
    http_status = models.IntegerField()
    response_time_ms = models.IntegerField(blank=True, null=True)
    error_message = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = "api_logs"
