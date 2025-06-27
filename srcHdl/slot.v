module Slot #(
    parameter SRC_ADDR_WIDTH = 32,
    parameter SRC_SIZE_WIDTH = 26,
    parameter DST_ADDR_WIDTH = 32,
    parameter DST_SIZE_WIDTH = 26,
    parameter STATUS_WIDTH   = 2,
    parameter PROFILE_WIDTH  = 4,
    parameter INPUT_IDX_WIDTH = 1,
    parameter CUR_IDX = 0
) (
    input wire clk,
    input wire reset,
    input wire [INPUT_IDX_WIDTH-1: 0]    inputIdx,

    // set Input ports
    input wire [SRC_ADDR_WIDTH-1:0] inp_src_addr,
    input wire [SRC_SIZE_WIDTH-1:0] inp_src_size,
    input wire [STATUS_WIDTH-1:0]   inp_status,
    input wire [PROFILE_WIDTH-1:0]  inp_profile,
    // set trigger ports
    input wire                      set_src_addr,
    input wire                      set_src_size,
    input wire                      set_status,
    input wire                      set_profile,
    // dest output ports
    output reg [DST_ADDR_WIDTH-1:0] out_src_addr,
    output reg [DST_SIZE_WIDTH-1:0] out_src_size,
    output reg [STATUS_WIDTH-1:0]   out_status,
    output reg [PROFILE_WIDTH-1:0]  out_profile
);


//// set trigger ports

always @(posedge clk ) begin
    
    if (reset) begin
        out_src_addr <= 0;
        out_src_size <= 0;
        out_status   <= 0;
        out_profile  <= 0;
    end else begin
        if (inputIdx == CUR_IDX) begin
            // Only update the output if the input index matches the current index
            // This allows for multiple slots to be used in parallel without interference
            if (set_src_addr) begin
            out_src_addr <= inp_src_addr;
            end
            if (set_src_size) begin
                out_src_size <= inp_src_size;
            end
            if (set_status) begin
                out_status   <= inp_status;
            end
            if (set_profile) begin
                out_profile  <= inp_profile;
            end
            end
    end

end
    
endmodule