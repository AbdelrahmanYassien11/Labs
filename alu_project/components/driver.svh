class driver;

	virtual alu_f v_inf;
	mailbox#(transaction) generator_to_driver;
	transaction driven_item;

	function void new(virtual alu_f v_inf, mailbox#(transaction) generator_to_driver);
		this.v_inf = v_inf;
		this.generator_to_driver = generator_to_driver;
		//driven_item = new();
	endfunction 

	function void execute();
		forever begin
			@(negedge v_inf.clk);
			driven_item = new();
			generator_to_driver.get(driven_item);
			drive_item(driven_item);
			$display("DRIVEN_ITEM: %0s",driven_item.input2string());
		end
		end_monitoring();
	endfunction : execute


	function void drive_item (transaction driven_item);
		v_inf.A <= driven_item.A;
		v_inf.B <= driven_item.B;
		v_inf.op_a <= driven_item.op_a;
		v_inf.op_b <= driven_item.op_b;
		v_inf.a_en <= driven_item.a_en;
		v_inf.b_en <= driven_item.b_en;
		v_inf.ALU_en <= driven_item.ALU_en;
		v_inf.rst_n  <= driven_item.rst_n;
		start_monitoring();
	endfunction : drive_item

	function void start_monitoring();
		v_inf.monitor_flag = 1;
	endfunction : start_monitoring

	function void end_monitoring();
		v_inf.monitor_flag = 0;
	endfunction : end_monitoring

endclass