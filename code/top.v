module top(
    input clk,
    input rst,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output [3:0]AN,
    output [6:0]SEG,
    inout PS2_CLK,
    inout PS2_DATA
);

    wire clk_25MHz;
    wire clk_segment;
    wire valid;
    wire in_canvas;
    wire enable_mouse_display;
    wire MOUSE_LEFT,MOUSE_MIDDLE,MOUSE_RIGHT,MOUSE_NEW_EVENT;
    wire write_enable;
    wire canvas_write_data,canvas_read_data,input_write_data;
    wire NN_read_data;
    wire [3:0]predict_number;
    wire [3:0]mouse_cursor_red , mouse_cursor_green , mouse_cursor_blue;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    wire [9:0] MOUSE_X_POS,MOUSE_Y_POS;
    wire [9:0] canvas_write_addr,canvas_read_addr; //log2(28*28) ~= 10
    wire [9:0] input_write_addr;
    wire [9:0] NN_read_addr;
    wire [11:0] mouse_pixel = {mouse_cursor_red, mouse_cursor_green, mouse_cursor_blue};

    clock_divisor ckd(
      	.clk(clk),
      	.clk1(clk_25MHz),
      	.clk17(clk_segment)
    );
    canvas canvas_inst(
        .clk(clk), 
        .rst(rst),
        .MOUSE_LEFT(MOUSE_LEFT),
        .MOUSE_MIDDLE(MOUSE_MIDDLE),
        .MOUSE_RIGHT(MOUSE_RIGHT),
        .MOUSE_X_POS(MOUSE_X_POS),
        .MOUSE_Y_POS(MOUSE_Y_POS),
        .write_enable(write_enable),
        .input_write_addr(input_write_addr),
        .input_write_data(input_write_data)
    );
    mem_addr_gen mem_addr_gen_inst(
        .clk(clk),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(canvas_read_addr),
        .in_canvas(in_canvas)
    );
    blk_mem_gen_canvas blk_mem_gen_canvas_inst(
      //WRITE
      .clka(clk),
      .wea(write_enable),
      .addra(input_write_addr),
      .dina(input_write_data),
      //READ
      .clkb(clk),
      .addrb(canvas_read_addr),
      .doutb(canvas_read_data)
    );
    blk_mem_gen_input blk_mem_gen_input_inst(
      //WRITE
      .clka(clk),
      .wea(write_enable),
      .addra(input_write_addr),
      .dina(input_write_data),
      //READ
      .clkb(clk),
      .addrb(NN_read_addr),
      .doutb(NN_read_data)
    );
    pixel_gen pixel_gen_inst(
       .rst(rst),
       .in_canvas(in_canvas),
       .valid(valid),
       .enable_mouse_display(enable_mouse_display),
       .mouse_pixel(mouse_pixel),
       .canvas_pixel(canvas_read_data),
       .vgaRed(vgaRed),
       .vgaGreen(vgaGreen),
       .vgaBlue(vgaBlue)
    );
    

    vga_controller vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
    
    mouse mouse_ctrl_inst(
        .clk(clk),
        .h_cntr_reg(h_cnt),
        .v_cntr_reg(v_cnt),
        .enable_mouse_display(enable_mouse_display),
        .MOUSE_X_POS(MOUSE_X_POS),
        .MOUSE_Y_POS(MOUSE_Y_POS),
        .MOUSE_LEFT(MOUSE_LEFT),
        .MOUSE_MIDDLE(MOUSE_MIDDLE),
        .MOUSE_RIGHT(MOUSE_RIGHT),
        .MOUSE_NEW_EVENT(MOUSE_NEW_EVENT),
        .mouse_cursor_red(mouse_cursor_red),
        .mouse_cursor_green(mouse_cursor_green),
        .mouse_cursor_blue(mouse_cursor_blue),
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA)
    );

    neural_network NN(
        .clk_a(clk),
        .clk(clk_25MHz),
        .rst(rst),
        .read_data(NN_read_data),
        .read_addr(NN_read_addr),
        .predict_number(predict_number)
    );

    seven_segment_display seven_segment_inst(
      .clk(clk_segment),
      .number(predict_number),
      .AN(AN),
      .SEG(SEG)
    );

endmodule
