class scoreboard;

	predictor predictor_h;
	comparator comparator_h;

	mailbox #(transaction) predictor_to_comparator;

	virtual alu_f v_inf;

	function void new(virtual alu_f v_inf, mailbox #(transaction) inputMonitor_to_scoreboard, mailbox #(transaction) outputMonitor_to_scoreboard);
		this.v_inf = v_inf;			
		predictor_to_comparator = new(1);
		predictor_h  = new(this.v_inf, inputMonitor_to_scoreboard, predictor_to_comparator);
		comparator_h = new(this.v_inf, outputMonitor_to_scoreboard, predictor_to_comparator);

	endfunction


endclass