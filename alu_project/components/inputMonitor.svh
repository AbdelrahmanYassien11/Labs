class inputMonitor;
	virtual alu_f v_inf;
	mailbox #(transaction) inputMonitor_to_scoreboard, inputMonitor_to_coverage;
	transaction input_item;

	function void new(virtual alu_f v_inf, mailbox #(transaction) inputMonitor_to_scoreboard, mailbox #(transaction) inputMonitor_to_coverage);
		this.v_inf = v_inf;
		this.inputMonitor_to_scoreboard = inputMonitor_to_scoreboard;
		this.inputMonitor_to_coverage = inputMonitor_to_coverage;
	endfunction 

	function void execute ();
		forever begin
			@(posedge v_inf.clk);
			if(v_inf.monitor_flag == 1) begin
				sample_inputs();
			end
		end
	endfunction : execute

	function void sample_inputs();
		input_item.rst_n  = v_inf.rst_n;
		input_item.ALU_en = v_inf.ALU_en;
		input_item.a_en   = v_inf.a_en;
		input_item.b_en   = v_inf.b_en;
		input_item.A = v_inf.A;
		input_item.B = v_inf.B;
		input_item.a_op = v_inf.a_op;
		input_item.b_op = v_inf.b_op;
		inputMonitor_to_scoreboard.put(input_item);
		inputMonitor_to_coverage.put(input_item);
	endfunction : sample_inputs


endclass : inputMonitor