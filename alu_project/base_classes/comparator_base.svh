virtual class comparator_base#(type T = int);

	protected virtual alu_f v_inf;
	protected mailbox #(T)outputMonitor_to_comparator, predictor_to_comparator;

	function new(virtual alu_f v_inf, mailbox #(T) outputMonitor_to_comparator, mailbox #(T) predictor_to_comparator);
	 	this.v_inf = v_inf;
	 	this.outputMonitor_to_comparator = outputMonitor_to_comparator;
	 	this.predictor_to_comparator     = predictor_to_comparator;
	 endfunction

	pure virtual task execute;

endclass : comparator_base
