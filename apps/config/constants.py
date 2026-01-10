class Constants:
    # Exchange / Market
    NSE = "NSE"
    BSE = "BSE"
    NSE_EQUITY = "NSE_EQ"
    NSE_INDEX = "NSE_INDEX"
    NSE_FO = "NSE_FO"

    # Trend / Strategy Codes
    SHORT_TERM_TREND_CODE = "short-term"
    LONG_TERM_TREND_CODE = "long-term"
    SHORT_SELL_TREND_CODE = "short-sell"

    SHORT_TERM_STRATEGY_CODE = SHORT_TERM_TREND_CODE
    LONG_TERM_STRATEGY_CODE = LONG_TERM_TREND_CODE
    SHORT_SELL_STRATEGY_CODE = "short-sell"

    # Execution / Lifecycle Codes
    EXIT_CODE = "exit"
    WAITING_CODE = "waiting"
    QUEUE_CODE = "queued"
    RUNNING_CODE = "running"
    DISMISS_CODE = "withdrawn"  # remove without action

    # Stop Loss Codes
    LOWEST_SL_CODE = "lowest"
    NEAR_SL_CODE = "nearest_ma"
    MID_SL_CODE = "mid_ma"
    FAR_SL_CODE = "far_ma"
    EMA_SL_CODE = "ema"
    BODY_SL_CODE = "body_ma"
    UNKNOWN_SL_CODE = "unknown"
    TRAILING_SL_CODE = "trailing_sl"

    # Trend Tracking Keys
    UPTREND_START_AT = "_UPTREND_CHECKED"
    UPTREND_END_AT = "_UPTREND_END_AT"
    UPTREND_START_VALUE = "_UPTREND_START_CHECKED"
    UPTREND_END_VALUE = "_UPTREND_END_CHECKED"

    # Metrics / Flags
    GROWTH_PERCENTAGE = "GROWTH_PERCENTAGE"
    SKIPPED = "SKIPPED"
    TOTAL_RANGE = "TOTAL_RANGE"
    MISSED_ORDER = "ORDER_MISSED"
    LOWEST_VALUE = "_LOWEST_ORDER"
    THRESHOLD_VALUE = "_THRESHOLD_VALUE"
    WARNING_VALUE = "_WARNING_LEVEL"
    PRE_WARNING_VALUE = "_PRE_WARNING_LEVEL"
    FIBBO_LEVELS = "_FIBBO_LEVEL"

    ADDED_TO_ORDER_BOOK = "_ADDED_TO_ORDER_BOOK"
    IS_ADDED_TO_TRADE_BOOK = "_IS_ADDED_TO_TRADE_BOOK"

    # Order Placement
    ORDER_PLACED_INDICATOR = "_ORDER_PLACED"
    BUY_ORDER = "BUY"
    SELL_ORDER = "SELL"
    BUY_ORDER_PLACED = BUY_ORDER + ORDER_PLACED_INDICATOR
    SELL_ORDER_PLACED = SELL_ORDER + ORDER_PLACED_INDICATOR

    # Order Status
    PENDING_ORDER_STATUS = "pending"
    COMPLETE_ORDER_STATUS = "complete"
    FAILED_ORDER_STATUS = "failed"
    OPEN_ORDER_STATUS = "open"

    # Candle / Pattern
    GAP_UP = "gap_up"
    LONG_CANDLE = "long_candle"

    # Trend Direction
    BEARISH = "bearish"
    BULLISH = "bullish"

    # Job / Task Status
    STARTED = "Started"
    SUCCESS = "Success"
    COMPLETED = "Completed"
    FAILED = "Failed"
    ABORTED = "Aborted"
    REJECTED = "Rejected"
    RUNNING = "Running"

    # Trade / OHLC
    FIT_FOR_TRADE = "FIT_FOR_TRADE"
    OPEN = "open"
    HIGH = "high"
    LOW = "low"
    CLOSE = "close"

    # Schedule
    DAILY_AT = "dailyAt"

    # Intraday Indicators
    RSI_INTRADAY = "RSI_INTRADAY"
    LOW_LINE_TOUCH_INTRADAY = "FEET_INTRADAY"
    TAKE_OFF_INTRADAY = "TAKEOFF_INTRADAY"
    TAKE_OFF_VALUE_INTRADAY = "TAKEOFF_VALUE_INTRADAY"
    CLOSE_VALUE_INTRADAY = "CLOSE_VALUE_INTRADAY"
    ENTRY_VALUE_INTRADAY = "ENTRY_VALUE_INTRADAY"
    CURRENT_LEVEL_INTRADAY = "CURRENT_LEVEL_INTRADAY"

    #System Lookup
    LAST_RUN_DATE = 'LAST_RUN_DATE'
    INC_MINUTE = 'INC_TIME'
