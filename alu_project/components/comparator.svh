class comparator;

	virtual alu_f v_inf;
	mailbox #(transaction )outputMonitor_to_comparator, predictor_to_comparator;

	function void new(virtual alu_f v_inf, mailbox #(transaction) outputMonitor_to_comparator, mailbox #(transaction) predictor_to_comparator);
	 	this.v_inf = v_inf;
	 	this.outputMonitor_to_comparator = outputMonitor_to_comparator;
	 	this.predictor_to_comparator     = predictor_to_comparator;
	 endfunction 

	function execute ();
	 	
	endfunction


endclass