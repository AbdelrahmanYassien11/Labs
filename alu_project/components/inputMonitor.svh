class inputMonitor#(type T = int) extends inputMonitor_base#(T);

	T input_item;

	function new(virtual alu_f v_inf, mailbox #(T) inputMonitor_to_scoreboard, mailbox #(T) inputMonitor_to_coverage);
		super.new(v_inf, inputMonitor_to_scoreboard, inputMonitor_to_coverage);
		input_item = new();
	endfunction 

	virtual task execute ();
		forever begin
			@(posedge v_inf.clk);
			if(v_inf.monitor_flag == 1) begin
				sample_inputs();
				$display("[INPUT_MONITOR]: %0s",input_item.input2string());
			end
		end
	endtask : execute

	virtual task sample_inputs();
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
	endtask : sample_inputs

endclass : inputMonitor
