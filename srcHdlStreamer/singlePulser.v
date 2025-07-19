module singlePulser #(
    parameter WIDTH = 1
)(
    input wire clk,
    input wire rst_n, // active low reset
    input wire [WIDTH-1:0] in,
    output reg [WIDTH-1:0] pulse
);

    reg [WIDTH-1:0] in_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_d  <= {WIDTH{1'b0}};
            pulse <= {WIDTH{1'b0}};
        end else begin
            pulse <= in & ~in_d;
            in_d  <= in;
        end
    end

endmodule