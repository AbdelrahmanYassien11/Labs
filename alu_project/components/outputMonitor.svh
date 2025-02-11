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
	mailbox #(transaction) outputMonitor_to_scoreboard;
	transaction output_item;

	function void new(virtual alu_f v_inf, mailbox #(transaction) outputMonitor_to_scoreboard, mailbox #(transaction) outputMonitor_to_coverage);
		this.v_inf = v_inf;
		this.outputMonitor_to_scoreboard = outputMonitor_to_scoreboard;
		this.outputMonitor_to_coverage = outputMonitor_to_scoverage;
	endfunction

	function void execute ();
		@(negedge clk);
		forever begin
			@(negedge v_inf.clk);
			if(v_inf.monitor_flag == 1) begin
				sample_outputs();
			end
		end
	endfunction : execute

	function void sample_outputs();
		output_item.C = v_inf.C;
		outputMonitor_to_scoreboard.put(output_item);
		outputMonitor_to_coverage.put(output_item);
	endfunction : sample_outputs

endclass : outputMonitor