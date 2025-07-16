import os
import subprocess
import re

def subProcessPrint(prefix, subProcessRes):
    
    print(f"{prefix} STDOUT:", subProcessRes.stdout)
    print(f"{prefix} ERROR :", subProcessRes.stderr)
    print("--------------------------------")
    

def changePLconfigMode(mode, isRoot): ### mode should be "pcap", "icap"
    indicator = "1"
    
    if mode == "icap":
        indicator = "0"
    elif mode == "pcap":
        pass
    else:
        raise Exception("change PL config Mode has mode error")
    
    
    changeCmd_inputVal = f"0xFFCA3008 0xFFFFFFFF 0x{indicator}"
    triggerCmd_inputVal = "0xFFCA3008"
    config_file = "/sys/firmware/zynqmp/config_reg"
    password = "xilinx"  # default sudo password for PYNQ-ZU

    # Compose the command string
    cmd_change = f"sudo -S tee {config_file}"
    cmd_trigger = f"sudo -S tee {config_file}"
    cmd_read    = f"cat {config_file}"
    
    passwordCmd = (password + '\n') if not isRoot else ""

    # Run the change command
    result = subprocess.run(
        cmd_change,
        input=passwordCmd + changeCmd_inputVal + '\n',
        shell=True,
        capture_output=True,
        text=True
    )
    subProcessPrint("CHANGE CMD", result)

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