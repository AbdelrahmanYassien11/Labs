class test extends test_base;

	env#(transaction) env_h;

	function new(virtual alu_f v_inf);
		super.new(v_inf);
		env_h = new(v_inf);
	endfunction

	task run_test();
		fork
			env_h.execute();
		join_none
	endtask : run_test

endclass
