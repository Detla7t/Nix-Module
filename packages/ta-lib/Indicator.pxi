cimport numpy as np
from numpy import nan
from cython import boundscheck, wraparound

# _ta_check_success: defined in _common.pxi

cdef double NaN = nan

cdef extern from "numpy/arrayobject.h":
    int PyArray_TYPE(np.ndarray)
    np.ndarray PyArray_EMPTY(int, np.npy_intp*, int, int)
    int PyArray_FLAGS(np.ndarray)
    np.ndarray PyArray_GETCONTIGUOUS(np.ndarray)

np.import_array() # Initialize the NumPy C API

cimport _ta_lib as lib
from _ta_lib cimport TA_RetCode

cdef np.ndarray check_array(np.ndarray real):
    if PyArray_TYPE(real) != np.NPY_DOUBLE:
        raise Exception("input array type is not double")
    if real.ndim != 1:
        raise Exception("input array has wrong dimensions")
    if not (PyArray_FLAGS(real) & np.NPY_ARRAY_C_CONTIGUOUS):
        real = PyArray_GETCONTIGUOUS(real)
    return real

cdef np.npy_intp check_length2(np.ndarray a1, np.ndarray a2) except -1:
    cdef:
        np.npy_intp length
    length = a1.shape[0]
    if length != a2.shape[0]:
        raise Exception("input array lengths are different")
    return length

cdef np.npy_intp check_length3(np.ndarray a1, np.ndarray a2, np.ndarray a3) except -1:
    cdef:
        np.npy_intp length
    length = a1.shape[0]
    if length != a2.shape[0]:
        raise Exception("input array lengths are different")
    if length != a3.shape[0]:
        raise Exception("input array lengths are different")
    return length

cdef np.npy_intp check_length4(np.ndarray a1, np.ndarray a2, np.ndarray a3, np.ndarray a4) except -1:
    cdef:
        np.npy_intp length
    length = a1.shape[0]
    if length != a2.shape[0]:
        raise Exception("input array lengths are different")
    if length != a3.shape[0]:
        raise Exception("input array lengths are different")
    if length != a4.shape[0]:
        raise Exception("input array lengths are different")
    return length

cdef np.npy_int check_begidx1(np.npy_intp length, double* a1):
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        return i
    else:
        return length - 1

cdef np.npy_int check_begidx2(np.npy_intp length, double* a1, double* a2):
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        val = a2[i]
        if val != val:
            continue
        return i
    else:
        return length - 1

cdef np.npy_int check_begidx3(np.npy_intp length, double* a1, double* a2, double* a3):
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        val = a2[i]
        if val != val:
            continue
        val = a3[i]
        if val != val:
            continue
        return i
    else:
        return length - 1

cdef np.npy_int check_begidx4(np.npy_intp length, double* a1, double* a2, double* a3, double* a4):
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        val = a2[i]
        if val != val:
            continue
        val = a3[i]
        if val != val:
            continue
        val = a4[i]
        if val != val:
            continue
        return i
    else:
        return length - 1

cdef np.ndarray make_double_array(np.npy_intp length, int lookback):
    cdef:
        np.ndarray outreal
        double* outreal_data
    outreal = PyArray_EMPTY(1, &length, np.NPY_DOUBLE, np.NPY_ARRAY_DEFAULT)
    outreal_data = <double*>outreal.data
    for i from 0 <= i < min(lookback, length):
        outreal_data[i] = NaN
    return outreal

cdef np.ndarray make_int_array(np.npy_intp length, int lookback):
    cdef:
        np.ndarray outinteger
        int* outinteger_data
    outinteger = PyArray_EMPTY(1, &length, np.NPY_INT32, np.NPY_ARRAY_DEFAULT)
    outinteger_data = <int*>outinteger.data
    for i from 0 <= i < min(lookback, length):
        outinteger_data[i] = 0
    return outinteger

def AD( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , np.ndarray volume not None ):
    """ AD(high, low, close, volume)

    Chaikin A/D Line (Volume Indicators)

    Inputs:
        prices: ['high', 'low', 'close', 'volume']
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    volume = check_array(volume)
    length = check_length4(high, low, close, volume)
    begidx = check_begidx4(length, <double*>(high.data), <double*>(low.data), <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_AD_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AD( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AD", retCode)
    return outreal 

def ADX( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ ADX(high, low, close[, timeperiod=?])

    Average Directional Movement Index (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ADX_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADX( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADX", retCode)
    return outreal 

def ADXR( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ ADXR(high, low, close[, timeperiod=?])

    Average Directional Movement Index Rating (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ADXR_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADXR( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADXR", retCode)
    return outreal 

def AROON( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ AROON(high, low[, timeperiod=?])

    Aroon (Momentum Indicators)

    Inputs:
        prices: ['high', 'low']
    Parameters:
        timeperiod: 14
    Outputs:
        aroondown
        aroonup
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outaroondown
        np.ndarray outaroonup
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_AROON_Lookback( timeperiod )
    outaroondown = make_double_array(length, lookback)
    outaroonup = make_double_array(length, lookback)
    retCode = lib.TA_AROON( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outaroondown.data)+lookback , <double *>(outaroonup.data)+lookback )
    _ta_check_success("TA_AROON", retCode)
    return outaroondown , outaroonup 

def ATR( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ ATR(high, low, close[, timeperiod=?])

    Average True Range (Volatility Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ATR_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ATR( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ATR", retCode)
    return outreal 

def BBANDS( np.ndarray real not None , int timeperiod=-2**31 , double nbdevup=-4e37 , double nbdevdn=-4e37 , int matype=0 ):
    """ BBANDS(real[, timeperiod=?, nbdevup=?, nbdevdn=?, matype=?])

    Bollinger Bands (Overlap Studies)

    Inputs:
        real: (any ndarray)
    Parameters:
        timeperiod: 5
        nbdevup: 2.0
        nbdevdn: 2.0
        matype: 0 (Simple Moving Average)
    Outputs:
        upperband
        middleband
        lowerband
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outrealupperband
        np.ndarray outrealmiddleband
        np.ndarray outreallowerband
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_BBANDS_Lookback( timeperiod , nbdevup , nbdevdn , matype )
    outrealupperband = make_double_array(length, lookback)
    outrealmiddleband = make_double_array(length, lookback)
    outreallowerband = make_double_array(length, lookback)
    retCode = lib.TA_BBANDS( 0 , endidx , <double *>(real.data)+begidx , timeperiod , nbdevup , nbdevdn , matype , &outbegidx , &outnbelement , <double *>(outrealupperband.data)+lookback , <double *>(outrealmiddleband.data)+lookback , <double *>(outreallowerband.data)+lookback )
    _ta_check_success("TA_BBANDS", retCode)
    return outrealupperband , outrealmiddleband , outreallowerband 

def DX( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ DX(high, low, close[, timeperiod=?])

    Directional Movement Index (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_DX_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_DX( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_DX", retCode)
    return outreal 

def IMI( np.ndarray open not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ IMI(open, close[, timeperiod=?])

    Intraday Momentum Index (Momentum Indicators)

    Inputs:
        prices: ['open', 'close']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    open = check_array(open)
    close = check_array(close)
    length = check_length2(open, close)
    begidx = check_begidx2(length, <double*>(open.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_IMI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_IMI( 0 , endidx , <double *>(open.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_IMI", retCode)
    return outreal 

def MACD( np.ndarray real not None , int fastperiod=-2**31 , int slowperiod=-2**31 , int signalperiod=-2**31 ):
    """ MACD(real[, fastperiod=?, slowperiod=?, signalperiod=?])

    Moving Average Convergence/Divergence (Momentum Indicators)

    Inputs:
        real: (any ndarray)
    Parameters:
        fastperiod: 12
        slowperiod: 26
        signalperiod: 9
    Outputs:
        macd
        macdsignal
        macdhist
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MACD_Lookback( fastperiod , slowperiod , signalperiod )
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACD( 0 , endidx , <double *>(real.data)+begidx , fastperiod , slowperiod , signalperiod , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACD", retCode)
    return outmacd , outmacdsignal , outmacdhist

def MACDEXT( np.ndarray real not None , int fastperiod=-2**31 , int fastmatype=0 , int slowperiod=-2**31 , int slowmatype=0 , int signalperiod=-2**31 , int signalmatype=0 ):
    """ MACDEXT(real[, fastperiod=?, fastmatype=?, slowperiod=?, slowmatype=?, signalperiod=?, signalmatype=?])

    MACD with controllable MA type (Momentum Indicators)

    Inputs:
        real: (any ndarray)
    Parameters:
        fastperiod: 12
        fastmatype: 0
        slowperiod: 26
        slowmatype: 0
        signalperiod: 9
        signalmatype: 0
    Outputs:
        macd
        macdsignal
        macdhist
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MACDEXT_Lookback( fastperiod , fastmatype , slowperiod , slowmatype , signalperiod , signalmatype )
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACDEXT( 0 , endidx , <double *>(real.data)+begidx , fastperiod , fastmatype , slowperiod , slowmatype , signalperiod , signalmatype , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACDEXT", retCode)
    return outmacd , outmacdsignal , outmacdhist 

def MACDFIX( np.ndarray real not None , int signalperiod=-2**31 ):
    """ MACDFIX(real[, signalperiod=?])

    Moving Average Convergence/Divergence Fix 12/26 (Momentum Indicators)

    Inputs:
        real: (any ndarray)
    Parameters:
        signalperiod: 9
    Outputs:
        macd
        macdsignal
        macdhist
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MACDFIX_Lookback( signalperiod )
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACDFIX( 0 , endidx , <double *>(real.data)+begidx , signalperiod , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACDFIX", retCode)
    return outmacd , outmacdsignal , outmacdhist 

def MINUS_DI( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ MINUS_DI(high, low, close[, timeperiod=?])

    Minus Directional Indicator (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MINUS_DI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MINUS_DI( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MINUS_DI", retCode)
    return outreal 
    
def MINUS_DM( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ MINUS_DM(high, low[, timeperiod=?])

    Minus Directional Movement (Momentum Indicators)

    Inputs:
        prices: ['high', 'low']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MINUS_DM_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MINUS_DM( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MINUS_DM", retCode)
    return outreal 

def PLUS_DI( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ PLUS_DI(high, low, close[, timeperiod=?])

    Plus Directional Indicator (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_PLUS_DI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PLUS_DI( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PLUS_DI", retCode)
    return outreal 

def PLUS_DM( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ PLUS_DM(high, low[, timeperiod=?])

    Plus Directional Movement (Momentum Indicators)

    Inputs:
        prices: ['high', 'low']
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_PLUS_DM_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PLUS_DM( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PLUS_DM", retCode)
    return outreal 
    
def RSI( np.ndarray real not None , int timeperiod=-2**31 ):
    """ RSI(real[, timeperiod=?])

    Relative Strength Index (Momentum Indicators)

    Inputs:
        real: (any ndarray)
    Parameters:
        timeperiod: 14
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_RSI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_RSI( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_RSI", retCode)
    return outreal 

def STDDEV( np.ndarray real not None , int timeperiod=-2**31 , double nbdev=-4e37 ):
    """ STDDEV(real[, timeperiod=?, nbdev=?])

    Standard Deviation (Statistic Functions)

    Inputs:
        real: (any ndarray)
    Parameters:
        timeperiod: 5
        nbdev: 1.0
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STDDEV_Lookback( timeperiod , nbdev )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_STDDEV( 0 , endidx , <double *>(real.data)+begidx , timeperiod , nbdev , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_STDDEV", retCode)
    return outreal

def STOCH( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int fastk_period=-2**31 , int slowk_period=-2**31 , int slowk_matype=0 , int slowd_period=-2**31 , int slowd_matype=0 ):
    """ STOCH(high, low, close[, fastk_period=?, slowk_period=?, slowk_matype=?, slowd_period=?, slowd_matype=?])

    Stochastic (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        fastk_period: 5
        slowk_period: 3
        slowk_matype: 0
        slowd_period: 3
        slowd_matype: 0
    Outputs:
        slowk
        slowd
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outslowk
        np.ndarray outslowd
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STOCH_Lookback( fastk_period , slowk_period , slowk_matype , slowd_period , slowd_matype )
    outslowk = make_double_array(length, lookback)
    outslowd = make_double_array(length, lookback)
    retCode = lib.TA_STOCH( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , fastk_period , slowk_period , slowk_matype , slowd_period , slowd_matype , &outbegidx , &outnbelement , <double *>(outslowk.data)+lookback , <double *>(outslowd.data)+lookback )
    _ta_check_success("TA_STOCH", retCode)
    return outslowk , outslowd 

def STOCHF( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int fastk_period=-2**31 , int fastd_period=-2**31 , int fastd_matype=0 ):
    """ STOCHF(high, low, close[, fastk_period=?, fastd_period=?, fastd_matype=?])

    Stochastic Fast (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        fastk_period: 5
        fastd_period: 3
        fastd_matype: 0
    Outputs:
        fastk
        fastd
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outfastk
        np.ndarray outfastd
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STOCHF_Lookback( fastk_period , fastd_period , fastd_matype )
    outfastk = make_double_array(length, lookback)
    outfastd = make_double_array(length, lookback)
    retCode = lib.TA_STOCHF( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , fastk_period , fastd_period , fastd_matype , &outbegidx , &outnbelement , <double *>(outfastk.data)+lookback , <double *>(outfastd.data)+lookback )
    _ta_check_success("TA_STOCHF", retCode)
    return outfastk , outfastd 

def STOCHRSI( np.ndarray real not None , int timeperiod=-2**31 , int fastk_period=-2**31 , int fastd_period=-2**31 , int fastd_matype=0 ):
    """ STOCHRSI(real[, timeperiod=?, fastk_period=?, fastd_period=?, fastd_matype=?])

    Stochastic Relative Strength Index (Momentum Indicators)

    Inputs:
        real: (any ndarray)
    Parameters:
        timeperiod: 14
        fastk_period: 5
        fastd_period: 3
        fastd_matype: 0
    Outputs:
        fastk
        fastd
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outfastk
        np.ndarray outfastd
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STOCHRSI_Lookback( timeperiod , fastk_period , fastd_period , fastd_matype )
    outfastk = make_double_array(length, lookback)
    outfastd = make_double_array(length, lookback)
    retCode = lib.TA_STOCHRSI( 0 , endidx , <double *>(real.data)+begidx , timeperiod , fastk_period , fastd_period , fastd_matype , &outbegidx , &outnbelement , <double *>(outfastk.data)+lookback , <double *>(outfastd.data)+lookback )
    _ta_check_success("TA_STOCHRSI", retCode)
    return outfastk , outfastd 

def ULTOSC( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod1=-2**31 , int timeperiod2=-2**31 , int timeperiod3=-2**31 ):
    """ ULTOSC(high, low, close[, timeperiod1=?, timeperiod2=?, timeperiod3=?])

    Ultimate Oscillator (Momentum Indicators)

    Inputs:
        prices: ['high', 'low', 'close']
    Parameters:
        timeperiod1: 7
        timeperiod2: 14
        timeperiod3: 28
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ULTOSC_Lookback( timeperiod1 , timeperiod2 , timeperiod3 )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ULTOSC( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod1 , timeperiod2 , timeperiod3 , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ULTOSC", retCode)
    return outreal 

def WMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ WMA(real[, timeperiod=?])

    Weighted Moving Average (Overlap Studies)

    Inputs:
        real: (any ndarray)
    Parameters:
        timeperiod: 30
    Outputs:
        real
    """
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_WMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_WMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_WMA", retCode)
    return outreal 
