"""This module sets tensorflow working environment."""

import os
from pathlib import Path
import logging
import platform
from typing import Tuple, TYPE_CHECKING, Any
import numpy as np
from imp import reload

if TYPE_CHECKING:
    from types import ModuleType

# import tensorflow v1 compatability
try:
    import tensorflow.compat.v1 as tf

    tf.disable_v2_behavior()
except ImportError:
    import tensorflow as tf


def set_env_if_empty(key: str, value: str, verbose: bool = True):
    """Set environment variable only if it is empty.

    Parameters
    ----------
    key : str
        env variable name
    value : str
        env variable value
    verbose : bool, optional
        if True action will be logged, by default True
    """
    if os.environ.get(key) is None:
        os.environ[key] = value
        if verbose:
            logging.warn(
                f"Environment variable {key} is empty. Use the default value {value}"
            )


def set_mkl():
    """Tuning MKL for the best performance.

    References
    ----------
    TF overview
    https://www.tensorflow.org/guide/performance/overview

    Fixing an issue in numpy built by MKL
    https://github.com/ContinuumIO/anaconda-issues/issues/11367
    https://github.com/numpy/numpy/issues/12374

    check whether the numpy is built by mkl, see
    https://github.com/numpy/numpy/issues/14751
    """
    if "mkl_rt" in np.__config__.get_info("blas_mkl_info").get("libraries", []):
        set_env_if_empty("KMP_BLOCKTIME", "0")
        set_env_if_empty("KMP_AFFINITY", "granularity=fine,verbose,compact,1,0")
        reload(np)


def set_tf_default_nthreads():
    """Set TF internal number of threads to default=automatic selection.

    Notes
    -----
    `TF_INTRA_OP_PARALLELISM_THREADS` and `TF_INTER_OP_PARALLELISM_THREADS`
    control TF configuration of multithreading.
    """
    set_env_if_empty("TF_INTRA_OP_PARALLELISM_THREADS", "0", verbose=False)
    set_env_if_empty("TF_INTER_OP_PARALLELISM_THREADS", "0", verbose=False)


def get_tf_default_nthreads() -> Tuple[int, int]:
    """Get TF paralellism settings.

    Returns
    -------
    Tuple[int, int]
        number of `TF_INTRA_OP_PARALLELISM_THREADS` and
        `TF_INTER_OP_PARALLELISM_THREADS`
    """
    return int(os.environ.get("TF_INTRA_OP_PARALLELISM_THREADS", "0")), int(
        os.environ.get("TF_INTER_OP_PARALLELISM_THREADS", "0")
    )


def get_tf_session_config() -> Any:
    """Configure tensorflow session.

    Returns
    -------
    Any
        session configure object
    """
    set_tf_default_nthreads()
    intra, inter = get_tf_default_nthreads()
    return tf.ConfigProto(
        intra_op_parallelism_threads=intra, inter_op_parallelism_threads=inter
    )


def get_module(module_name: str) -> "ModuleType":
    """Load force module.

    Returns
    -------
    ModuleType
        loaded force module

    Raises
    ------
    FileNotFoundError
        if module is not found in directory
    """
    if platform.system() == "Windows":
        ext = ".dll"
    elif platform.system() == "Darwin":
        ext = ".dylib"
    else:
        ext = ".so"

    module_file = (Path(__file__).parent / module_name).with_suffix(ext)

    if not module_file.is_file():
        raise FileNotFoundError(f"module {module_name} does not exist")
    else:
        module = tf.load_op_library(os.fspath(module_file))
        return module


op_module = get_module("libop_abi")
op_grads_module = get_module("libop_grads")
default_tf_session_config = get_tf_session_config()
