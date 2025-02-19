module alu_top_tb();

	import base_classes_pkg::*;
	import alu_pkg::*;

	bit clk;

	always #CLK_PERIOD clk = ~clk; 

	alu_f a_if(clk);

	virtual alu_f v_inf;

	alu #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH), .A_OP_WIDTH(A_OP_WIDTH), .B_OP_WIDTH(B_OP_WIDTH)) alu1( 
		.clk(clk),
		.rst_n(a_if.rst_n),
		.ALU_en(a_if.ALU_en),
		.A(a_if.A),
		.B(a_if.B),
		.a_en(a_if.a_en),
		.b_en(a_if.b_en),
		.a_op(a_if.a_op),
		.b_op(a_if.b_op),
		.C(a_if.C)
		);

	bind alu alu_sva#(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH), .A_OP_WIDTH(A_OP_WIDTH), .B_OP_WIDTH(B_OP_WIDTH) /*.CLK_PERIOD(CLK_PERIOD)*/) sva(a_if.SVA); // bind / dut / module to be instentiated / instance name()


	test_base test_h;
	random_test random_test_h;
	random_error_injection_test random_error_injection_test_h;
	random_reset_thrice_test random_reset_thrice_test_h;

  // Use runtime selection to set the VPD file and choose the test
  initial begin
    string vpd_file;
    // Select VPD file based on runtime plusargs
    if ($test$plusargs("RANDOM_TEST"))
      vpd_file = "output/RANDOM_TEST.vpd";
    else if ($test$plusargs("RANDOM_ERROR_INJECTION_TEST"))
      vpd_file = "output/RANDOM_ERROR_INJECTION_TEST.vpd";
    else if ($test$plusargs("RANDOM_RESET_THRICE_TEST"))
      vpd_file = "output/RANDOM_RESET_THRICE_TEST.vpd";
    else
      vpd_file = "output/RANDOM_TEST.vpd"; // Default

    // Open the VPD file and start dumping signals
    $vcdplusfile(vpd_file);
    $vcdpluson;
  end

	initial begin
		v_inf = a_if;
		test_h = new(v_inf);
		// Create appropriate test type but assign to base class handle
    	if ($test$plusargs("RANDOM_TEST")) begin
            random_test_h = new (v_inf);
        	test_h = random_test_h;
        	$display("starting RANDOM_TEST");
    	end
    	else if ($test$plusargs("RANDOM_ERROR_INJECTION_TEST")) begin
            random_error_injection_test_h = new (v_inf);
            test_h = random_error_injection_test_h;
            $display("starting RANDOM_ERROR_INJECTION_TEST");
    	end
    	else if ($test$plusargs("RANDOM_RESET_THRICE_TEST")) begin
	    	random_reset_thrice_test_h = new(v_inf);
            test_h = random_reset_thrice_test_h;
            $display("starting RANDOM_RESET_THRICE_TEST");
    	end
    	else begin
            random_test_h = new (v_inf);
            test_h = random_test_h;
            $display("starting RANDOM_TEST");
    	end
		fork
			test_h.run_test();
		join_none
		@a_if.finish_test;
		$finish;
	end
	// initial begin	
	// 	`ifdef RANDOM_TEST
	// 		$vcdplusfile("output/RANDOM_TEST.vpd");   // Specify VPD file name
	// 	`elsif RANDOM_ERROR_INJECTION_TEST
	// 		$vcdplusfile("output/RANDOM_ERROR_INJECTION_TEST.vpd");   // Specify VPD file name
	// 	`elsif RANDOM_RESET_THRICE_TEST
	// 		$vcdplusfile("output/RANDOM_RESET_THRICE_TEST.vpd");   // Specify VPD file name
	// 	`else 
	// 		$vcdplusfile("output/RANDOM_TEST.vpd");   // Specify VPD file name
	// 	`endif
 //    	$vcdpluson;                        		 // Start dumping signals
	// end

	// initial begin
	// 	v_inf = a_if;
	// 	//test_h = new(v_inf);

	// 	// Create appropriate test type but assign to base class handle
 //        `ifdef RANDOM_TEST
 //            random_test_h = new (v_inf);
 //        	test_h = new random_test_h;
 //        `elsif RANDOM_ERROR_INJECTION_TEST
 //            random_error_injection_test_h = new (v_inf);
 //        	test_h = new random_error_injection_test_h;
 //        `elsif RANDOM_RESET_THRICE_TEST
 //            random_reset_thrice_test_h = new(v_inf);
 //            test_h = new random_reset_thrice_test_h;
 //        `else 
 //            random_test_h = new (v_inf);
 //        	test_h = new random_test_h;
 //        `endif

	// 	fork
	// 		test_h.run_test();
	// 	join_none
	// 	@a_if.finish_test;
	// 	$finish;
	// end

	final begin
		$display("TIME: %0t Correct Checks: %0d, Incorrect Checks: %0d", $time(), a_if.correct_items, a_if.incorrect_items);
	end

endmodule : alu_top_tb

