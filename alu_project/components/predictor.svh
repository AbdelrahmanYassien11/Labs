class predictor;

	virtual alu_f v_inf;
	mailbox #(transaction )inputMonitor_to_predictor, predictor_to_comparator;

	function void new(virtual alu_f v_inf, mailbox #(transaction) inputMonitor_to_predictor, mailbox #(transaction) predictor_to_comparator);
	 	this.v_inf = v_inf;
	 	this.inputMonitor_to_predictor = inputMonitor_to_predictor;
	 	this.predictor_to_comparator   = predictor_to_comparator;
	endfunction 

	function void execute();
		
	endfunction : execute
endclass