import requests
import talib
import upstox_client
from django.shortcuts import redirect
from urllib.parse import quote
from django.http import JsonResponse
from upstox_client.rest import ApiException
from django.core.cache import cache
from scipy.signal import find_peaks

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

def get_access_tokn():
    return cache.get('API_ACCESS_TOKEN')

def get_configuration(sandbox = False):
    configuration = upstox_client.Configuration(sandbox)
    if sandbox:
        configuration.access_token = 'SANDBOX_ACCESS_TOKEN'
    else:
        configuration.access_token = get_access_tokn()
    return configuration

def get_history(instrument_key, unit, interval, to_date, from_date):
    response = None
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
    except ApiException as e:
        print("Exception:", e)
    return response.data.candles

def get_ema(array, timeperiod = 3):
    return talib.EMA(array, timeperiod=3)

def get_swing_hl(array,window = 3, low = False):
    inputArray = array
    if low:
        inputArray = -array
    swingHL, _ = find_peaks(array)
    # swing_HL_values = array[swingHL]
    return swingHL