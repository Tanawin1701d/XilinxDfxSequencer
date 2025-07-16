# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class MyDfxCtrl(DefaultIP):
    def __init__(self, description):
        self.isMetaConfigured = False
        super().__init__(description=description)
        self.storage = None
        # BLS Bit Layout Size
        self.BLS_DATA   = 2 # register contain 4 byte (2 bit addressing)
        self.BLS_REGID  = 4 # register Id
        self.BLS_BANKID = 2 # bank id
        #### TODO this may change 
        # GENERAL BANK
        self.BANK_GENREG      = 0     
        self.GENREG_STATUS    = 0
        self.GENREG_CTRL      = 0
        self.GENREG_SWTRIGGER = 1
        # TRIGGER RM MAPPING
        self.BANK_RMM         = 1
            #self.BANK_RMM_LIMIT   = 2 #### it is not used now!
        # RM INFO
        self.BANK_RMINFO      = 2
            #self.BANK_RMINFO_LIMIT= 2 #### it is not used now!
        # BITSTREAM INFO
        self.BANK_BSINFO      = 3
            #self.BANK_BSINFO_LIMIT= 2 #### it is not used now!

        ##### retrive the actual metadata

        
        #print(description) #
        
    bindto = ['xilinx.com:ip:dfx_controller:1.0']

    def config(self, metaPath):

        regBankIdx, regColIdx = self.retrieveConfig(metaPath)
        self.BLS_REGID  = regColIdx [1] - regColIdx [0] + 1
        self.BLS_BANKID = regBankIdx[1] - regBankIdx[0] + 1
        self.isMetaConfigured = True
        

    #######################################
    ###### config check ###################
    #######################################
    def retrieveConfig(self, path):
        regBankIdx = None
        regColIdx  = None

        with open(path, 'r') as file:
            for line in file:
                if "Selects the Register Bank" in line:
                    regBankIdx = self.extractBitRange(line)
                    print(f"regbank detect index {regBankIdx}")
                    
                if "Selects the Register within the bank" in line:
                    regColIdx = self.extractBitRange(line)
                    print(f"regbank detect index {regColIdx}")

        return regBankIdx, regColIdx



    def extractBitRange(self, line):

        match = re.search(r'\[\s*(\d+)\s*:\s*(\d+)\s*\]', line)

        if match:
            high = int(match.group(1))
            low  = int(match.group(2))
            return low, high
        else:
            return None


    #######################################
    ###### address generator ##############
    #######################################
    def getAddress(self, bankId, regId): ### todo make it compatible for more than 1 slot
        if not self.isMetaConfigured:
            raise Exception("this module has not initialized yet, any attempt to interact with the IP will be abort")
        return (bankId << (self.BLS_DATA + self.BLS_REGID)) + (regId << (self.BLS_DATA))
    #######################################
    ###### general command ################
    #######################################
    def shutdownEngine(self):
        print("shutdown dfx Controller")
        self.setCtrl(0)
    
    def restartNoStatus(self):
        print("restart the dfx Controller with no status")
        self.setCtrl(1)
        
    def restartWithStatus(self):
        print("restart the dfx Controller with status")
        
    def trigger(self, triggerId):
        print("trig the rmId ", triggerId)
        self.setCtrlTrigger(triggerId)

    #######################################
    ###### getter setter command ##########
    #######################################
        
    ###### general register bank0
    #
    # |statusRegister, controlRegister|
    # | trigger register              |
    #
    def getStatus(self):
        regAddr = self.getAddress(self.BANK_GENREG, self.GENREG_STATUS)
        print("[get status register] @", hex(regAddr))
        return self.read(regAddr)
    
    def getCtrl(self):
        regAddr = self.getAddress(self.BANK_GENREG, self.GENREG_CTRL)
        print("[get ctrl register] @", hex(regAddr))
        return self.read(regAddr)
    
    def setCtrl(self, command):
        regAddr = self.getAddress(self.BANK_GENREG, self.GENREG_CTRL)
        print("[set ctrl register] @", hex(regAddr), " with command ", hex(command))
        self.write(regAddr, command)
    
    def getCtrlTrigger(self):
        regAddr = self.getAddress(self.BANK_GENREG, self.GENREG_SWTRIGGER)
        print("[get Ctrl Trigger] @", hex(regAddr))
        return self.read(regAddr)
    
    def setCtrlTrigger(self, triggerId):
        regAddr = self.getAddress(self.BANK_GENREG, self.GENREG_SWTRIGGER)
        print("[set Ctrl Trigger] @", hex(regAddr))
        self.write(regAddr, triggerId)
        
    ####### Reconfig Module Map bank1
    # | RM0 |
    # | RM1 |
    # | RM2 |
    # .
    def getRMM(self, triggerId):
        regAddr = self.getAddress(self.BANK_RMM, triggerId)
        print("[get RM MAP] @", hex(regAddr))
        return self.read(regAddr)
    
    def setRMM(self, triggerId, infoId):
        regAddr = self.getAddress(self.BANK_RMM, triggerId)
        print("[set RM MAP] @", hex(regAddr), " info ", hex(infoId))
        self.write(regAddr, infoId)
        
    ####### Reconfig Module Map bank2
    # | BS_ID0 | CT_ID0 |
    # | BS_ID1 | CT_ID1 |
    # | BS_ID2 | CT_ID2 |
    # .
    def getRMInfo(self, infoId):
        bsIdxAddr = self.getAddress(self.BANK_RMINFO, infoId * 2)
        ### *2 because each row has two element
        ctrlAddr  = self.getAddress(self.BANK_RMINFO, (infoId * 2) + 1)
        print("[get RM INFO] bsIdxAddr@", hex(bsIdxAddr), " ctrlAddr@", hex(ctrlAddr))
        return (self.read(bsIdxAddr), self.read(ctrlAddr))
    
    def setRMInfo(self, infoId, bsIdx, ctrlCmd):
        ### *2 because each row has two element
        bsIdxAddr = self.getAddress(self.BANK_RMINFO, infoId * 2)
        ctrlAddr  = self.getAddress(self.BANK_RMINFO, (infoId * 2) + 1)
        print("[get RM INFO] bsIdxAddr@", hex(bsIdxAddr), " ctrlAddr@", hex(ctrlAddr))
        self.write(bsIdxAddr, bsIdx)
        self.write(ctrlAddr, ctrlCmd)
    ####### BIN stream bank3
    # | BIN_ADDR0 | SIZE0 |
    # | BIN_ADDR1 | SIZE1 |
    # | BIN_ADDR2 | SIZE2 |
    # .
    def getBSInfo(self, bsId):
        ### *3 because each row has three element
        streamIdentAddr  = self.getAddress(self.BANK_BSINFO, (bsId * 4)    )
        streamAddr       = self.getAddress(self.BANK_BSINFO, (bsId * 4) + 1)
        sizeAddr         = self.getAddress(self.BANK_BSINFO, (bsId * 4) + 2)
        print("[get BS INFO] streamAddr@", hex(streamAddr), " sizeAddr@", hex(sizeAddr))
        return (self.read(streamIdentAddr), self.read(streamAddr), self.read(sizeAddr))
    
    def setBSInfo(self, bsId, phyStreamAddr, streamSize):
    
        streamIdentAddr  = self.getAddress(self.BANK_BSINFO, (bsId * 4)    )
        streamAddr       = self.getAddress(self.BANK_BSINFO, (bsId * 4) + 1)
        sizeAddr         = self.getAddress(self.BANK_BSINFO, (bsId * 4) + 2)
        print("[get BS INFO] streamAddr@", hex(streamAddr), " sizeAddr@", hex(sizeAddr))
        self.write(streamIdentAddr, 1)
        self.write(streamAddr     , phyStreamAddr)
        self.write(sizeAddr       , streamSize)
        
    ######## AUTO META DATA RECONFIGURE
    def setSimpleMetaData(self, idx, streamPhyAddr, streamPhySize):
        
        print("setting RM Mapping to ", idx)
        self.setRMM(idx, idx)
        print("setting RM INFO to ", idx)
        ctrlValue = 0B0_10_0_00
        print("control value for active low reset is ", hex(ctrlValue))
        self.setRMInfo(idx, idx, ctrlValue)
        
        print("setting BS INFO to ", idx, " with streamAddress: ", streamPhyAddr, " with size: ", streamPhySize)
        self.setBSInfo(idx, streamPhyAddr, streamPhySize)
    
    ###########################################
    ######## DEBUGGER #########################
    ###########################################

    def printStatus(self):
        
        status = self.getStatus()
        
        print(">>status of the system vs0")
        print("-------> Is device shutdown: ", (status >> 7) & 0x1)
        print("-------> current error code: ", hex((status >> 3) & 0xF))
        print("-------> active RM_ID      : ", hex((status >> 8) & 0xFFFF))
        print("-------> state      : ", hex(status & 0x7))
        
    def printSimpleMetaData(self, idx):
        print("get metadata info for row", idx)
        print("RM MAPPER: ", self.getRMM   (idx))
        print("RM INFO  : ", self.getRMInfo(idx))
        print("BS INFO  : ", self.getBSInfo(idx))
        
        
        
    ###############################################
    ####### ALLOCATE BIN STREAM ON MAIN MEMORY ####
    ###############################################
    
    def allocateBitStreamCMA(self, path):
              
        print(">>allocateBitStream")
        
        print("opening file ", path)
        with open(path, 'rb') as f:
            data = f.read()
        file_size = len(data)
        print("copying the data")
        data_u32  = np.frombuffer(data, dtype='<u4')  # Big-endian uint32
        buffer    = allocate(shape=(len(data_u32),), dtype='>u4')
        buffer[:] = data_u32
        print("copy complete")
        print("file size ", file_size)
        print("---------------------------------")
        return buffer, buffer.physical_address, file_size