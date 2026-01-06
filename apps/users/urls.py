from django.urls import path
from . import views

urlpatterns = [
    path('index/', views.index, name='user-index'),
    path('login/', views.user_login, name='user-login'),
    path('api-login/', views.api_login, name='api-login'),
    path('generate-api-token/', views.create_token, name='generate-token'),
]