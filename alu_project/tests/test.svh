class test;

	env env_h;

	virtual alu_f v_inf;

	function new(virtual alu_f v_inf);
		this.v_inf = v_inf;
		env_h = new(this.v_inf);
	endfunction

	task run_test();
		env_h.execute();
	endtask : run_test

endclass
