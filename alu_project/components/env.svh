class env;

	scoreboard scorebaord_h;
	agent agent_h;
	driver driver_h;
	// monitor monitor_h;
	inputMonitor  inputMonitor_h;
	outputMonitor outputMonitor_h;
	coverage coverage_h;

	virtual alu_f v_inf;

	mailbox #(transaction) generator_to_driver, inputMonitor_to_scoreboard, outputMonitor_to_scoreboard, inputMonitor_to_coverage, outputMonitor_to_coverage;

	function void new(virtual alu_f v_inf);

		this.v_inf = v_inf;

		generator_to_driver         = new(1);
		inputMonitor_to_scoreboard  = new(1);
		outputMonitor_to_scoreboard = new(1);

		generator_h 	= new(v_inf, generator_to_driver);
		scoreboard_h 	= new(v_inf, inputMonitor_to_scoreboard, outputMonitor_to_scoreboard);
		driver_h 	 	= new(v_inf, generator_to_driver);
		// monitor_h 		= new(v_inf, inputMonitor_to_scoreboard, outputMonitor_to_scoreboard);
		inputMonitor_h  = new(v_inf, inputMonitor_to_scoreboard);
		outputMonitor_h = new(v_inf, outputMonitor_to_scoreboard);
		coverage_h      = new(v_inf, inputMonitor_to_coverage, outputMonitor_to_coverage);

	endfunction

	function void execute();
		fork
			generator_h.execute();
			scoreboard_h.execute();
			driver_h.execute();
			//monitor_h.execute();
			inputMonitor_h.execute();
			outputMonitor_h.execute();
			coverage_h.execute();
		join_none
	endfunction : execute

endclass


//No my love you are stupid, just like the rest of them
// but I love you all the same
// My love I hope it won't hurt when it comes,....if it comes
//time is a deceitful thing, and the truth of things escapes our grasp
//humane we are and humane we always will be
//humane we are and humane we will be