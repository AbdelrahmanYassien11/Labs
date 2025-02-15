virtual class inputMonitor_base#(type T = int);
	protected virtual alu_f v_inf;
	protected mailbox #(T) inputMonitor_to_scoreboard, inputMonitor_to_coverage;

	function new(virtual alu_f v_inf, mailbox #(T) inputMonitor_to_scoreboard, mailbox #(T) inputMonitor_to_coverage);
		this.v_inf = v_inf;
		this.inputMonitor_to_scoreboard = inputMonitor_to_scoreboard;
		this.inputMonitor_to_coverage   = inputMonitor_to_coverage;
	endfunction 

	pure virtual task execute;

endclass : inputMonitor_base