module MagicSeqCore #(

    parameter BANK1_INDEX_WIDTH = 2, // 2 ^ 2 = 4 slots
    parameter BANK1_SRC_ADDR_WIDTH = 32,
    parameter BANK1_SRC_SIZE_WIDTH = 26,
    parameter BANK1_DST_ADDR_WIDTH = 32,
    parameter BANK1_DST_SIZE_WIDTH = 26,
    parameter BANK1_STATUS_WIDTH   = 2,
    parameter BANK1_PROFILE_WIDTH  = 4,

    parameter BANK0_CONTROL_WIDTH = 4,
    parameter BANK0_STATUS_WIDTH  = 4,
    parameter BANK0_CNT_WIDTH = BANK1_INDEX_WIDTH /// the counter for the sequencer


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
    input wire ext_bank1_set_status,
    input wire ext_bank1_set_profile,

    output wire bank1_set_actual_src_addr, /// status of the register
    output wire bank1_set_actual_src_size, /// status of the register
    output wire bank1_set_actual_status, /// status of the register  
    output wire bank1_set_actual_profile, /// status of the register 

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
    input wire [BANK0_CONTROL_WIDTH-1:0] ext_bank0_inp_control, /// read only
    input wire                           ext_bank0_set_control, /// set control

    output wire [BANK0_STATUS_WIDTH-1:0] ext_bank0_out_status,  /// read only and it is reg
    output wire [BANK0_CNT_WIDTH-1:0]    ext_bank0_out_mainCnt,     /// read only

    input  wire [BANK0_CNT_WIDTH-1:0]    ext_bank0_inp_endCnt,      ///
    input  wire                          ext_bank0_set_endCnt,      ///
    output wire [BANK0_CNT_WIDTH-1:0]    ext_bank0_out_endCnt       /// read only

);


localparam STATUS_SHUTDOWN       = 4'b0000;
localparam STATUS_EXECUTING      = 4'b0001;
localparam STATUS_PAUSE_ON_ERROR = 4'b0010;

localparam CTRL_CLEAR            = 4'b0000;
localparam CTRL_SHUTDOWN         = 4'b0001;
localparam CTRL_START            = 4'b0010;

reg [BANK0_STATUS_WIDTH-1:0]    mainStatus;
reg [BANK0_CNT_WIDTH   -1:0]    mainCnt;
reg [BANK0_CNT_WIDTH   -1:0]    endCnt;

////// BAN

wire [BANK1_DST_ADDR_WIDTH -1:0] bank1_out_src_addr;      // actually it is a reg
wire [BANK1_DST_SIZE_WIDTH -1:0] bank1_out_src_size;      // actually it is a reg
wire [BANK1_DST_ADDR_WIDTH -1:0] bank1_out_des_addr;
wire [BANK1_DST_SIZE_WIDTH -1:0] bank1_out_des_size;
wire [BANK1_STATUS_WIDTH   -1:0] bank1_out_status  ;      // actually it is a reg
wire [BANK1_PROFILE_WIDTH  -1:0] bank1_out_profile ;       // actually it is a reg

wire bank1_mainActual_set_req = (mainStatus == STATUS_SHUTDOWN) && 
                                (ext_bank1_set_src_addr | ext_bank1_set_src_size |
                                 ext_bank1_set_status   | ext_bank1_set_profile);
assign bank1_set_actual_src_addr   = bank1_mainActual_set_req & ext_bank1_set_src_addr;
assign bank1_set_actual_src_size   = bank1_mainActual_set_req & ext_bank1_set_src_size;
assign bank1_set_actual_status     = bank1_mainActual_set_req & ext_bank1_set_status;
assign bank1_set_actual_profile    = bank1_mainActual_set_req & ext_bank1_set_profile;



//////// the system will not allow to set any regiter while the system is in executing or pause on error state

//////////// end counter setting
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

assign ext_bank1_out_src_addr = bank1_out_src_addr;
assign ext_bank1_out_src_size = bank1_out_src_size;
assign ext_bank1_out_des_addr = bank1_out_des_addr;
assign ext_bank1_out_des_size = bank1_out_des_size;
assign ext_bank1_out_status   = bank1_out_status;
assign ext_bank1_out_profile  = bank1_out_profile;
assign ext_bank1_out_ready = ext_bank1_out_req &&  (mainStatus == STATUS_SHUTDOWN);




endmodule