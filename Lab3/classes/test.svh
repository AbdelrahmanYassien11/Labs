class test;


	inputMonitor inputMonitor_h;
	outputMonitor outputMonitor_h;
	driver driver_h;
	scoreboard scoreboard_h;
	randomized_sequence randomized_sequence_h;

	mailbox #(transaction) sequence_to_driver;
	mailbox #(transaction) inputMonitor_to_scoreboard;
	mailbox #(transaction) outputMonitor_to_scoreboard;

	virtual simpleadder_if v_inf;

	function new(virtual simpleadder_if v_inf);
		this.v_inf = v_inf;
	endfunction : new

	task execute();
		sequence_to_driver 		  	 = new(1);
		inputMonitor_to_scoreboard 	 = new(1);
		outputMonitor_to_scoreboard  = new(1);

		driver_h = new(v_inf);
		scoreboard_h = new(v_inf);
		inputMonitor_h = new(v_inf);
		outputMonitor_h = new(v_inf);
		randomized_sequence_h = new(v_inf);		

		randomized_sequence_h.sequence_to_driver 	= sequence_to_driver;
		driver_h.sequence_to_driver 			 	= sequence_to_driver;

		inputMonitor_h.inputMonitor_to_scoreboard 	= inputMonitor_to_scoreboard;
		scoreboard_h.inputMonitor_to_scoreboard    	= inputMonitor_to_scoreboard;

		outputMonitor_h.outputMonitor_to_scoreboard = outputMonitor_to_scoreboard;
		scoreboard_h.outputMonitor_to_scoreboard    = outputMonitor_to_scoreboard;

		fork
			driver_h.drive();
			scoreboard_h.start_scoreboard();
			inputMonitor_h.startMonitoring();
			outputMonitor_h.startMonitoring();
			randomized_sequence_h.generateStimulus();
		join_none
	endtask : execute

endclass : test