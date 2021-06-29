module fixed_point_ADD#(
    parameter WIDTH=16
)(
    input wire[WIDTH-1:0]A,
    input wire[WIDTH-1:0]B,
    output reg[WIDTH-1:0]out
);


    always @(*) begin
        if(A[WIDTH-1] == 1) begin//A < 0
            if(B[WIDTH-1] == 1) begin// B < 0
                out[WIDTH-2:0] = A[WIDTH-2:0] + B[WIDTH-2:0];
                out[WIDTH-1] = 1;
            end
            else begin //B >= 0
                if(B[WIDTH-2:0] >= A[WIDTH-2:0]) begin // |B| >= |A|  
                    out[WIDTH-2:0] = B[WIDTH-2:0] - A[WIDTH-2:0];
                    out[WIDTH-1] = 0;
                end
                else begin // |B| < |A|
                    out[WIDTH-2:0] = A[WIDTH-2:0] - B[WIDTH-2:0];
                    out[WIDTH-1] = 1;
                end
            end
        end
        else begin // A >= 0
            if(B[WIDTH-1] == 1) begin// B < 0
                if(B[WIDTH-2:0] >= A[WIDTH-2:0]) begin // |B| >= |A|  
                    out[WIDTH-2:0] = B[WIDTH-2:0] - A[WIDTH-2:0];
                    out[WIDTH-1] = 1;
                end
                else begin // |B| < |A|
                    out[WIDTH-2:0] = A[WIDTH-2:0] - B[WIDTH-2:0];
                    out[WIDTH-1] = 0;
                end
            end
            else begin //B >= 0
                out[WIDTH-2:0] = A[WIDTH-2:0] + B[WIDTH-2:0];
                out[WIDTH-1] = 0;
            end
        end
    end

endmodule