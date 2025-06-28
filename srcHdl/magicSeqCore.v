module MagicSeqCore #(

    parameter BANK1_INDEX_WIDTH    =  2, // 2 ^ 2 = 4 slots
    parameter BANK1_SRC_ADDR_WIDTH = 32,
    parameter BANK1_SRC_SIZE_WIDTH = 26,
    parameter BANK1_DST_ADDR_WIDTH = 32,
    parameter BANK1_DST_SIZE_WIDTH = 26,
    parameter BANK1_STATUS_WIDTH   =  2,
    parameter BANK1_PROFILE_WIDTH  = 32,

    parameter BANK0_CONTROL_WIDTH = 4,
    parameter BANK0_STATUS_WIDTH  = 4,
    parameter BANK0_CNT_WIDTH     = BANK1_INDEX_WIDTH /// the counter for the sequencer


) (
    input wire clk,
    input wire reset,
    //////////////////////////////////////////////////////////
    // outsider interface bank0 (typically from PS)///////////
    //////////////////////////////////////////////////////////

    // setter from outsider
    input wire [BANK1_INDEX_WIDTH    -1:0] ext_bank1_inp_index,
    input wire [BANK1_SRC_ADDR_WIDTH -1:0] ext_bank1_inp_src_addr,
    input wire [BANK1_SRC_SIZE_WIDTH -1:0] ext_bank1_inp_src_size,
    input wire [BANK1_DST_ADDR_WIDTH -1:0] ext_bank1_inp_des_addr,
    input wire [BANK1_DST_SIZE_WIDTH -1:0] ext_bank1_inp_des_size,
    input wire [BANK1_STATUS_WIDTH   -1:0] ext_bank1_inp_status,
    input wire [BANK1_PROFILE_WIDTH  -1:0] ext_bank1_inp_profile,

    input wire ext_bank1_set_src_addr,
    input wire ext_bank1_set_src_size,
    input wire ext_bank1_set_des_addr,
    input wire ext_bank1_set_des_size,
    input wire ext_bank1_set_status,
    input wire ext_bank1_set_profile,

    output wire ext_bank1_set_fin_src_addr,   /// the result external setting 
    output wire ext_bank1_set_fin_src_size,   /// the result external setting 
    output wire ext_bank1_set_fin_des_addr,   /// the result external setting 
    output wire ext_bank1_set_fin_des_size,   /// the result external setting 
    output wire ext_bank1_set_fin_status,     /// the result external setting   
    output wire ext_bank1_set_fin_profile,    /// the result external setting  

    // retriever from outsider
    input  wire [BANK1_INDEX_WIDTH    -1:0] ext_bank1_out_index,
    input  wire                             ext_bank1_out_req,           // actually it is a wire
    output wire [BANK1_DST_ADDR_WIDTH -1:0] ext_bank1_out_src_addr,      // actually it is a reg
    output wire [BANK1_DST_SIZE_WIDTH -1:0] ext_bank1_out_src_size,      // actually it is a reg
    output wire [BANK1_DST_ADDR_WIDTH -1:0] ext_bank1_out_des_addr,
    output wire [BANK1_DST_SIZE_WIDTH -1:0] ext_bank1_out_des_size,
    output wire [BANK1_STATUS_WIDTH   -1:0] ext_bank1_out_status  ,      // actually it is a reg
    output wire [BANK1_PROFILE_WIDTH  -1:0] ext_bank1_out_profile,       // actually it is a reg
    output wire                             ext_bank1_out_ready,         // actually it is a reg


    //////////////////////////////////////////////////////////
    // outsider interface bank0 (typically from PS)///////////
    //////////////////////////////////////////////////////////
    input wire [BANK0_CONTROL_WIDTH-1:0] ext_bank0_inp_control, /// set control data
    input wire                           ext_bank0_set_control, /// set control signal

    output wire [BANK0_STATUS_WIDTH-1:0] ext_bank0_out_status,  /// read only and it is reg

    output wire [BANK0_CNT_WIDTH   -1:0] ext_bank0_out_mainCnt,     /// read only

    input  wire [BANK0_CNT_WIDTH-1:0]    ext_bank0_inp_endCnt,      ///
    input  wire                          ext_bank0_set_endCnt,      ///
    output wire [BANK0_CNT_WIDTH-1:0]    ext_bank0_out_endCnt,      /// read only

    //////////////////////////////////////////////////////////
    // slave functionality                         ///////////
    //////////////////////////////////////////////////////////
    output wire slaveReprog, ///// trigger slave dma to reprogram
    input  wire slaveReprogAccept, ///// the slave dma is ready to reprogram

    output wire slaveInit, ///// trigger slave dma to do somthing
    input  wire slaveFinInit,

    output wire slaveStartExec,
    input  wire slaveStartExecAccept, ///// the slave dma is ready to start

    input wire  slaveFinExec, ///// the slave dma is finished, so we can go to triggering next

    output wire [BANK1_DST_ADDR_WIDTH -1:0] slave_bank1_out_src_addr,      // actually it is a reg
    output wire [BANK1_DST_SIZE_WIDTH -1:0] slave_bank1_out_src_size,      // actually it is a reg
    output wire [BANK1_DST_ADDR_WIDTH -1:0] slave_bank1_out_des_addr,
    output wire [BANK1_DST_SIZE_WIDTH -1:0] slave_bank1_out_des_size,
    output wire [BANK1_STATUS_WIDTH   -1:0] slave_bank1_out_status  ,      // actually it is a reg
    output wire [BANK1_PROFILE_WIDTH  -1:0] slave_bank1_out_profile        // actually it is a reg



);


localparam STATUS_SHUTDOWN       = 4'b0000;
localparam STATUS_REPROG         = 4'b0001;
localparam STATUS_INITIALIZING   = 4'b0010; // the system is initializing, we can trigger the slave to do something
localparam STATUS_TRIGGERING     = 4'b0011;
localparam STATUS_WAIT4FIN       = 4'b0100;
localparam STATUS_PAUSEONERROR   = 4'b0101; // the system is paused on error, we can not do anything

localparam CTRL_CLEAR            = 4'b0000;
localparam CTRL_SHUTDOWN         = 4'b0001;
localparam CTRL_START            = 4'b0010;

reg [BANK0_STATUS_WIDTH-1:0]    mainStatus;
reg [BANK0_CNT_WIDTH   -1:0]    mainCnt;
reg [BANK0_CNT_WIDTH   -1:0]    endCnt;
/////////////////////////////////////////////////
////// BANK 1 slot table wire declaration ///////
/////////////////////////////////////////////////


////// the writing side signal

//////////////  the input pool

wire [BANK1_INDEX_WIDTH    -1:0] bank1_inp_index; // actually it is a wire
wire [BANK1_PROFILE_WIDTH  -1:0] bank1_inp_profile; // it must share with ps and auto inc

wire bank1_set_fin_src_addr;
wire bank1_set_fin_src_size;
wire bank1_set_fin_des_addr;
wire bank1_set_fin_des_size;
wire bank1_set_fin_status;
wire bank1_set_fin_profile;

//////////////  the out pool
wire [BANK1_INDEX_WIDTH    -1:0] bank1_out_index; // actually it is a wire
wire [BANK1_DST_ADDR_WIDTH -1:0] bank1_out_src_addr;      // actually it is a reg
wire [BANK1_DST_SIZE_WIDTH -1:0] bank1_out_src_size;      // actually it is a reg
wire [BANK1_DST_ADDR_WIDTH -1:0] bank1_out_des_addr;
wire [BANK1_DST_SIZE_WIDTH -1:0] bank1_out_des_size;
wire [BANK1_STATUS_WIDTH   -1:0] bank1_out_status  ;      // actually it is a reg
wire [BANK1_PROFILE_WIDTH  -1:0] bank1_out_profile ;      // actually it is a reg




///////////////////////////////////////////////
///////// variable setting/getting //////////
///////////////////////////////////////////////

///////////////////////////////////////////////////
//////////// control will be held in state machine
///////////////////////////////////////////////////

////////////////////////////////////
//////////// status setting/////////
////////////////////////////////////
assign ext_bank0_out_status = mainStatus;

////////////////////////////////////
//////////// main counter setting///
////////////////////////////////////
assign ext_bank0_out_mainCnt = mainCnt;
///////////////////////////////////
//////////// end counter setting///
///////////////////////////////////
assign ext_bank0_out_endCnt = endCnt;
always @(posedge clk) begin
    if (reset) begin
        endCnt  <= 0;
    end else if (mainStatus == STATUS_SHUTDOWN) begin
        // if the system is in shutdown state, we can set the endCnt
        if (ext_bank0_set_endCnt) begin
            endCnt <= ext_bank0_inp_endCnt;
        end
    end
    // otherwise, we do not allow to set the endCnt register
end

///////////////////////////////////
//////////// bank1 slot         ///
///////////////////////////////////

////// reading
////////////////////////// only when the system is in shutdown state, we can read the bank1 slot
assign bank1_out_index = (mainStatus == STATUS_SHUTDOWN) ? ext_bank1_out_index: mainCnt;

assign ext_bank1_out_src_addr   = bank1_out_src_addr;
assign ext_bank1_out_src_size   = bank1_out_src_size;
assign ext_bank1_out_des_addr   = bank1_out_des_addr;
assign ext_bank1_out_des_size   = bank1_out_des_size;
assign ext_bank1_out_status     = bank1_out_status;
assign ext_bank1_out_profile    = bank1_out_profile;
assign ext_bank1_out_ready      = ext_bank1_out_req &&  (mainStatus == STATUS_SHUTDOWN);



assign slave_bank1_out_src_addr = bank1_out_src_addr;
assign slave_bank1_out_src_size = bank1_out_src_size;
assign slave_bank1_out_des_addr = bank1_out_des_addr;
assign slave_bank1_out_des_size = bank1_out_des_size;
assign slave_bank1_out_status   = bank1_out_status;
assign slave_bank1_out_profile  = bank1_out_profile;

/////// writing
assign bank1_inp_index             = (mainStatus == STATUS_SHUTDOWN) ? ext_bank1_inp_index : mainCnt;

////////////// writing from external setData
wire ext_bank1_mainActual_set_req = (mainStatus == STATUS_SHUTDOWN) && 
                                    (ext_bank1_set_src_addr | ext_bank1_set_src_size |
                                     ext_bank1_set_des_addr | ext_bank1_set_des_size |
                                     ext_bank1_set_status   | ext_bank1_set_profile);
assign ext_bank1_set_fin_src_addr   = ext_bank1_mainActual_set_req & ext_bank1_set_src_addr;
assign ext_bank1_set_fin_src_size   = ext_bank1_mainActual_set_req & ext_bank1_set_src_size;
assign ext_bank1_set_fin_des_addr   = ext_bank1_mainActual_set_req & ext_bank1_set_des_addr;
assign ext_bank1_set_fin_des_size   = ext_bank1_mainActual_set_req & ext_bank1_set_des_size;
assign ext_bank1_set_fin_status     = ext_bank1_mainActual_set_req & ext_bank1_set_status;
assign ext_bank1_set_fin_profile    = ext_bank1_mainActual_set_req & ext_bank1_set_profile;

///////////// writing profiler data

assign bank1_inp_profile = (mainStatus == STATUS_REPROG) ? (slave_bank1_out_profile + 1) : ext_bank1_inp_profile;

////////////// writing pool
assign bank1_set_fin_src_addr       = ext_bank1_set_fin_src_addr;
assign bank1_set_fin_src_size       = ext_bank1_set_fin_src_size;
assign bank1_set_fin_des_addr       = ext_bank1_set_fin_des_addr;
assign bank1_set_fin_des_size       = ext_bank1_set_fin_des_size;
assign bank1_set_fin_status         = ext_bank1_set_fin_status;
assign bank1_set_fin_profile        = ext_bank1_set_fin_profile | (mainStatus == STATUS_REPROG); 


//////////////////////////////////////////////
///////// CONTROL SYSTEM  /////////////////////
///////////////////////////////////////////////

always @(posedge clk or negedge reset ) begin
    
    ///// case the system is commanded by the outsider
    if (~reset) begin
        mainStatus <= STATUS_SHUTDOWN;
        mainCnt    <= 0;
        endCnt     <= 0;
    end else if (ext_bank0_set_control) begin
        case (ext_bank0_inp_control)
            CTRL_CLEAR: begin
                mainStatus <= STATUS_SHUTDOWN;
                mainCnt    <= 0;
            end
            CTRL_SHUTDOWN: begin
                mainStatus <= STATUS_SHUTDOWN;
            end
            CTRL_START: begin
                if (mainStatus == STATUS_SHUTDOWN) begin
                    mainStatus <= STATUS_REPROG;
                    mainCnt    <= 0; // reset the counter
                end
            end
            default: begin
                // do nothing, just keep the current status
            end
        endcase
    end else begin
        
        case (mainStatus)
            STATUS_SHUTDOWN: begin
                // do nothing, just keep the current status
            end
            STATUS_REPROG: begin
                // do nothing, just keep the current status
                // we can trigger the slave to do something
                if (slaveReprogAccept) begin
                    mainStatus <= STATUS_INITIALIZING; // go to initializing state
                end
            end
            STATUS_INITIALIZING: begin
                // do nothing, just keep the current status
                // we can trigger the slave to do something
                if (slaveFinInit) begin
                    mainStatus <= STATUS_TRIGGERING; // go to triggering state
                end
            end
            STATUS_TRIGGERING: begin
                if (slaveStartExecAccept) begin
                    // trigger the slave to start executing
                    mainStatus <= STATUS_WAIT4FIN; // go to wait for finish state
                end
            end
            STATUS_WAIT4FIN: begin
                if(slaveFinExec) begin
                    // the slave has finished executing, we can go to the next step
                    if (mainCnt < endCnt) begin
                        mainCnt <= mainCnt + 1; // increment the counter
                        mainStatus <= STATUS_REPROG; // go back to initializing state
                    end else begin
                        mainCnt    <= 0; // reset the counter
                        mainStatus <= STATUS_SHUTDOWN; // go back to shutdown state
                    end
                end
            end
            default: begin
                // do nothing, just keep the current status
            end
        endcase
    end
    
end

assign slaveReprog = (mainStatus == STATUS_REPROG);
assign slaveInit   = (mainStatus == STATUS_INITIALIZING);
assign slaveStartExec = (mainStatus == STATUS_TRIGGERING);

///////////////////////////////////////////////
///////// BANK1 slot table ///////////////////
///////////////////////////////////////////////

SlotArr #(
.INDEX_WIDTH    (BANK1_INDEX_WIDTH),
.SRC_ADDR_WIDTH (BANK1_SRC_ADDR_WIDTH),
.SRC_SIZE_WIDTH (BANK1_SRC_SIZE_WIDTH),
.DST_ADDR_WIDTH (BANK1_DST_ADDR_WIDTH),
.DST_SIZE_WIDTH (BANK1_DST_SIZE_WIDTH),
.STATUS_WIDTH   (BANK1_STATUS_WIDTH),
.PROFILE_WIDTH  (BANK1_PROFILE_WIDTH)
) dayta (
    .clk(clk),
    .reset(reset),
    // Declare an array of slots
    .inp_index     (bank1_inp_index),
    .inp_src_addr  (ext_bank1_inp_src_addr),
    .inp_src_size  (ext_bank1_inp_src_size),
    .inp_des_addr  (ext_bank1_inp_des_addr),
    .inp_des_size  (ext_bank1_inp_des_size),
    .inp_status    (ext_bank1_inp_status),
    .inp_profile   (bank1_inp_profile), // it must share with ps and auto inc

    .set_src_addr  (bank1_set_fin_src_addr),
    .set_src_size  (bank1_set_fin_src_size),
    .set_des_addr  (bank1_set_fin_des_addr),
    .set_des_size  (bank1_set_fin_des_size),
    .set_status    (bank1_set_fin_status  ),
    .set_profile   (bank1_set_fin_profile ),

    // Output ports0
    .out_index     (bank1_out_index),
    .out_src_addr  (bank1_out_src_addr),      // actually it is a wire
    .out_src_size  (bank1_out_src_size),      // actually it is a wire
    .out_des_addr  (bank1_out_des_addr),      // actually it is a wire
    .out_des_size  (bank1_out_des_size),      // actually it is a wire
    .out_status    (bank1_out_status) ,      // actually it is a wire
    .out_profile   (bank1_out_profile)       // actually it is a wire
);

endmodule



module SlotArr #(

    parameter INDEX_WIDTH = 2, // 2 ^ 2 = 4 slots
    parameter SRC_ADDR_WIDTH = 32,
    parameter SRC_SIZE_WIDTH = 26,
    parameter DST_ADDR_WIDTH = 32,
    parameter DST_SIZE_WIDTH = 26,
    parameter STATUS_WIDTH   = 2,
    parameter PROFILE_WIDTH  = 4
)(
    input wire clk,
    input wire reset,
    // Declare an array of slots
    input wire [INDEX_WIDTH-1:0]    inp_index,
    input wire [SRC_ADDR_WIDTH-1:0] inp_src_addr,
    input wire [SRC_SIZE_WIDTH-1:0] inp_src_size,
    input wire [DST_ADDR_WIDTH-1:0] inp_des_addr,
    input wire [DST_SIZE_WIDTH-1:0] inp_des_size,
    input wire [STATUS_WIDTH-1:0]   inp_status,
    input wire [PROFILE_WIDTH-1:0]  inp_profile,

    input wire set_src_addr,
    input wire set_src_size,
    input wire set_des_addr,
    input wire set_des_size,
    input wire set_status,
    input wire set_profile,

    // Output ports0
    input wire [INDEX_WIDTH-1:0]    out_index,
    output reg [DST_ADDR_WIDTH-1:0] out_src_addr,      // actually it is a wire
    output reg [DST_SIZE_WIDTH-1:0] out_src_size,      // actually it is a wire
    output reg [DST_ADDR_WIDTH-1:0] out_des_addr,      // actually it is a wire
    output reg [DST_SIZE_WIDTH-1:0] out_des_size,      // actually it is a wire
    output reg [STATUS_WIDTH-1:0]   out_status  ,      // actually it is a wire
    output reg [PROFILE_WIDTH-1:0]  out_profile      // actually it is a wire
);
endmodule