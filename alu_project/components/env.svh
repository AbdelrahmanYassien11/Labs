class env#(type T = int) extends env_base#(T);

	scoreboard#(T) scoreboard_h;
	
	driver#(T) driver_h;
	inputMonitor#(T)  inputMonitor_h;
	outputMonitor#(T) outputMonitor_h;
	coverage#(T) coverage_h;

	random_generator#(T) generator_h;
	error_injection_generator#(T) generator_x;
	random_reset_thrice_generator#(T) generator_t;

	event finished_driving;

	TEST_TYPE generator_determiner;

	function new(virtual alu_f v_inf, TEST_TYPE generator_determiner);

		super.new(v_inf);

		this.generator_determiner = generator_determiner;

		scoreboard_h 	= new(v_inf, inputMonitor_to_scoreboard, outputMonitor_to_scoreboard);
		driver_h 	 	= new(v_inf, generator_to_driver, finished_driving);
		inputMonitor_h  = new(v_inf, inputMonitor_to_scoreboard, inputMonitor_to_coverage);
		outputMonitor_h = new(v_inf, outputMonitor_to_scoreboard, outputMonitor_to_coverage);
		coverage_h      = new(v_inf, inputMonitor_to_coverage, outputMonitor_to_coverage);

		case (generator_determiner)
			RANDOM: 				generator_h = new(v_inf, generator_to_driver, finished_driving);
			RANDOM_ERROR_INJECTION: generator_x = new(v_inf, generator_to_driver, finished_driving);
			RANDOM_RESET_THRICE:	generator_t = new(v_inf, generator_to_driver, finished_driving);
		endcase

	endfunction

	virtual task execute();
		fork
			scoreboard_h.execute();
			driver_h.execute();
			inputMonitor_h.execute();
			outputMonitor_h.execute();
			coverage_h.execute();
			begin
				case (generator_determiner)
					0: generator_h.execute();
					1: generator_x.execute();
					2: generator_t.execute();
				endcase
			end
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