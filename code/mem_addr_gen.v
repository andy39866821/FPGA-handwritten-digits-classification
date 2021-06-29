module mem_addr_gen(
    input wire clk,
    input wire rst,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    output reg [9:0] pixel_addr,
    output reg in_canvas
);

   parameter LEFT_BOUND = 0;
   parameter RIGHT_BOUND = 448;
   parameter UPPER_BOUND = 16;
   parameter LOWER_BOUND = 464;
   parameter W = 28;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_addr = 0;
            in_canvas = 1'b0;
        end 
        else begin
            if ( LEFT_BOUND <= h_cnt && h_cnt < RIGHT_BOUND && UPPER_BOUND <= v_cnt && v_cnt < LOWER_BOUND) begin
                pixel_addr = ((h_cnt) >> 4) + ((v_cnt - 16) >> 4) * W;
                in_canvas = 1'b1;
            end 
            else begin
                pixel_addr = 0;
                in_canvas = 1'b0;
            end 
        end
    end

endmodule