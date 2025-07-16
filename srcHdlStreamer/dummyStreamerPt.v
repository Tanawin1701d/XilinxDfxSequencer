module DummyStreammerPt #
(
    parameter integer DATA_WIDTH        = 32, 
    parameter integer STORAGE_IDX_WIDTH = 10     //// 4 Kb
)
(
    // AXIS Slave Interface   store in terface
    input  wire [DATA_WIDTH-1:0]     S_AXI_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI_TKEEP,  // <= tkeep added
    input  wire                      S_AXI_TVALID,
    output wire                       S_AXI_TREADY,
    input  wire                      S_AXI_TLAST,

    // AXIS Master Interface load interface
    output  reg [DATA_WIDTH-1:0]     M_AXI_TDATA,
    output  reg [DATA_WIDTH/8-1:0]   M_AXI_TKEEP,  // <= tkeep added
    output  reg                      M_AXI_TVALID,
    input   wire                     M_AXI_TREADY,
    output  reg                      M_AXI_TLAST,
    
    input   wire clk,
    input   wire reset
);


assign S_AXI_TREADY = S_AXI_TVALID && (M_AXI_TVALID == M_AXI_TREADY); // Ready when valid and master is ready

always @(posedge clk or negedge reset) begin
    if (~reset) begin
        M_AXI_TDATA  <= 0; // Reset output data
        M_AXI_TKEEP  <= 0; // Reset tkeep
        M_AXI_TVALID <= 1'b0; // Reset valid signal
        M_AXI_TLAST  <= 1'b0; // Reset last signal
    end else if (M_AXI_TVALID == M_AXI_TREADY) begin
        ////// now destination ready to renew
        M_AXI_TDATA  <=  S_AXI_TDATA;
        M_AXI_TKEEP  <=  S_AXI_TKEEP;
        M_AXI_TVALID <=  S_AXI_TVALID;
        M_AXI_TLAST  <=  S_AXI_TLAST;
    end


end







endmodule