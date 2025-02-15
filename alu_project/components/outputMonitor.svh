class outputMonitor#(type T = int) extends outputMonitor_base#(T);

	T output_item;

	function new(virtual alu_f v_inf, mailbox #(T) outputMonitor_to_scoreboard, mailbox #(T) outputMonitor_to_coverage);
		super.new(v_inf, outputMonitor_to_scoreboard, outputMonitor_to_coverage);
		output_item = new();
	endfunction

	task execute ();
		@(posedge v_inf.clk);
		forever begin
			@(negedge v_inf.clk);
			if(v_inf.monitor_flag == 1) begin
				sample_outputs();
				$display("[OUTPUT_MONITOR]: %0s", output_item.output2string());
			end
		end
	endtask: execute

	task sample_outputs();
		output_item.C = v_inf.C;
		output_item.rst_n = v_inf.rst_n;
		outputMonitor_to_scoreboard.put(output_item);
		outputMonitor_to_coverage.put(output_item);
	endtask: sample_outputs

endclass : outputMonitor
