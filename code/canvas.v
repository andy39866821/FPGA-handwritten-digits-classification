module canvas(
    input clk, rst,
	input MOUSE_LEFT,
    input MOUSE_MIDDLE,
    input MOUSE_RIGHT,
	input [9:0] MOUSE_X_POS,
    input [9:0] MOUSE_Y_POS,
	output reg write_enable,
	output reg [9:0] input_write_addr,
	output reg input_write_data
);

    parameter IDLE = 2'd0;
    parameter PAINT = 2'd1;
    parameter ERASE = 2'd2;
    parameter CLEAR = 2'd3;
    parameter CANVAS_SIZE = 10'd784; // 56*56 = 3136
    parameter LEFT_BOUND = 0;
    parameter RIGHT_BOUND = 448;
    parameter UPPER_BOUND = 16;
    parameter LOWER_BOUND = 464;
    parameter W = 28;

    reg [11:0] clear_count,next_clear_count;
    reg [1:0] state,next_state;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= CLEAR;
            clear_count <= 0;
        end
        else begin
            state <= next_state;
            clear_count <= next_clear_count;
        end
    end

    always @(*) begin
        if(state == CLEAR) begin
            next_clear_count = clear_count + 1;
            next_state = (clear_count == CANVAS_SIZE-1 ? IDLE : CLEAR);
        end
        else if(state == PAINT || state == ERASE) begin
            next_clear_count = 0;
            next_state = (MOUSE_LEFT ? PAINT :(MOUSE_RIGHT? CLEAR:( MOUSE_MIDDLE? ERASE:IDLE)));

        end
        else if(state == IDLE) begin
            next_clear_count = 0;
            next_state = (MOUSE_LEFT ? PAINT :(MOUSE_RIGHT? CLEAR:( MOUSE_MIDDLE? ERASE: IDLE)));
        end
        else begin
            next_clear_count = 0;
            next_state = state;
        end
    end


    
    always @(*) begin
        if(state == CLEAR) begin
            input_write_addr = clear_count;
            input_write_data = 0;
            write_enable = 1;
        end
        else if(state == PAINT || state == ERASE) begin
            if ( LEFT_BOUND <= MOUSE_X_POS && MOUSE_X_POS < RIGHT_BOUND && UPPER_BOUND <= MOUSE_Y_POS && MOUSE_Y_POS < LOWER_BOUND) begin
                write_enable = 1;
                    
                input_write_addr = ((MOUSE_X_POS ) >> 4) + ((MOUSE_Y_POS - 16) >> 4) * W;
                input_write_data = (state == PAINT);
            end
            else begin 
               write_enable = 0;

                input_write_addr = 0;
                input_write_data = 0;
            end
        end
        else if(state == IDLE) begin
            input_write_addr = 0;
            input_write_data = 0;
            write_enable = 0;
        end
        else begin
            
            input_write_addr = 0;
            input_write_data = 0;
            write_enable = 0;
        end
    end




endmodule