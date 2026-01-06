# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.db.models import PROTECT
from django.contrib.auth.models import User



class UserApp(models.Model):
    user = models.ForeignKey(
        User,
        db_column='user_id',
        on_delete=PROTECT,
        related_name='app'
    )

    id = models.CharField(primary_key=True, max_length=36)
    broker = models.CharField(max_length=50)
    client_id = models.CharField(max_length=64)
    client_secret = models.CharField(max_length=20)
    access_token = models.TextField()
    is_active = models.IntegerField(blank=True, null=True)
    account_type = models.CharField(max_length=10)
    last_used_at = models.DateTimeField(blank=True, null=True)
    expires_at = models.DateTimeField(blank=True, null=True)
    revoked_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'user_app'
        unique_together = (('user_id', 'broker'),)
