import sys
from datetime import datetime
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from apps.common.datelib import current_date
from apps.users.models.user_app import UserApp
from apps.common.trader import client_login, generate_token
from django.urls import reverse
from django.db import DatabaseError
from django.core.cache import cache


def index(request):
    data = {
        "name" : "Welcome"
    }
    return render(request, 'users/index.html', data)

def user_login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user:
            login(request, user)
            if request.user.is_superuser :
                return redirect('/admin')
            else :
                return  redirect(reverse('api-login'))# Make sure 'home' exists in urls.py
        else:
            messages.error(request, "Invalid username or password.")

    data = {
        "name" : "Welcome"
    }
    return render(request, 'users/login.html', data)

def api_login(request):
    app = UserApp.objects.get(user_id = request.user.id)
    validatorUrl = client_login(app.client_id)
    return redirect(validatorUrl)

def create_token(request):
    try:
        print(request.user.id)
        app = UserApp.objects.get(user_id = 3)
        response = generate_token(request.GET.get("code"),app.client_id,app.client_secret)
        accessToken = response['access_token']
        app.access_token = accessToken
        app.last_used_at = current_date()
        app.save()
        cache.set('API_ACCESS_TOKEN',accessToken, timeout=60*60*24)
        return redirect(reverse('user-index'))
    except DatabaseError:
        messages.error(request, "Failed to generate token.")
        return render(request, 'users/index.html')
