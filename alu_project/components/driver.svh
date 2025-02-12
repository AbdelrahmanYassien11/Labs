class driver;

	virtual alu_f v_inf;
	mailbox #(transaction) generator_to_driver;
	transaction driven_item;
	
	event finished_driving;

	function new(virtual alu_f v_inf, mailbox#(transaction) generator_to_driver, event finished_driving);
		this.v_inf = v_inf;
		this.generator_to_driver = generator_to_driver;
		this.finished_driving = finished_driving;
		//driven_item = new();

	endfunction 

	task execute();
		forever begin
			@(negedge v_inf.clk);
			driven_item = new();
			generator_to_driver.get(driven_item);
			drive_item(driven_item);
			$display("[DRIVER] DRIVEN_ITEM: %0s",driven_item.input2string());
			-> finished_driving;
		end
		end_monitoring();
	endtask : execute


	function void drive_item (transaction driven_item);
		v_inf.A <= driven_item.A;
		v_inf.B <= driven_item.B;
		v_inf.a_op <= driven_item.a_op;
		v_inf.b_op <= driven_item.b_op;
		v_inf.a_en <= driven_item.a_en;
		v_inf.b_en <= driven_item.b_en;
		v_inf.ALU_en <= driven_item.ALU_en;
		v_inf.rst_n  <= driven_item.rst_n;
		start_monitoring();
	endfunction : drive_item

	function void start_monitoring();
		v_inf.monitor_flag = 1;
	endfunction : start_monitoring

	task end_monitoring();
		@(posedge v_inf.clk);
		@(posedge v_inf.clk);
		$display("[DRIVER] STOPPING MONITORING",);
		v_inf.monitor_flag = 0;
	endtask : end_monitoring

endclass