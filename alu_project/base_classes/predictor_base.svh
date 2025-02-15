virtual class predictor_base#(type T = int);

	protected virtual alu_f v_inf;
	protected mailbox #(T) inputMonitor_to_predictor, predictor_to_comparator;

	function new(virtual alu_f v_inf, mailbox #(T) inputMonitor_to_predictor, mailbox #(T) predictor_to_comparator);
	 	this.v_inf = v_inf;
	 	this.inputMonitor_to_predictor = inputMonitor_to_predictor;
	 	this.predictor_to_comparator   = predictor_to_comparator;
	endfunction 

	pure virtual task execute;
	
endclass : predictor_base
