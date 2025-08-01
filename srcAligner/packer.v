module packer 
# (
    parameter DATA_WIDTH_SRC = 258,
    parameter DATA_WIDTH_ALG = 8,
    parameter PACK_SIZE = 4
)
 (
    input wire[DATA_WIDTH_SRC-1: 0] rawData,
    output wire[PACK_SIZE*(DATA_WIDTH_SRC/DATA_WIDTH_ALG)-1: 0] packedData
);


    genvar i;
    generate
        for (i = 0; i < (DATA_WIDTH_SRC/DATA_WIDTH_ALG); i = (i + 1)) begin : pack_loop
            assign packedData[i*PACK_SIZE +: PACK_SIZE] = rawData[i*DATA_WIDTH_ALG +: PACK_SIZE];
        end
    endgenerate

    
endmodule