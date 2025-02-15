module atlas_tb();

	bit clk;
	always #5 clk = ~clk;

	bit signed [4:0] in1;
	logic signed [5:0] out1;
	bit signed [5:0] out2;

	initial begin
		in1 = -14; //2'b11 + 1; 01+1 = 10...........2'b10 - 2'b01... 
	end


	always@(posedge clk)begin
		out1 <= in1 -1 ;
		out2 <= in1 -1;
		$display("out1:%0d, out2:%0d", out1, out2);
	end
endmodule : atlas_tb