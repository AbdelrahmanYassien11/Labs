class scoreboard;
	//static int correct_checks, incorrect_checks;

	comparator comparator_h;
	predictor predictor_h;

	mailbox #(transaction) predictor_to_comparator;

	virtual simpleadder_if v_inf;

	function new(virtual simpleadder_if v_inf, mailbox #(transaction) inputMonitor_to_scoreboard, outputMonitor_to_scoreboard);
		this.v_inf = v_inf;
		predictor_h = new(v_inf, inputMonitor_to_scoreboard);
		comparator_h = new(v_inf, outputMonitor_to_scoreboard);

		predictor_to_comparator = new(1);

		predictor_h.predictor_to_comparator  = predictor_to_comparator;
		comparator_h.predictor_to_comparator = predictor_to_comparator;
	endfunction

	task start_scoreboard();
		fork
			predictor_h.predict();
			comparator_h.start_checking();	
		join_none
	endtask : start_scoreboard

endclass : scoreboard