module unpacker 
# (
    parameter DATA_WIDTH_DES = 256,
    parameter DATA_WIDTH_ALG = 8,
    parameter PACK_SIZE = 4
)
 (
    input  wire[PACK_SIZE * (DATA_WIDTH_DES/DATA_WIDTH_ALG) -1: 0] packedData,
    output wire[DATA_WIDTH_DES-1: 0] rawData
);


    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH_DES/DATA_WIDTH_ALG; i = i + 1) begin : pack_loop
            assign rawData[i*DATA_WIDTH_ALG +: PACK_SIZE] = packedData[i*PACK_SIZE +: PACK_SIZE];
            assign rawData[(i+1)*DATA_WIDTH_ALG-1: (i*DATA_WIDTH_ALG)+PACK_SIZE] = 0; // Zero padding for unused bits
        end
    endgenerate

    
endmodule