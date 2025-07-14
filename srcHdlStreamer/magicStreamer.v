module my_axis_slave #
(
    parameter integer DATA_WIDTH        = 32, 
    parameter integer STORAGE_IDX_WIDTH = 10     //// 4 Kb
)
(
    input wire                        clk,
    input wire                        reset,

    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI_TKEEP,  // <= tkeep added
    input  wire                      S_AXI_TVALID,
    output wire                      S_AXI_TREADY,
    input  wire                      S_AXI_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI_TDATA,
    output  wire [DATA_WIDTH/8-1:0]   M_AXI_TKEEP,  // <= tkeep added
    output  wire                      M_AXI_TVALID,
    input   wire                      M_AXI_TREADY,
    output  wire                      M_AXI_TLAST,

    // control signal 

    input wire storeReset,
    input wire loadReset,
    input wire storeInit,
    input wire loadInit,

    // store complete connect it to mgsFinExec
    output wire finStore,

    // out put wire for debugging
    output wire [STATE_BIT_WIDTH-1:0] dbg_state,
    output wire [STORAGE_IDX_WIDTH-1:0] dbg_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH-1:0] dbg_amt_load_bytes

);



///// declare state
localparam STATE_BIT_WIDTH = 4;
localparam STATUS_IDLE  = 4'b0000;
localparam STATUS_STORE = 4'b0001;
localparam STATUS_LOAD  = 4'b0010;

///// meta data 
reg[DATA_WIDTH-1: 0] mainMem [0: ((1 << STORAGE_IDX_WIDTH) - 1)];

reg[STATE_BIT_WIDTH  -1: 0] state;
reg[STORAGE_IDX_WIDTH-1: 0] amt_store_bytes; ///// store to this block
reg[STORAGE_IDX_WIDTH-1: 0] amt_load_bytes;  ///// load to this block
reg storeIntr;

wire[STORAGE_IDX_WIDTH-1: 0] pooled_addr = (state == STATUS_STORE) ? amt_store_bytes : amt_load_bytes;

/////////////////////////////////////
////// axi signal assign ////////////
/////////////////////////////////////

///////// store
assign S_AXI_TREADY = (state == STATUS_STORE) && S_AXI_TVALID;
///////// load
assign M_AXI_TDATA   = mainMem[pooled_addr];
assign M_AXI_TKEEP   = 4'b1111;
assign M_AXI_TVALID  = (state == STATUS_LOAD);
assign M_AXI_TLAST   = (state == STATUS_LOAD) && (amt_load_bytes == (amt_store_bytes-1));
///////// interrupt signal
assign finStore = storeIntr;
/////////// debug signal
assign dbg_state           = state;
assign dbg_amt_store_bytes = amt_store_bytes;
assign dbg_amt_load_bytes  = amt_load_bytes;

/////////////////////////////////////
////// control system    ////////////
/////////////////////////////////////
always @(posedge clk, negedge reset) begin
    
    if (~reset) begin
        state           <= STATUS_IDLE;
        amt_store_bytes <= 0;
        amt_load_bytes  <= 0;
        storeIntr       <= 0;
    end else begin
        case (state) 
            STATUS_IDLE    : begin 
                    if (storeReset) begin
                        amt_store_bytes <= 0;
                        storeIntr       <= 0;
                    end else if (loadReset) begin
                        amt_load_bytes <= 0;
                        storeIntr      <= 0;
                    end else if (storeInit) begin
                        state <= STATUS_STORE;
                    end else if (loadInit) begin
                        state <= STATUS_LOAD;
                    end
            end
            //////////// case store data to the internal memory
            STATUS_STORE    : begin 
                if (S_AXI_TVALID)begin //// we are sure that ready will send this time              
                    mainMem[pooled_addr] <= S_AXI_TDATA;
                    amt_store_bytes <= amt_store_bytes + 1;
                    if (S_AXI_TLAST)begin
                        storeIntr <= 1;
                        state     <= STATUS_IDLE;
                    end
                end
            end
            //////////// case load data from the mainMemory
            STATUS_LOAD    : begin 
                if (M_AXI_TREADY) begin
                    amt_load_bytes <= amt_load_bytes + 1;
                    if (amt_load_bytes == (amt_store_bytes-1)) begin //// assume that amt_store_bytes >= 1
                        state <= STATUS_IDLE;      //// we are sure that valid will send this time              
                    end
                end
            end
            default: begin end

        endcase
    end 

end

endmodule
