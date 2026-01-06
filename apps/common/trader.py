import requests
import upstox_client
from django.shortcuts import redirect
from urllib.parse import quote
from django.http import JsonResponse
from upstox_client.rest import ApiException

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

def get_configuration(sandbox = False):
    configuration = upstox_client.Configuration(sandbox)
    if sandbox:
        configuration.access_token = 'SANDBOX_ACCESS_TOKEN'
    else:
        configuration.access_token = 'PROD_ACCESS_TOKEN'
    return configuration

def get_history(instrument_key, unit, interval, to_date, from_date):
    configuration = get_configuration()
    api_instance = upstox_client.HistoryV3Api(upstox_client.ApiClient(configuration))
    try:
        response = api_instance.get_historical_candle_data1(
            instrument_key=instrument_key,
            unit=unit,
            interval=interval,
            to_date=to_date,
            from_date=from_date
        )
        print(response.data.candles)
    except ApiException as e:
        print("Exception:", e)
