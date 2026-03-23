"""
Indicator.py - pandas-friendly wrapper for TA indicators.

This module was generated automatically from Indicator.pxi. It exposes functions with the same names
as in the original file but accepts pandas.Series or pandas.DataFrame inputs and returns pandas.Series
or pandas.DataFrame outputs. Internally it attempts to call the TA-Lib Python package (pip install TA-Lib).
If TA-Lib is not available, functions will raise ImportError.

Notes:
- The wrapper preserves indices when possible: the index of the first pandas.Series or pandas.DataFrame
  argument will be used for output Series.
- Functions that return multiple arrays (e.g., BBANDS) return tuples of pandas.Series in the same order.
- If an input is a DataFrame, it will be passed to TA-Lib as numpy array; the output will be Series with same index.

Generated automatically. Keep function names identical to the original Cython interface.
"""
from __future__ import annotations
import numpy as np
import pandas as pd

# Attempt to import TA-Lib (the C library Python wrapper). If unavailable, users must install it.
try:
    import talib as _talib
except Exception as e:
    _talib = None
    _talib_import_error = e

def _ensure_talib():
    if _talib is None:
        raise ImportError("TA-Lib Python package is required for Indicator.py wrappers. Install with 'pip install TA-Lib'. Original import error: {}".format(_talib_import_error))

def _to_numpy(x):
    """Convert input to numpy array, preserving dtype when possible."""
    if isinstance(x, (pd.Series, pd.DataFrame)):
        return x.to_numpy()
    elif isinstance(x, (list, tuple)):
        return np.asarray(x)
    elif isinstance(x, np.ndarray):
        return x
    else:
        return np.asarray(x)

def _get_index_from_args(args, kwargs):
    # Return the first pandas.Index found in args or kwargs (from Series/DataFrame)
    for a in list(args) + list(kwargs.values()):
        if isinstance(a, (pd.Series, pd.DataFrame)):
            return a.index
    return None

def _wrap_output(out, index=None, name=None):
    """Wrap numpy array output into pandas Series. If out is a tuple, wrap each element."""
    if isinstance(out, tuple):
        return tuple(_wrap_output(o, index=index, name=name) for o in out)
    arr = np.asarray(out)
    # If 1D, return Series; if 2D, return DataFrame
    if arr.ndim == 1:
        if index is not None and len(index) == arr.shape[0]:
            return pd.Series(arr, index=index, name=name)
        else:
            return pd.Series(arr, name=name)
    elif arr.ndim == 2:
        # Map to DataFrame; preserve index if length matches first dimension
        if index is not None and len(index) == arr.shape[0]:
            return pd.DataFrame(arr, index=index)
        else:
            return pd.DataFrame(arr)
    else:
        # For higher dims, just return numpy array
        return arr


def AD(*args, **kwargs):
    """Wrapper for AD(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "AD", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'AD'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="AD")


def ADX(*args, **kwargs):
    """Wrapper for ADX(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "ADX", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'ADX'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="ADX")


def ADXR(*args, **kwargs):
    """Wrapper for ADXR(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "ADXR", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'ADXR'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="ADXR")


def AROON(*args, **kwargs):
    """Wrapper for AROON(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "AROON", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'AROON'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="AROON")


def ATR(*args, **kwargs):
    """Wrapper for ATR(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "ATR", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'ATR'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="ATR")


def BBANDS(*args, **kwargs):
    """Wrapper for BBANDS(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "BBANDS", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'BBANDS'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="BBANDS")


def DX(*args, **kwargs):
    """Wrapper for DX(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "DX", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'DX'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="DX")


def IMI(*args, **kwargs):
    """Wrapper for IMI(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "IMI", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'IMI'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="IMI")


def MACD(*args, **kwargs):
    """Wrapper for MACD(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "MACD", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'MACD'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="MACD")


def MACDEXT(*args, **kwargs):
    """Wrapper for MACDEXT(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "MACDEXT", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'MACDEXT'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="MACDEXT")


def MACDFIX(*args, **kwargs):
    """Wrapper for MACDFIX(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "MACDFIX", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'MACDFIX'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="MACDFIX")


def MINUS_DI(*args, **kwargs):
    """Wrapper for MINUS_DI(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "MINUS_DI", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'MINUS_DI'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="MINUS_DI")


def MINUS_DM(*args, **kwargs):
    """Wrapper for MINUS_DM(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "MINUS_DM", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'MINUS_DM'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="MINUS_DM")


def PLUS_DI(*args, **kwargs):
    """Wrapper for PLUS_DI(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "PLUS_DI", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'PLUS_DI'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="PLUS_DI")


def PLUS_DM(*args, **kwargs):
    """Wrapper for PLUS_DM(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "PLUS_DM", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'PLUS_DM'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="PLUS_DM")


def RSI(*args, **kwargs):
    """Wrapper for RSI(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "RSI", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'RSI'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="RSI")


def STDDEV(*args, **kwargs):
    """Wrapper for STDDEV(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "STDDEV", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'STDDEV'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="STDDEV")


def STOCH(*args, **kwargs):
    """Wrapper for STOCH(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "STOCH", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'STOCH'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="STOCH")


def STOCHF(*args, **kwargs):
    """Wrapper for STOCHF(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "STOCHF", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'STOCHF'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="STOCHF")


def STOCHRSI(*args, **kwargs):
    """Wrapper for STOCHRSI(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "STOCHRSI", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'STOCHRSI'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="STOCHRSI")


def ULTOSC(*args, **kwargs):
    """Wrapper for ULTOSC(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "ULTOSC", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'ULTOSC'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="ULTOSC")


def WMA(*args, **kwargs):
    """Wrapper for WMA(...). See TA-Lib for exact parameter semantics.

    The function accepts pandas.Series, pandas.DataFrame, numpy arrays, lists, or scalars as inputs.
    Returns pandas.Series, pandas.DataFrame, or tuple of Series/DataFrames where applicable.
    """
    _ensure_talib()
    # Determine index from first pandas input
    index = _get_index_from_args(args, kwargs)
    # Convert args/kwargs to numpy arrays where appropriate
    np_args = tuple(_to_numpy(a) for a in args)
    np_kwargs = {k: _to_numpy(v) for k, v in kwargs.items()}
    # Call the corresponding function in talib (same name expected)
    talib_func = getattr(_talib, "WMA", None)
    if talib_func is None:
        # If TA-Lib does not expose this exact name, raise informative error
        raise AttributeError("TA-Lib does not have a function named 'WMA'. Ensure TA-Lib provides this indicator.")
    result = talib_func(*np_args, **np_kwargs)
    # Wrap output back into pandas structures
    return _wrap_output(result, index=index, name="WMA")
