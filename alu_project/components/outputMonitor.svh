// class monitor;

// 	virtual alu_f v_inf;

// 	mailbox #(transaction) inputMonitor_to_scoreboard, outputMonitor_to_scoreboard;

// 	function void new(virtual alu_f v_inf, mailbox #(transaction) inputMonitor_to_scoreboard, mailbox #(transaction) outputMonitor_to_scoreboard);
// 		this.v_inf = v_inf;
// 		this.inputMonitor_to_scoreboard = inputMonitor_to_scoreboard;
// 		this.outputMonitor_to_scoreboard = outputMonitor_to_scoreboard;
// 	endfunction 

// endclass : monitor

// class inputMonitor extends monitor;



// 	function void new();
		
// 	endfunction 

// endclass : inputMonitor


class outputMonitor;
	virtual alu_f v_inf;
	mailbox #(transaction) outputMonitor_to_scoreboard, outputMonitor_to_coverage;
	transaction output_item;

	function new(virtual alu_f v_inf, mailbox #(transaction) outputMonitor_to_scoreboard, mailbox #(transaction) outputMonitor_to_coverage);
		this.v_inf = v_inf;
		this.outputMonitor_to_scoreboard = outputMonitor_to_scoreboard;
		this.outputMonitor_to_coverage = outputMonitor_to_coverage;
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
		outputMonitor_to_scoreboard.put(output_item);
		outputMonitor_to_coverage.put(output_item);
	endtask: sample_outputs

endclass : outputMonitor