class test;

	env env_h;

	virtual alu_f v_inf;

	function void new(virtual alu_f v_inf);
		this.v_inf = v_inf;
		env_h = new(v_inf);
	endfunction

	function void run_test();
		env_h.execute();
	endfunction : run_test

endclass
