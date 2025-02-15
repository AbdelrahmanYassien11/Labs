module tb;

	bit clk;

	always #5 clk = ~clk;

	logic rst_n;
	bit signed [4:0] A, B;
	bit a_en, b_en, ALU_en;
	bit [2:0] a_op;
	bit [1:0] b_op;
	logic [5:0] C;

	alu_d alu1(
		.clk(clk),
		.rst_n(rst_n),
		.A(A),
		.B(B),
		.a_en(a_en),
		.b_en(b_en),
		.ALU_en(ALU_en),
		.a_op(a_op),
		.b_op(b_op),
		.C(C)
	);

	initial begin
		// rst_n = 1;
		// b_op = 0;
		// a_op = 0;
		// ALU_en = 1;
		@(posedge clk);
		$display("atlas");
		@(negedge clk);
		$display("atlas1");

	end

endmodule : tb