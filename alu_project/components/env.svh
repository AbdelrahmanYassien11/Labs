class env#(type T = int) extends env_base#(T);

	scoreboard#(T) scoreboard_h;
	//agent agent_h;
	driver#(T) driver_h;
	inputMonitor#(T)  inputMonitor_h;
	outputMonitor#(T) outputMonitor_h;
	coverage#(T) coverage_h;
	generator#(T) generator_h;
	event finished_driving;

	function new(virtual alu_f v_inf);

		super.new(v_inf);
		generator_h 	= new(v_inf, generator_to_driver, finished_driving);
		scoreboard_h 	= new(v_inf, inputMonitor_to_scoreboard, outputMonitor_to_scoreboard);
		driver_h 	 	= new(v_inf, generator_to_driver, finished_driving);
		inputMonitor_h  = new(v_inf, inputMonitor_to_scoreboard, inputMonitor_to_coverage);
		outputMonitor_h = new(v_inf, outputMonitor_to_scoreboard, outputMonitor_to_coverage);
		coverage_h      = new(v_inf, inputMonitor_to_coverage, outputMonitor_to_coverage);

	endfunction

	virtual task execute();
		fork
			generator_h.execute();
			scoreboard_h.execute();
			driver_h.execute();
			inputMonitor_h.execute();
			outputMonitor_h.execute();
			coverage_h.execute();
		join_none
		@(v_inf.finish_test);
	endtask : execute

endclass


//No my love you are stupid, just like the rest of them
// but I love you all the same
// My love I hope it won't hurt when it comes,....if it comes
//time is a deceitful thing, and the truth of things escapes our grasp
//humane we are and humane we always will be
//humane we are and humane we will be