module MagicStreammerPool #
(
    parameter integer DATA_WIDTH = 32,
    parameter integer STORAGE_IDX_WIDTH_0 = 19-2, // 2 ^ 19 = 512 Kb
    parameter integer STORAGE_IDX_WIDTH_1 = 19-2, // 2 ^ 19 = 512 Kb
    parameter integer STORAGE_IDX_WIDTH_2 = 10-2, // 2 ^ 19 = 512 Kb
    parameter integer STORAGE_IDX_WIDTH_3 = 10-2, // 2 ^ 19 = 512 Kb
    parameter integer STORAGE_IDX_WIDTH_4 = 10-2, // 2 ^ 19 = 512 Kb
    parameter integer STORAGE_IDX_WIDTH_5 = 10-2, // 2 ^ 19 = 512 Kb
    parameter integer STORAGE_IDX_WIDTH_6 = 10-2, // 2 ^ 19 = 512 Kb
    parameter integer STORAGE_IDX_WIDTH_7 = 10-2, // 2 ^ 19 = 512 Kb
    parameter integer AMT_STREAMERS = 8,
    parameter integer STATE_BIT_WIDTH = 4

)
(
    input wire                        clk,
    input wire                        reset,
    // control signal
    input wire [AMT_STREAMERS-1: 0]    storeResets,
    input wire [AMT_STREAMERS-1: 0]    loadResets,
    input wire [AMT_STREAMERS-1: 0]    storeInits,
    input wire [AMT_STREAMERS-1: 0]    loadInits,
    output wire[AMT_STREAMERS-1: 0]    finStores,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 0 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI0_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI0_TKEEP,  // <= tkeep added
    input  wire                      S_AXI0_TVALID,
    output wire                      S_AXI0_TREADY,
    input  wire                      S_AXI0_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI0_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI0_TKEEP,    // it is supposed to be wire
    output  wire                     M_AXI0_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI0_TREADY,    // it is supposed to be wire
    output  wire                     M_AXI0_TLAST,    // it is supposed to be wire

    output wire [STATE_BIT_WIDTH-1:0]   dbg0_state,
    output wire [STORAGE_IDX_WIDTH_0-1:0] dbg0_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_0-1:0] dbg0_amt_load_bytes,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 1 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI1_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI1_TKEEP,  // <= tkeep added
    input  wire                      S_AXI1_TVALID,
    output wire                      S_AXI1_TREADY,
    input  wire                      S_AXI1_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI1_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI1_TKEEP,    // it is supposed to be wire
    output  wire                      M_AXI1_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI1_TREADY,    // it is supposed to be wire
    output  wire                      M_AXI1_TLAST,    // it is supposed to be wire

    output wire [STATE_BIT_WIDTH-1:0]   dbg1_state,
    output wire [STORAGE_IDX_WIDTH_1-1:0] dbg1_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_1-1:0] dbg1_amt_load_bytes,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 2 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI2_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI2_TKEEP,  // <= tkeep added
    input  wire                      S_AXI2_TVALID,
    output wire                      S_AXI2_TREADY,
    input  wire                      S_AXI2_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI2_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI2_TKEEP,    // it is supposed to be wire
    output  wire                      M_AXI2_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI2_TREADY,    // it is supposed to be wire
    output  wire                      M_AXI2_TLAST,    // it is supposed to be wire

    output wire [STATE_BIT_WIDTH-1:0]   dbg2_state,
    output wire [STORAGE_IDX_WIDTH_2-1:0] dbg2_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_2-1:0] dbg2_amt_load_bytes,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 3 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI3_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI3_TKEEP,  // <= tkeep added
    input  wire                      S_AXI3_TVALID,
    output wire                      S_AXI3_TREADY,
    input  wire                      S_AXI3_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI3_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI3_TKEEP,    // it is supposed to be wire
    output  wire                      M_AXI3_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI3_TREADY,    // it is supposed to be wire
    output  wire                      M_AXI3_TLAST,    // it is supposed to be wire
    output wire [STATE_BIT_WIDTH-1:0]   dbg3_state,
    output wire [STORAGE_IDX_WIDTH_3-1:0] dbg3_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_3-1:0] dbg3_amt_load_bytes,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 4 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI4_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI4_TKEEP,  // <= tkeep added
    input  wire                      S_AXI4_TVALID,
    output wire                      S_AXI4_TREADY,
    input  wire                      S_AXI4_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI4_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI4_TKEEP,    // it is supposed to be wire
    output  wire                      M_AXI4_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI4_TREADY,    // it is supposed to be wire
    output  wire                      M_AXI4_TLAST,    // it is supposed to be wire
    output wire [STATE_BIT_WIDTH-1:0]   dbg4_state,
    output wire [STORAGE_IDX_WIDTH_4-1:0] dbg4_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_4-1:0] dbg4_amt_load_bytes,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 5 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI5_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI5_TKEEP,  // <= tkeep added
    input  wire                      S_AXI5_TVALID,
    output wire                      S_AXI5_TREADY,
    input  wire                      S_AXI5_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI5_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI5_TKEEP,    // it is supposed to be wire
    output  wire                      M_AXI5_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI5_TREADY,    // it is supposed to be wire
    output  wire                      M_AXI5_TLAST,    // it is supposed to be wire

    output wire [STATE_BIT_WIDTH-1:0]   dbg5_state,
    output wire [STORAGE_IDX_WIDTH_5-1:0] dbg5_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_5-1:0] dbg5_amt_load_bytes,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 6 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI6_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI6_TKEEP,  // <= tkeep added
    input  wire                      S_AXI6_TVALID,
    output wire                      S_AXI6_TREADY,
    input  wire                      S_AXI6_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI6_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI6_TKEEP,    // it is supposed to be wire
    output  wire                      M_AXI6_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI6_TREADY,    // it is supposed to be wire
    output  wire                      M_AXI6_TLAST,    // it is supposed to be wire

    output wire [STATE_BIT_WIDTH-1:0]   dbg6_state,
    output wire [STORAGE_IDX_WIDTH_6-1:0] dbg6_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_6-1:0] dbg6_amt_load_bytes,
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS STREAMER 7 /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI7_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI7_TKEEP,  // <= tkeep added
    input  wire                      S_AXI7_TVALID,
    output wire                      S_AXI7_TREADY,
    input  wire                      S_AXI7_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI7_TDATA,    // it is supposed to be wire
    output  wire [DATA_WIDTH/8-1:0]  M_AXI7_TKEEP,    // it is supposed to be wire
    output  wire                      M_AXI7_TVALID,    // it is supposed to be wire
    input   wire                     M_AXI7_TREADY,    // it is supposed to be wire
    output  wire                      M_AXI7_TLAST,    // it is supposed to be wire

    output wire [STATE_BIT_WIDTH-1:0]   dbg7_state,
    output wire [STORAGE_IDX_WIDTH_7-1:0] dbg7_amt_store_bytes,
    output wire [STORAGE_IDX_WIDTH_7-1:0] dbg7_amt_load_bytes

);


MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_0)) m0(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI0_TDATA),  .S_AXI_TKEEP(S_AXI0_TKEEP), .S_AXI_TVALID(S_AXI0_TVALID),
    .S_AXI_TREADY(S_AXI0_TREADY), .S_AXI_TLAST(S_AXI0_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI0_TDATA),   .M_AXI_TKEEP(M_AXI0_TKEEP), .M_AXI_TVALID(M_AXI0_TVALID),
    .M_AXI_TREADY(M_AXI0_TREADY), .M_AXI_TLAST(M_AXI0_TLAST),
    // control signal
    .storeReset(storeResets[0]), .loadReset(loadResets[0]), .storeInit(storeInits[0]), .loadInit(loadInits[0]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[0]),
    // out put wire for debugging
    .dbg_state(dbg0_state), .dbg_amt_store_bytes(dbg0_amt_store_bytes), .dbg_amt_load_bytes(dbg0_amt_load_bytes)
);

MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_1)) m1(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI1_TDATA),  .S_AXI_TKEEP(S_AXI1_TKEEP), .S_AXI_TVALID(S_AXI1_TVALID),
    .S_AXI_TREADY(S_AXI1_TREADY), .S_AXI_TLAST(S_AXI1_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI1_TDATA),   .M_AXI_TKEEP(M_AXI1_TKEEP), .M_AXI_TVALID(M_AXI1_TVALID),
    .M_AXI_TREADY(M_AXI1_TREADY), .M_AXI_TLAST(M_AXI1_TLAST),
    // control signal
    .storeReset(storeResets[1]), .loadReset(loadResets[1]), .storeInit(storeInits[1]), .loadInit(loadInits[1]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[1]),
    // out put wire for debugging
    .dbg_state(dbg1_state), .dbg_amt_store_bytes(dbg1_amt_store_bytes), .dbg_amt_load_bytes(dbg1_amt_load_bytes)
);

MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_2)) m2(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI2_TDATA),  .S_AXI_TKEEP(S_AXI2_TKEEP), .S_AXI_TVALID(S_AXI2_TVALID),
    .S_AXI_TREADY(S_AXI2_TREADY), .S_AXI_TLAST(S_AXI2_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI2_TDATA),   .M_AXI_TKEEP(M_AXI2_TKEEP), .M_AXI_TVALID(M_AXI2_TVALID),
    .M_AXI_TREADY(M_AXI2_TREADY), .M_AXI_TLAST(M_AXI2_TLAST),
    // control signal
    .storeReset(storeResets[2]), .loadReset(loadResets[2]), .storeInit(storeInits[2]), .loadInit(loadInits[2]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[2]),
    // out put wire for debugging
    .dbg_state(dbg2_state), .dbg_amt_store_bytes(dbg2_amt_store_bytes), .dbg_amt_load_bytes(dbg2_amt_load_bytes)
);

MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_3)) m3(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI3_TDATA),  .S_AXI_TKEEP(S_AXI3_TKEEP), .S_AXI_TVALID(S_AXI3_TVALID),
    .S_AXI_TREADY(S_AXI3_TREADY), .S_AXI_TLAST(S_AXI3_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI3_TDATA),   .M_AXI_TKEEP(M_AXI3_TKEEP), .M_AXI_TVALID(M_AXI3_TVALID),
    .M_AXI_TREADY(M_AXI3_TREADY), .M_AXI_TLAST(M_AXI3_TLAST),
    // control signal
    .storeReset(storeResets[3]), .loadReset(loadResets[3]), .storeInit(storeInits[3]), .loadInit(loadInits[3]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[3]),
    // out put wire for debugging
    .dbg_state(dbg3_state), .dbg_amt_store_bytes(dbg3_amt_store_bytes), .dbg_amt_load_bytes(dbg3_amt_load_bytes)
);

MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_4)) m4(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI4_TDATA),  .S_AXI_TKEEP(S_AXI4_TKEEP), .S_AXI_TVALID(S_AXI4_TVALID),
    .S_AXI_TREADY(S_AXI4_TREADY), .S_AXI_TLAST(S_AXI4_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI4_TDATA),   .M_AXI_TKEEP(M_AXI4_TKEEP), .M_AXI_TVALID(M_AXI4_TVALID),
    .M_AXI_TREADY(M_AXI4_TREADY), .M_AXI_TLAST(M_AXI4_TLAST),
    // control signal
    .storeReset(storeResets[4]), .loadReset(loadResets[4]), .storeInit(storeInits[4]), .loadInit(loadInits[4]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[4]),
    // out put wire for debugging
    .dbg_state(dbg4_state), .dbg_amt_store_bytes(dbg4_amt_store_bytes), .dbg_amt_load_bytes(dbg4_amt_load_bytes)
);

MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_5)) m5(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI5_TDATA),  .S_AXI_TKEEP(S_AXI5_TKEEP), .S_AXI_TVALID(S_AXI5_TVALID),
    .S_AXI_TREADY(S_AXI5_TREADY), .S_AXI_TLAST(S_AXI5_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI5_TDATA),   .M_AXI_TKEEP(M_AXI5_TKEEP), .M_AXI_TVALID(M_AXI5_TVALID),
    .M_AXI_TREADY(M_AXI5_TREADY), .M_AXI_TLAST(M_AXI5_TLAST),
    // control signal
    .storeReset(storeResets[5]), .loadReset(loadResets[5]), .storeInit(storeInits[5]), .loadInit(loadInits[5]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[5]),
    // out put wire for debugging
    .dbg_state(dbg5_state), .dbg_amt_store_bytes(dbg5_amt_store_bytes), .dbg_amt_load_bytes(dbg5_amt_load_bytes)
);

MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_6)) m6(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI6_TDATA),  .S_AXI_TKEEP(S_AXI6_TKEEP), .S_AXI_TVALID(S_AXI6_TVALID),
    .S_AXI_TREADY(S_AXI6_TREADY), .S_AXI_TLAST(S_AXI6_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI6_TDATA),   .M_AXI_TKEEP(M_AXI6_TKEEP), .M_AXI_TVALID(M_AXI6_TVALID),
    .M_AXI_TREADY(M_AXI6_TREADY), .M_AXI_TLAST(M_AXI6_TLAST),
    // control signal
    .storeReset(storeResets[6]), .loadReset(loadResets[6]), .storeInit(storeInits[6]), .loadInit(loadInits[6]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[6]),
    // out put wire for debugging
    .dbg_state(dbg6_state), .dbg_amt_store_bytes(dbg6_amt_store_bytes), .dbg_amt_load_bytes(dbg6_amt_load_bytes)
);

MagicStreammerCore #(.DATA_WIDTH(DATA_WIDTH), .STORAGE_IDX_WIDTH(STORAGE_IDX_WIDTH_7)) m7(
    .clk(clk), .reset(reset),
    // AXIS Slave Interface   store in terface
    .S_AXI_TDATA (S_AXI7_TDATA),  .S_AXI_TKEEP(S_AXI7_TKEEP), .S_AXI_TVALID(S_AXI7_TVALID),
    .S_AXI_TREADY(S_AXI7_TREADY), .S_AXI_TLAST(S_AXI7_TLAST),
    // AXIS Master Interface load interface
    .M_AXI_TDATA(M_AXI7_TDATA),   .M_AXI_TKEEP(M_AXI7_TKEEP), .M_AXI_TVALID(M_AXI7_TVALID),
    .M_AXI_TREADY(M_AXI7_TREADY), .M_AXI_TLAST(M_AXI7_TLAST),
    // control signal
    .storeReset(storeResets[7]), .loadReset(loadResets[7]), .storeInit(storeInits[7]), .loadInit(loadInits[7]),
    // store complete connect it to mgsFinExec
    .finStore(finStores[7]),
    // out put wire for debugging
    .dbg_state(dbg7_state), .dbg_amt_store_bytes(dbg7_amt_store_bytes), .dbg_amt_load_bytes(dbg7_amt_load_bytes)
);


endmodule



// module MagicStreammerCore #
// (
//     parameter integer DATA_WIDTH        = 32, 
//     parameter integer STORAGE_IDX_WIDTH = 10,     //// 4 Kb
//     parameter integer STATE_BIT_WIDTH   =  4
// )
// (
//     input wire                        clk,
//     input wire                        reset,

//     // AXIS Slave Interface   store in terface
//     input  wire [DATA_WIDTH-1:0]     S_AXI_TDATA,
//     input  wire [DATA_WIDTH/8-1:0]   S_AXI_TKEEP,  // <= tkeep added
//     input  wire                      S_AXI_TVALID,
//     output wire                      S_AXI_TREADY,
//     input  wire                      S_AXI_TLAST,

//     // AXIS Master Interface load interface
//     output  reg [DATA_WIDTH-1:0]     M_AXI_TDATA,    // it is supposed to be reg
//     output  wire [DATA_WIDTH/8-1:0]  M_AXI_TKEEP,    // it is supposed to be reg
//     output  reg                      M_AXI_TVALID,    // it is supposed to be reg
//     input   wire                     M_AXI_TREADY,    // it is supposed to be reg
//     output  reg                      M_AXI_TLAST,    // it is supposed to be reg

//     // control signal 

//     input wire storeReset,
//     input wire loadReset,
//     input wire storeInit,
//     input wire loadInit,

//     // store complete connect it to mgsFinExec
//     output wire finStore,

//     // out put wire for debugging
//     output wire [STATE_BIT_WIDTH-1:0]   dbg_state,
//     output wire [STORAGE_IDX_WIDTH-1:0] dbg_amt_store_bytes,
//     output wire [STORAGE_IDX_WIDTH-1:0] dbg_amt_load_bytes

// );

// endmodule
