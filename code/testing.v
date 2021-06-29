module nn_test #(
    parameter WIDTH = 16,
    parameter INPUT_COUNT = 784,
    parameter HIDDEN_COUNT = 64,
    parameter OUTPUT_COUNT = 10,
    parameter ADDRESS_WIDTH = 16,
    parameter INPUT_LAYER_WEIGHT_COUNT = 50240,
    parameter HIDDEN_LAYER_WEIGHT_COUNT = 650,
    
    parameter RESET = 3'd0,
    parameter MULTI = 3'd1,
    parameter ACCUMULATE = 3'd2,
    parameter IDLE = 3'd3
)(
    input wire clk,
    input wire clk_a,
    input wire rst,
    input wire read_data,
    output reg [9:0]read_addr,
    output reg [3:0] predict_number
);

    // nn architrcture
    // 784 input  => 8 elements hidden layer => 10 elements output layer

    // all parameter are stored in 16 bits floating point
    // signed bits | integer bits | floating point bits
    //     1       |       7      |        8
    

    reg [3:0] next_predict_number;
    reg [2:0] input_state;
    reg [2:0] next_input_state;
    reg [2:0] hidden_state;
    reg [2:0] next_hidden_state;
    reg [WIDTH-1:0]next_hidden_layer_accumulate[0:HIDDEN_COUNT-1];// 8 hidden layers's element before relu function
    reg [WIDTH-1:0]next_output_layer_accumulate[0:OUTPUT_COUNT-1];// 10 output layers's element after matrix multiplication
    reg [WIDTH-1:0]hidden_layer_accumulate[0:HIDDEN_COUNT-1];// 8 hidden layers's element before relu function
    reg [WIDTH-1:0] hidden_layer_activation[0:HIDDEN_COUNT-1];// 8 hidden layers's element after relu function : activations
    wire[WIDTH-1:0] hidden_layer_ADD; // output of fixed point adder
    wire[WIDTH-1:0] output_layer_ADD; // output of fixed point adder
    reg [WIDTH-1:0]output_layer_accumulate[0:OUTPUT_COUNT-1];// 10 output layers's element after matrix multiplication
    
    reg [ADDRESS_WIDTH-1:0] input_layer_weight_addr;
    reg [ADDRESS_WIDTH-1:0] next_input_layer_weight_addr;
    reg [ADDRESS_WIDTH-1:0] hidden_layer_weight_addr;
    reg [ADDRESS_WIDTH-1:0] next_hidden_layer_weight_addr;
    wire[WIDTH-1:0]input_layer_weight;
    wire[WIDTH-1:0]hidden_layer_weight;
    reg [WIDTH-1:0]input_layer_weight_to_add;
    reg [WIDTH-1:0]hidden_layer_weight_to_add;
    wire[WIDTH-1:0]hidden_layer_matrix_MUL;


    reg [INPUT_COUNT-1:0] in;
    reg [INPUT_COUNT-1:0] next_in;
    reg [9:0] next_read_addr;
    reg changed,next_changed;
    integer i;
    integer index;
    
    ////////////////////////////////
    // read data
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            read_addr <= 0;
            in <= 0;
            changed <= 0;
        end
        else begin
            read_addr <= next_read_addr;
            in <= next_in;
            changed <= next_changed;
        end
    end

    always @(*) begin
        next_in = in;
        next_changed = (in[read_addr]!=read_data);
        next_in[read_addr] = read_data;
        next_read_addr = (read_addr==INPUT_COUNT-1 ? 0 : read_addr + 1);
    end
    
    //////////////////////////////////
    // state DFF

    always @(posedge clk or posedge rst) begin
        if(rst) 
            input_state <= RESET;  
        else
            input_state <= next_input_state;
    end

    always @(*) begin
        if(changed == 1)
            next_input_state = RESET;
        else if(input_state==RESET)
            next_input_state = ACCUMULATE;
        else if(input_state==ACCUMULATE && input_layer_weight_addr==INPUT_LAYER_WEIGHT_COUNT-1) 
            next_input_state = IDLE;
        else
            next_input_state = input_state;
    end


    ///////////////////////////////////
    // input layer weight address DFF

    always @(posedge clk or posedge rst) begin // input_layer_weight address
        if(rst)
            input_layer_weight_addr <= 0;
        else begin
            input_layer_weight_addr <= next_input_layer_weight_addr;
        end
    end

    always @(*) begin
        if(input_state==RESET)
            next_input_layer_weight_addr = 0;
        else if(input_state==ACCUMULATE) 
            next_input_layer_weight_addr = (input_layer_weight_addr<INPUT_LAYER_WEIGHT_COUNT-1? input_layer_weight_addr + 1:input_layer_weight_addr);
        else
            next_input_layer_weight_addr = input_layer_weight_addr;
    end
    blk_mem_gen_input_layer_weight_785x64 blk_mem_gen_input_layer_weight_785x64_inst(
        .clka(clk_a),
		.wea(0),
		.addra(input_layer_weight_addr),
		.dina(0),
        .douta(input_layer_weight)
    );
    ///////////////////////////////////
    //input accumulate

    fixed_point_ADD #(
        .WIDTH(WIDTH)
    )FPA_inst(
        .A(hidden_layer_accumulate[input_layer_weight_addr%HIDDEN_COUNT]),
        .B(input_layer_weight_to_add),
        .out(hidden_layer_ADD)
    );
    always @(posedge clk or posedge rst) begin // input_layer_weight address
        if(rst) begin
            for(i = 0; i <HIDDEN_COUNT ; i=i+1)
                hidden_layer_accumulate[i] <= 0;
        end
        else begin
            for(i = 0; i <HIDDEN_COUNT ; i=i+1)
                hidden_layer_accumulate[i] <= next_hidden_layer_accumulate[i];
        end
    end

    always @(*) begin
        for(i = 0; i <HIDDEN_COUNT ; i=i+1)
            next_hidden_layer_accumulate[i] = hidden_layer_accumulate[i];

        if(input_state==RESET) begin
            for(i = 0; i <HIDDEN_COUNT ; i=i+1)
                next_hidden_layer_accumulate[i] = 0;
        end
        else if(input_state==ACCUMULATE)  begin
            i= input_layer_weight_addr%HIDDEN_COUNT;
            next_hidden_layer_accumulate[i] =  hidden_layer_ADD;
        end
        else begin
            
        end
    end

    always @(*) begin
        if(input_state==RESET) begin
            input_layer_weight_to_add = 0;
        end
        else if(input_state==ACCUMULATE)  begin
            if(input_layer_weight_addr/HIDDEN_COUNT < INPUT_COUNT)
                input_layer_weight_to_add = {WIDTH{in[input_layer_weight_addr/HIDDEN_COUNT]}} & input_layer_weight;
            else
                input_layer_weight_to_add = input_layer_weight;
        end
        else begin
            input_layer_weight_to_add = 0;
        end
    end
    /////////////////////////////////
    // hidden layer activation by reLU function

    always @(*) begin
        for(i = 0; i <HIDDEN_COUNT ; i=i+1)
            hidden_layer_activation[i] = (hidden_layer_accumulate[i][WIDTH-1]==1 ? 0 : hidden_layer_accumulate[i]);
    end


    //////////////////////////////////
    //hidden layer state DFF

    always @(posedge clk or posedge rst) begin
        if(rst)
            hidden_state <= RESET;
        else
            hidden_state <= next_hidden_state;
    end

    always @(*) begin
        if(input_state != IDLE)
            next_hidden_state = RESET;
        else if(hidden_state == RESET)
            next_hidden_state = ACCUMULATE;
        else if(hidden_state == ACCUMULATE && hidden_layer_weight_addr == HIDDEN_LAYER_WEIGHT_COUNT-1) 
            next_hidden_state = IDLE;
        else
            next_hidden_state = hidden_state;
    end

    //////////////////////////////////
    //hidden layer weight address DFF
    always @(posedge clk or posedge rst) begin 
        if(rst)
            hidden_layer_weight_addr <= 0;
        else begin
            hidden_layer_weight_addr <= next_hidden_layer_weight_addr;
        end
    end

    always @(*) begin
        if(hidden_state==RESET)
            next_hidden_layer_weight_addr = 0;
        else if(hidden_state==ACCUMULATE) 
            next_hidden_layer_weight_addr = (hidden_layer_weight_addr<HIDDEN_LAYER_WEIGHT_COUNT-1? hidden_layer_weight_addr + 1:hidden_layer_weight_addr);
        else
            next_hidden_layer_weight_addr = hidden_layer_weight_addr;
    end

    blk_mem_gen_hidden_layer_weight_65x10 blk_mem_gen_hidden_layer_weight_65x10_inst(
        .clka(clk_a),
		.wea(0),
		.addra(hidden_layer_weight_addr),
		.dina(0),
        .douta(hidden_layer_weight)
    );

    //////////////////////////////////
    // hidden layer MUL

    fixed_point_MUL FPM_inst(
        .A(hidden_layer_activation[hidden_layer_weight_addr/OUTPUT_COUNT]),
        .B(hidden_layer_weight),
        .out(hidden_layer_matrix_MUL)
    );
    
    //////////////////////////////////
    //output accumulate

    fixed_point_ADD #(
        .WIDTH(WIDTH)
    )FPA_inst_hidden(
        .A(output_layer_accumulate[hidden_layer_weight_addr%OUTPUT_COUNT]),
        .B(hidden_layer_weight_to_add),
        .out(output_layer_ADD)
    );
    always @(posedge clk or posedge rst) begin // input_layer_weight address
        if(rst) begin
            for(i = 0; i <OUTPUT_COUNT ; i=i+1)
                output_layer_accumulate[i] <= 0;
        end
        else begin
            for(i = 0; i <OUTPUT_COUNT ; i=i+1)
                output_layer_accumulate[i] <= next_output_layer_accumulate[i];
        end
    end

    always @(*) begin
        for(i = 0; i <OUTPUT_COUNT ; i=i+1)
            next_output_layer_accumulate[i] = output_layer_accumulate[i];

        if(hidden_state==RESET) begin
            for(i = 0; i <OUTPUT_COUNT ; i=i+1)
                next_output_layer_accumulate[i] = 0;
        end
        else if(hidden_state==ACCUMULATE)  begin
            i= hidden_layer_weight_addr%OUTPUT_COUNT;
            next_output_layer_accumulate[i] =  output_layer_ADD;
        end
        else begin
            
        end
    end

    always @(*) begin
        if(hidden_state==RESET) begin
            hidden_layer_weight_to_add = 0;
        end
        else if(hidden_state==ACCUMULATE)  begin
            if(hidden_layer_weight_addr/OUTPUT_COUNT < HIDDEN_COUNT)
                hidden_layer_weight_to_add = hidden_layer_matrix_MUL;
            else
                hidden_layer_weight_to_add = hidden_layer_weight;
        end
        else begin
            hidden_layer_weight_to_add = 0;
        end
    end

    //////////////////////////////////
    // comapre 10 output to predict number
    always @(*) begin
        if(hidden_state!=IDLE)
            predict_number = 1;
        else begin
            index = 0;
            for(i=0; i<OUTPUT_COUNT ; i=i+1) begin
                if(output_layer_accumulate[i][WIDTH-1]==1) begin // challenger < 0
                    if(output_layer_accumulate[index][WIDTH-1]==1) begin // prtector < 0
                        if(output_layer_accumulate[i][WIDTH-2:0] >= output_layer_accumulate[index][WIDTH-2:0])
                            index = index;
                        else
                            index = i;
                    end
                    else begin // prtector >= 0
                        index = index;
                    end
                end
                else begin // challenger >= 0
                    if(output_layer_accumulate[index][WIDTH-1]==1) begin // prtector < 0
                        index = i;
                    end
                    else begin // prtector >= 0
                        if(output_layer_accumulate[i][WIDTH-2:0] >= output_layer_accumulate[index][WIDTH-2:0])
                            index = i;
                        else
                            index = index;
                    end
                end
            end

            predict_number = index;
        end

    end
    ////////////////////////////////


endmodule