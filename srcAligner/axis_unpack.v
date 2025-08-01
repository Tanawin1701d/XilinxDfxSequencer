module axis_unpacker 
# (
    parameter DATA_WIDTH_DES = 256,
    parameter DATA_WIDTH_ALG = 8,
    parameter PACK_SIZE = 4
)
 (

        // AXIS Slave Interface   store in terface
    input  wire [PACK_SIZE * (DATA_WIDTH_DES/DATA_WIDTH_ALG) -1: 0]     S_AXI_TDATA,
//    input  wire [DATA_WIDTH/8-1:0]   S_AXI_TKEEP,  // <= tkeep added
    input  wire                            S_AXI_TVALID,
    output wire                            S_AXI_TREADY,
    input  wire                            S_AXI_TLAST,

    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH_DES-1: 0] M_AXI_TDATA,
//    output  reg [DATA_WIDTH/8-1:0]   M_AXI_TKEEP,  // <= tkeep added
    output  wire                             M_AXI_TVALID,
    input   wire                             M_AXI_TREADY,
    output  wire                             M_AXI_TLAST,
    
    input   wire clk,
    input   wire reset
);


    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH_DES/DATA_WIDTH_ALG; i = i + 1) begin : pack_loop
            assign M_AXI_TDATA[i*DATA_WIDTH_ALG +: PACK_SIZE] = S_AXI_TDATA[i*PACK_SIZE +: PACK_SIZE];
            assign M_AXI_TDATA[(i+1)*DATA_WIDTH_ALG-1: (i*DATA_WIDTH_ALG)+PACK_SIZE] = 0; // Zero padding for unused bits
        end
    endgenerate

    ////// slave side
    assign S_AXI_TREADY = M_AXI_TREADY;
    ////// master side
    assign M_AXI_TVALID = S_AXI_TVALID;
    assign M_AXI_TLAST  = S_AXI_TLAST;



    
endmodule