`timescale 1ns/1ns 

module simpleadder_tb();

	import simpleadder_pkg::*;

	bit clk;

	always #5 clk = ~clk;

	simpleadder_if f_if(clk);

	virtual simpleadder_if v_inf;

	test test_h;

	simpleadder simp1(
		.clk(clk),
		.en_i(f_if.en_i),
		.ina(f_if.in_a),
		.inb(f_if.in_b),
		.en_o(f_if.en_o),
		.out(f_if.out)
		);

	initial begin
    	$vcdplusfile("output/simpleadder.vpd");   // Specify VPD file name
    	$vcdpluson;                        		 // Start dumping signals
	end

	initial begin
		v_inf = f_if;
		test_h = new(v_inf);
    	fork
    		test_h.execute();
    	join_none
		@f_if.finish_the_test;
		$display("TIME: %0t Correct Checks: %0d, Incorrect Checks: %0d", $time(), f_if.correct_checks, f_if.incorrect_checks);
		#1;
		$finish;
	end

	final begin
		$display("TIME: %0t Correct Checks: %0d, Incorrect Checks: %0d", $time(), f_if.correct_checks, f_if.incorrect_checks);
	end

endmodule : simpleadder_tb