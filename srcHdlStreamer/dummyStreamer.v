module DummyStreammerTop #
(
    parameter integer DATA_WIDTH        = 32, 
    parameter integer STORAGE_IDX_WIDTH = 10     //// 4 Kb
)
(
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
    
    input   wire clk,
    input   wire reset
);

assign S_AXI_TREADY  = 1'b0; // Dummy implementation, always not ready
assign M_AXI_TDATA   = 0; // Dummy implementation, always output zero
assign M_AXI_TKEEP   = 0; // Dummy implementation, always output zero
assign M_AXI_TVALID  = 1'b0; // Dummy implementation, always not valid
assign M_AXI_TLAST   = 1'b0; // Dummy implementation, always not last

endmodule