class scoreboard;
	//static int correct_checks, incorrect_checks;

	comparator comparator_h;
	predictor predictor_h;

	mailbox #(transaction) inputMonitor_to_scoreboard;
	mailbox #(transaction) outputMonitor_to_scoreboard;

	mailbox #(transaction) predictor_to_comparator;

	virtual simpleadder_if v_inf;

	function new(virtual simpleadder_if v_inf);
		this.v_inf = v_inf;
		predictor_h = new(v_inf);
		comparator_h = new(v_inf);
		predictor_to_comparator = new(1);

		predictor_h.scoreboard_to_predictor   = inputMonitor_to_scoreboard;
		comparator_h.scoreboard_to_comparator = outputMonitor_to_scoreboard;

		predictor_h.predictor_to_comparator = predictor_to_comparator;
		comparator_h.predictor_to_comparator = predictor_to_comparator;
	endfunction

	task start_scoreboard();
		predictor_h.predict();
		comparator_h.start_checking();
	endtask : start_scoreboard

endclass : scoreboard