module fixed_point_MUL#(
    parameter WIDTH = 16 
)(
    input wire [WIDTH-1:0] A,
    input wire [WIDTH-1:0] B,
    output reg [WIDTH-1:0] out
);

    reg [WIDTH*2-1:0] MUL_TMP;
    always @(*) begin
        MUL_TMP[WIDTH*2-2:0] = A[WIDTH-2:0] * B[WIDTH-2:0]; 
        MUL_TMP[WIDTH*2-1] = A[WIDTH-1] ^ B[WIDTH-1];
    end

    always @(*) begin
        out[WIDTH-1] = MUL_TMP[WIDTH*2-1];
        out[WIDTH-2:0] = MUL_TMP[24:10];
    end

endmodule