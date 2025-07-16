# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np


def allocDataUint(allocShape = (16, ), allocType = np.float32, inputX = None):
    buf0 = allocate(shape=allocShape, dtype=allocType)
    #### copy the data
    if inputX is not None:
        print("start copy from input to allocate buffer")
        if (allocShape != inputX.shape) or (allocType != inputX.dtype):
            raise Exception("the specified shape and inputX shape is mismatch")
        np.copyto(buf0, inputX)
        print("copy finish")

    return buf0, buf0.physical_address, buf0.nbytes