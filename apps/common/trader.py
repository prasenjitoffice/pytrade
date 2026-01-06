import requests
import upstox_client
from django.shortcuts import redirect
from urllib.parse import quote
from django.http import JsonResponse

API_LOGIN_URL = "https://api-v2.upstox.com/login/authorization/dialog"

API_REDIRECT_URL = "http://localhost:8000/user/generate-api-token"

API_TOKEN_URL = "https://api.upstox.com/v2/login/authorization/token"

def client_login(apiKey):
    rUrl = quote(API_REDIRECT_URL)
    validatorUrl = f"{API_LOGIN_URL}?response_type=code&client_id={apiKey}&redirect_uri={rUrl}"
    return validatorUrl

def generate_token(code, client_id, client_secret):
    redirectUrl = API_REDIRECT_URL
    payload = {
        "code": code,
        "client_id": client_id,
        "client_secret": client_secret,
        "redirect_uri": redirectUrl,
        "grant_type": "authorization_code"
    }
    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }
    response = requests.post(API_TOKEN_URL, data=payload, headers=headers)
    return response.json()

    # return {'email': 'prasenjitbanik2021@gmail.com', 'exchanges': ['NFO', 'BSE', 'BCD', 'BFO', 'MCX', 'NSE', 'CDS'],
    #  'products': ['OCO', 'D', 'CO', 'I'], 'broker': 'UPSTOX', 'user_id': 'JS5910', 'user_name': 'PRASENJIT BANIK',
    #  'order_types': ['MARKET', 'LIMIT', 'SL', 'SL-M'], 'user_type': 'individual', 'poa': False, 'ddpi': False,
    #  'is_active': True,
    #  'access_token': 'eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiJKUzU5MTAiLCJqdGkiOiI2OTVhODBmNTNiNDVkZTM4MjdjZGEzNmMiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc2NzUzODkzMywiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzY3NTY0MDAwfQ.6164e0kOovKJBuv6XcI97N7sSko4tGAv5G6ep6JGWQA',
    #  'extended_token': None}