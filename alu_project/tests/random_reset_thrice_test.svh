class random_reset_thrice_test extends test_base;

	env#(transaction) env_h;

	TEST_TYPE test_t;

	function new(virtual alu_f v_inf);
		super.new(v_inf);
		test_t = RANDOM_RESET_THRICE;
		env_h = new(v_inf, test_t);
	endfunction

	task run_test();
		fork
			env_h.execute();
		join_none
	endtask : run_test

endclass
