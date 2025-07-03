module SlotArr #(

    parameter INDEX_WIDTH = 2, // 2 ^ 2 = 4 slots
    parameter SRC_ADDR_WIDTH = 32,
    parameter SRC_SIZE_WIDTH = 26,
    parameter DST_ADDR_WIDTH = 32,
    parameter DST_SIZE_WIDTH = 26,
    parameter STATUS_WIDTH   = 2,
    parameter PROFILE_WIDTH  = 32
)(
    input wire clk,
    input wire reset,
    // Declare an array of slots
    input wire [INDEX_WIDTH   -1:0] inp_index,
    input wire [SRC_ADDR_WIDTH-1:0] inp_src_addr,
    input wire [SRC_SIZE_WIDTH-1:0] inp_src_size,
    input wire [DST_ADDR_WIDTH-1:0] inp_des_addr,
    input wire [DST_SIZE_WIDTH-1:0] inp_des_size,
    input wire [STATUS_WIDTH  -1:0] inp_status,
    input wire [PROFILE_WIDTH -1:0] inp_profile,

    input wire set_src_addr,
    input wire set_src_size,
    input wire set_des_addr,
    input wire set_des_size,
    input wire set_status,
    input wire set_profile,

    // Output ports0
    input  wire [INDEX_WIDTH   -1:0] out_index,
    output wire [SRC_ADDR_WIDTH-1:0] out_src_addr,
    output wire [SRC_SIZE_WIDTH-1:0] out_src_size,
    output wire [DST_ADDR_WIDTH-1:0] out_des_addr,
    output wire [DST_SIZE_WIDTH-1:0] out_des_size,
    output wire [STATUS_WIDTH  -1:0] out_status  ,
    output wire [PROFILE_WIDTH -1:0] out_profile
);

    reg [SRC_ADDR_WIDTH-1:0] src_addrs [0: (1 << (INDEX_WIDTH)) -1];
    reg [SRC_SIZE_WIDTH-1:0] src_sizes [0: (1 << (INDEX_WIDTH)) -1];
    reg [DST_ADDR_WIDTH-1:0] des_addrs [0: (1 << (INDEX_WIDTH)) -1];
    reg [DST_SIZE_WIDTH-1:0] des_sizes [0: (1 << (INDEX_WIDTH)) -1];
    reg [STATUS_WIDTH  -1:0] statuss   [0: (1 << (INDEX_WIDTH)) -1];
    reg [PROFILE_WIDTH -1:0] profiles  [0: (1 << (INDEX_WIDTH)) -1];

    assign out_src_addr      = src_addrs[out_index];
    assign out_src_size      = src_sizes[out_index];
    assign out_des_addr      = des_addrs[out_index];
    assign out_des_size      = des_sizes[out_index];
    assign out_status        = statuss  [out_index];
    assign out_profile       = profiles [out_index];

    always @(posedge clk) begin
        
        if (set_src_addr ) begin src_addrs[inp_index] <= inp_src_addr;   end
        if (set_src_size ) begin src_sizes[inp_index] <= inp_src_size;   end
        if (set_des_addr ) begin des_addrs[inp_index] <= inp_des_addr;   end
        if (set_des_size ) begin des_sizes[inp_index] <= inp_des_size;   end
        if (set_status   ) begin statuss  [inp_index] <= inp_status;     end
        if (set_profile  ) begin profiles [inp_index] <= inp_profile;    end

    end


endmodule
