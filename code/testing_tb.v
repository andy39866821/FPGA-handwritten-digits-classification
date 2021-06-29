module test_tb(

);


    parameter WIDTH = 8;

    reg clk=0;
    reg clk_a=0;
    reg rst;
    wire[3:0] predict_number;
    wire read_data;
    wire[9:0]read_addr;
    reg [783:0]data;
    initial begin
        #100 rst = 1;clk=0;data={780'b0,4'b0001};
        #100 rst = 0;

        #10000 $finish;

    end
    always 
        #4 clk <= ~clk;
    always
        #1 clk_a <= ~clk_a;

    
    nn_test nn_test_inst(
        .clk(clk),
        .clk_a(clk_a),
        .rst(rst),
        .read_data(read_data),
        .read_addr(read_addr),
        .predict_number(predict_number)
    );
    blk_mem_gen_number_784 blk_mem_gen_number_784_inst(
        .clka(clk_a),
		.wea(0),
		.addra(read_addr),
		.dina(0),
        .douta(read_data)
    );


endmodule