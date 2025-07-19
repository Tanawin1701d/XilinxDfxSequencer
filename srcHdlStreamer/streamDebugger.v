module streamObs
#(
parameter DATA_WIDTH = 32


)(

input  wire [DATA_WIDTH-1:0]     S_AXI_TDATA,
input  wire [DATA_WIDTH/8-1:0]   S_AXI_TKEEP,  // <= tkeep added
input  wire                      S_AXI_TVALID,
input  wire                      S_AXI_TREADY,
input  wire                      S_AXI_TLAST,

output reg [DATA_WIDTH-1:0]     M_AXI_RCV_CNT,    // it is supposed to be reg
output reg [DATA_WIDTH-1:0]     M_AXI_LST_CNT,
output reg [DATA_WIDTH-1:0]     M_AXI_LST_NC_CNT,

input  wire rst,
input  wire clk
);


always @(posedge clk or negedge rst) begin

    if (~rst) begin
        // Reset logic here
        M_AXI_RCV_CNT <= 0;
        M_AXI_LST_CNT <= 0;
        M_AXI_LST_NC_CNT <= 0;

    end else begin
        // Normal operation logic here
        // For example, you can monitor the S_AXI_TDATA, S_AXI_TKEEP, etc.
        if (S_AXI_TVALID && S_AXI_TREADY) begin
            M_AXI_RCV_CNT <= M_AXI_RCV_CNT + 1;
            
            if (S_AXI_TLAST) begin
                M_AXI_LST_CNT <= M_AXI_LST_CNT + 1;
            end
        end
        if (S_AXI_TREADY) begin
            M_AXI_LST_NC_CNT <= M_AXI_LST_NC_CNT + 1;
        end
        
    end
    
end



endmodule