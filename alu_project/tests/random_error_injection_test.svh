class random_error_injection_test extends test_base;

	env#(transaction) env_h;
	TEST_TYPE test_t;

	function new(virtual alu_f v_inf);
		super.new(v_inf);
		test_t = RANDOM_ERROR_INJECTION;
		env_h = new(v_inf, test_t);
	endfunction

	task run_test();
		fork
			env_h.execute();
		join_none
	endtask : run_test

endclass
