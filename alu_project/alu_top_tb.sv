module alu_top_tb();


	import alu_pkg::*;

	bit clk;

	always #5 clk = ~clk; 

	alu_f a_if(clk);

	virtual alu_f v_inf;

	alu #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) alu1( 
		.clk(clk),
		.A(a_if.A),
		.B(a_if.B),
		.a_en(a_if.a_en),
		.b_en(a_if.b_en),
		.a_op(a_if.a_op),
		.b_op(a_if.b_op),
		.rst_n(a_if.rst_n),
		.ALU_en(a_if.ALU_en),
		.C(a_if.C)
		);

	test test_h;

	initial begin
		v_inf = a_if;
		test_h = new(v_inf);
		fork
			test_h.run_test();
		join_none
		@(v_inf.finish_test);
	end

	// final begin


	// end

endmodule : alu_top_tb

