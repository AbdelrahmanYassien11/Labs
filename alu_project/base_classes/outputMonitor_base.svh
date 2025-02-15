virtual class outputMonitor_base#(type T = int);
	
	protected virtual alu_f v_inf;
	protected mailbox #(T) outputMonitor_to_scoreboard, outputMonitor_to_coverage;

	function new(virtual alu_f v_inf, mailbox #(T) outputMonitor_to_scoreboard, mailbox #(T) outputMonitor_to_coverage);
		this.v_inf = v_inf;
		this.outputMonitor_to_scoreboard = outputMonitor_to_scoreboard;
		this.outputMonitor_to_coverage = outputMonitor_to_coverage;
	endfunction

	pure virtual task execute;

endclass : outputMonitor_base