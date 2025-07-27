# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
import subprocess          # import the subprocess library for running shell commands
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np

def subProcessPrint(prefix, subProcessRes):
    
    print(f"{prefix} STDOUT:", subProcessRes.stdout)
    print(f"{prefix} ERROR :", subProcessRes.stderr)
    print("--------------------------------")
    

def changeMemCommitMode(allowOverCommit, isRoot): ### mode should be "pcap", "icap"
    
    if allowOverCommit:
        indicator = "1"
    else:
        indicator = "0"
    
    
    triggerCmd_inputVal = indicator
    config_file = "/proc/sys/vm/overcommit_memory"
    password = "xilinx"  # default sudo password for PYNQ-ZU

    # Compose the command string
    cmd_trigger = f"sudo -S tee {config_file}"
    cmd_read    = f"cat {config_file}"
    
    passwordCmd = (password + '\n') if not isRoot else ""

    # Run the trigger command
    result = subprocess.run(
        cmd_trigger,
        input=passwordCmd + triggerCmd_inputVal + '\n',
        shell=True,
        capture_output=True,
        text=True
    )

    subProcessPrint("TRIGGER CMD", result)

    
    result = subprocess.run(
        cmd_read,
        shell=True,
        capture_output=True,
        text=True
    )

    subProcessPrint("READ CMD", result)


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