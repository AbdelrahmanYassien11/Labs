class test_base;

	virtual alu_f v_inf;

	function new(virtual alu_f v_inf);
		this.v_inf = v_inf;
	endfunction

	virtual task run_test;
	endtask : run_test

endclass : test_base