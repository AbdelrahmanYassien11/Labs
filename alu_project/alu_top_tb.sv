module alu_tb();

	bit clk;
	always begin #5 clk = ~clk; end

	alu_f a_if(clk);

	alu(a_if);

	test test_h;

	virtual interface v_inf;
	initial begin
		v_inf = a_if;
		test_h = new(v_inf);
	end

	final begin


	end

endmodule : alu_tb

