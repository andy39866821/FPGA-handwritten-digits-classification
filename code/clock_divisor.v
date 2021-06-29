module clock_divisor(
 	input wire clk,
  	output wire clk1,
  	output wire clk17
);


	reg [17:0] num,next_num;

	always @(posedge clk) begin
	num <= next_num;
	end

	always @(*) begin
		next_num = num + 1'b1;
	end

	assign clk1 = num[1];
	assign clk17 = num[17];

endmodule
