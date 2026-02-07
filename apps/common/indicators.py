import numpy as np

DOJI_BODY = 0.2
AVG_CANDLE_HEIGHT = 0.3

def set_avg_body(h,l):
    range_ = h - l
    atr = range_.rolling(14).mean()
    global AVG_CANDLE_HEIGHT

def get_doji(o,h,l,c):
    body = (c - o).abs()
    range_ = h - l
    return np.where(body < DOJI_BODY * range_, 1, 0)

def is_bullish(o,c):
    return np.where(c > o,1,0)

def is_bearish(o, c):
    return np.where(c < o,1,0)

def candle_type(o,h,l,c):
    return np.where(get_doji(o,h,l,c),2,
             np.where(is_bullish(o,c),1,0),
    )

# def check_growth(df):


def is_proper_bullish(o,h,l,c):
    body = np.abs(c - o)
    range_ = h - l
    upper_wick = h - np.maximum(o, c)
    atr = range_.rolling(14).mean()
    print(atr)
    bullish = is_bullish(o=o,c=c)
    strong_body = body >= DOJI_BODY * atr
    small_upper_wick = upper_wick <= body     #upper wick less than half of body
    cond = bullish & strong_body & small_upper_wick
    return cond

def three_bullish_candle(o,h,l,c):
    cond = is_proper_bullish(o,h,l,c)
    return cond

def three_white_soldiers(o, h, l, c):
    cond = is_proper_bullish(o,h,l,c)
    # print(upper_wick, body,(0.5 * body))
    higher_closes = (
        (c > c.shift(1)) &
        (c.shift(1) > c.shift(2))
    )
    open_within_prev = (
        (o <= c.shift(1)) &
        (o >= o.shift(1))
    )
    # return np.where (cond & higher_closes & open_within_prev,1,0)
    return np.where (
        cond &
        cond.shift(1) &
        cond.shift(2) &
        higher_closes &
        open_within_prev
    , 1, 0)

def is_proper_bearish(o, h, l, c):
    body = np.abs(c - o)
    range_ = h - l
    lower_wick = np.minimum(o, c) - l
    atr = range_.rolling(14).mean()

    bearish = is_bearish(o=o, c=c)
    strong_body = body >= DOJI_BODY * atr
    small_lower_wick = lower_wick <= body

    return bearish & strong_body & small_lower_wick

def is_small_body(o, h, l, c):
    body = np.abs(c - o)
    range_ = h - l
    atr = range_.rolling(14).mean()
    return body <= 0.3 * atr

def evening_star(o, h, l, c):
    # Candle 1: strong bullish
    first = is_proper_bullish(o, h, l, c).shift(2)

    # Candle 2: small body / indecision
    second = is_small_body(o, h, l, c).shift(1)

    # Optional gap up (crypto often ignores gaps, so this is soft)
    gap_up = o.shift(1) > c.shift(2)

    # Candle 3: strong bearish
    third = is_proper_bearish(o, h, l, c)

    # Close into candle 1 body (at least halfway)
    close_into_first = c < (o.shift(2) + c.shift(2)) / 2

    return np.where(
        first &
        second &
        third &
        close_into_first
        # & gap_up   # enable if you trade gap-based markets
    , 1, 0)

