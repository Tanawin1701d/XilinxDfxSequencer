# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class MagicStreamDbg:

    
    LOAD_ADDR = 0x8
    STORE_STATE_ADDR = 0x0


    def __init__(self, debugIps, idxWidths: list, wrapWidths):

        self.dbIps = debugIps
        self.dbIdxWidths = idxWidths.copy()
        self.dbWrapWidths = wrapWidths.copy()

        if len(debugIps) != len(idxWidths):
            raise Exception("There are mismatch metadata of dubugIps and idxWidths")
        if len(debugIps) != len(wrapWidths):
            raise Exception("There are mismatch metadata of dubugIps and wrapWidths")

    def createMask(self, length):
        return (1 << length) -1

    def cvtRawToStoreVal(self, streamIdx, rawData):
        return rawData & self.createMask(self.dbIdxWidths[streamIdx]+ 1)
    
    def cvtRawToStateVal(self, streamIdx, rawData):
        return rawData >> (self.dbIdxWidths[streamIdx] + 1)
    
    def getMaxUsage(self, streamIdx):
        width = self.dbIdxWidths[streamIdx]

        return 1 << width


    ##############################################
    ############# get data function ##############
    ##############################################
    def getLoadAmtValue(self, streamIdx):
        return self.dbIps[streamIdx].read(self.LOAD_ADDR)
    
    def getStoreAmtValue(self, streamIdx):
        rawValue =  self.dbIps[streamIdx].read(self.STORE_STATE_ADDR)
        return self.cvtRawToStoreVal(streamIdx, rawValue)
    
    def convertAmtUseToByte(self, streamIdx, amtUse):
        return int(amtUse * self.dbWrapWidths[streamIdx] / 8)
    
    def getStateValue(self, streamIdx):
        rawValue = self.dbIps[streamIdx].read(self.STORE_STATE_ADDR)
        stateValue = self.cvtRawToStateVal(streamIdx, rawValue)

        stateMap = ["STATUS_IDLE","STATUS_STORE","STATUS_LOAD"]

        return stateMap[stateValue]
    

    ##############################################
    ############# print Dbg function #############
    ##############################################

    def printDebugAll(self):
        print("magic streamer debugger")
        for idx in range(len(self.dbIps)):
            print(f"-------- STREAM {idx}----------")
            print(f"state: {self.getStateValue(idx)}")
            amtLoadInByte    = str(self.convertAmtUseToByte(idx,self.getLoadAmtValue(idx)))
            amtStoreInByte   = str(self.convertAmtUseToByte(idx,self.getStoreAmtValue(idx)))
            maxStorageInByte = str(self.convertAmtUseToByte(idx,self.getMaxUsage(idx)))
            print(f"amtLoad: {str(amtLoadInByte)} bytes/ {maxStorageInByte} bytes")
            print(f"amtStore: {str(amtStoreInByte)} bytes/ {maxStorageInByte} bytes")
        print("----------------------------------")