virtual class env_base#(type T = int);

	protected virtual alu_f v_inf;
	protected mailbox #(T) generator_to_driver, inputMonitor_to_scoreboard, outputMonitor_to_scoreboard, inputMonitor_to_coverage, outputMonitor_to_coverage;

	function new(virtual alu_f v_inf);

		this.v_inf = v_inf;

		generator_to_driver         = new(1);
		inputMonitor_to_scoreboard  = new(1);
		outputMonitor_to_scoreboard = new(1);
		inputMonitor_to_coverage 	= new(1);
		outputMonitor_to_coverage   = new(1);

	endfunction

	pure virtual task execute;

endclass : env_base