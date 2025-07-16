# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class MagicSeqdDriver(DefaultIP):

    def __init__(self, description):
        super().__init__(description=description)

        ### Bit Layout start bit
        self.BL_COL_ST  =  2 
        self.BL_ROW_ST  =  6 
        self.BL_BNK_ST  = 14 
        ### Bit Layout size
        self.BIT_COL_SZ = 4
        self.BIT_ROW_SZ = 8
        self.BIT_BNK_SZ = 2

        self.REG_CTRL     = (0,0,0)
        self.REG_ST       = (0,1,0)
        self.REG_MAINCNT  = (0,2,0)
        self.REG_ENDCNT   = (0,3,0)
        self.REG_DMA_ADDR = (0,4,0)
        self.REG_DFX_ADDR = (0,5,0)

        #### the row must be change to match the slot
        self.SLOT_SRC_ADDR    = (1,0,0)
        self.SLOT_SRC_SIZE    = (1,0,1)
        self.SLOT_DES_ADDR    = (1,0,2)
        self.SLOT_DES_SIZE    = (1,0,3)
        self.SLOT_STATUS      = (1,0,4)
        self.SLOT_PROF        = (1,0,5)
        self.SLOT_LD_MASK     = (1,0,6)
        self.SLOT_ST_MASK     = (1,0,7)
        self.SLOT_STINTR_MASK = (1,0,8)



        self.LIM_AMT_SLOT = 4 ### limit amount slot
        

    bindto = ['user.org:user:MagicSeqTop:1.0']

    def genAddr(self, bankId, rowIdx, colIdx):
        return (bankId << self.BL_BNK_ST) | (rowIdx << self.BL_ROW_ST) | (colIdx << self.BL_COL_ST)
    
    def genAddrForSlot(self, slotT, slotIdx):
        return self.genAddr(slotT[0], slotIdx, slotT[2])

    ###############################################
    ####### getter ################################
    ###############################################

    def getStatus(self):
        return self.read(self.genAddr(*self.REG_ST))
    def getMainCnt(self):
        return self.read(self.genAddr(*self.REG_MAINCNT))
    def getEndCnt(self):
        return self.read(self.genAddr(*self.REG_ENDCNT))
    def getDmaAddr(self):
        return self.read(self.genAddr(*self.REG_DMA_ADDR))
    def getDfxAddr(self):
        return self.read(self.genAddr(*self.REG_DFX_ADDR))
    
    def getSlot(self, slotIdx):

        addr_srcAddr  = self.genAddrForSlot(self.SLOT_SRC_ADDR   , slotIdx)             
        addr_srcSz    = self.genAddrForSlot(self.SLOT_SRC_SIZE   , slotIdx)           
        addr_desAddr  = self.genAddrForSlot(self.SLOT_DES_ADDR   , slotIdx)             
        addr_desSz    = self.genAddrForSlot(self.SLOT_DES_SIZE   , slotIdx)           
        addr_status   = self.genAddrForSlot(self.SLOT_STATUS     , slotIdx)            
        addr_prof     = self.genAddrForSlot(self.SLOT_PROF       , slotIdx)
        addr_ldMask   = self.genAddrForSlot(self.SLOT_LD_MASK    , slotIdx)
        addr_stMask   = self.genAddrForSlot(self.SLOT_ST_MASK    , slotIdx)
        addr_stIntr   = self.genAddrForSlot(self.SLOT_STINTR_MASK, slotIdx)


        data_srcAddr  = self.read(addr_srcAddr)
        data_srcSz    = self.read(addr_srcSz)
        data_desAddr  = self.read(addr_desAddr)
        data_desSz    = self.read(addr_desSz)
        data_status   = self.read(addr_status)
        data_prof     = self.read(addr_prof)
        data_ldMask   = self.read(addr_ldMask)
        data_stMask   = self.read(addr_stMask)
        data_stIntr   = self.read(addr_stIntr)

        return data_srcAddr, data_srcSz, data_desAddr, data_desSz, data_status, data_prof, \
        data_ldMask, data_stMask, data_stIntr
        

    ###############################################
    ####### setter ################################
    ###############################################

    def setControl(self, value): #### status registesr will be neglect
        return self.write(self.genAddr(*self.REG_CTRL), value)
    # def setMainCnt(self, value):
    #     return self.write(self.genAddr(*self.REG_MAINCNT), value)
    def setEndCnt(self, value):
        return self.write(self.genAddr(*self.REG_ENDCNT), value)
    def setDmaAddr(self, value):
        return self.write(self.genAddr(*self.REG_DMA_ADDR), value)
    def setDfxAddr(self, value):
        return self.write(self.genAddr(*self.REG_DFX_ADDR), value)
    
    def setSlot(self, slotT, slotIdx, value):
        addr  = self.genAddrForSlot(slotT, slotIdx) 
        self.write(addr, value)

    def setWholeSlot(self, slotIdx, dataList):

        addr_srcAddr  = self.genAddrForSlot(self.SLOT_SRC_ADDR, slotIdx)             
        addr_srcSz    = self.genAddrForSlot(self.SLOT_SRC_SIZE, slotIdx)           
        addr_desAddr  = self.genAddrForSlot(self.SLOT_DES_ADDR, slotIdx)             
        addr_desSz    = self.genAddrForSlot(self.SLOT_DES_SIZE, slotIdx)           
        addr_status   = self.genAddrForSlot(self.SLOT_STATUS  , slotIdx)            
        addr_prof     = self.genAddrForSlot(self.SLOT_PROF    , slotIdx)
        addr_ldMask   = self.genAddrForSlot(self.SLOT_LD_MASK    , slotIdx)
        addr_stMask   = self.genAddrForSlot(self.SLOT_ST_MASK    , slotIdx)
        addr_stIntr   = self.genAddrForSlot(self.SLOT_STINTR_MASK, slotIdx)

        self.write(addr_srcAddr, dataList[0])
        self.write(addr_srcSz  , dataList[1])
        self.write(addr_desAddr, dataList[2])
        self.write(addr_desSz  , dataList[3])
        self.write(addr_status , dataList[4])
        self.write(addr_prof   , dataList[5])
        self.write(addr_ldMask , dataList[6])
        self.write(addr_stMask , dataList[7])
        self.write(addr_stIntr , dataList[8])

    ###############################################
    ####### command################################
    ###############################################

    def clearEngine(self):
        print("[cmd] clear the engine")
        self.setControl(0)
        print("[cmd] clear the engine successfully")


    def shutdownEngine(self):
        print("[cmd] shutdown the engine")
        self.setControl(1)
        print("[cmd] shutdown successfully")

    def startEngine(self):
        print("[cmd] start the engine")
        self.setControl(2)
        print("[cmd] start the successfully")

    ###############################################
    ####### debugger ##############################
    ###############################################

    def status2Str(self, statusIdx):
        mapper = [ "SHUTDOWN","REPROG","W4SLAVERESET","W4SLAVEOP","CLEAR_MGS","INITIALIZE_MGS",
                  "INITIALIZE_DMA","SET_DMA_LOAD","SET_DMA_STORE","TRIGGERING","WAIT4FIN","PAUSEONERROR"
        ]

        if statusIdx not in range(0, len(mapper)):
            return "STATUS ERROR"
        return mapper[statusIdx]
        
    def printMainStatus(self):


        print("----- MAIN STATUS ------------------")
        status  = self.getStatus()
        print("--------> STATUS = ", self.status2Str(status))
        mainCnt = self.getMainCnt()
        print("--------> MAINCNT = ", mainCnt)
        endCnt  = self.getEndCnt()
        print("--------> ENDCNT  = ", endCnt)
        dmaAddr = self.getDmaAddr()
        print("--------> DMAADDR  = ", hex(dmaAddr))
        dfxAddr = self.getDfxAddr()
        print("--------> DFXADDR  = ", hex(dfxAddr))


    def printSlotData(self):

        print("----- SLOT DATA ------------------")

        if self.getStatus() != 0:
            print("---------- cannot print slot data due to the system is not in shutdown state")
            return

        for slotIdx in range (self.LIM_AMT_SLOT):
            s_addr, s_size, d_addr, d_size, status, prof, data_ldMask, data_stMask, data_stIntr = self.getSlot(slotIdx)

            print(f"------> slot {slotIdx} :")
            print(f"        srcAddr   : {hex(s_addr)},  srcSize   : {hex(s_size)}")
            print(f"        desAddr   : {hex(d_addr)},  desSize   : {hex(d_size)}")
            print(f"        status    : {hex(status)}")
            print(f"        profileCnt: {hex(prof)}")
            print(f"        loadMask  : {bin(data_ldMask)}")
            print(f"        storeMask : {bin(data_stMask)}")
            print(f"        stIntrMask: {bin(data_stIntr)}")

    def printDebug(self):
        self.printMainStatus()
        self.printSlotData()
        print("-------------------------------")