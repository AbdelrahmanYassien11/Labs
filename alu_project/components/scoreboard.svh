class scoreboard#(type T = int) extends scoreboard_base#(T);

	predictor#(T) predictor_h;
	comparator#(T) comparator_h;


	function new(virtual alu_f v_inf, mailbox #(T) inputMonitor_to_scoreboard, mailbox #(T) outputMonitor_to_scoreboard);
		super.new(v_inf);
		predictor_h  = new(this.v_inf, inputMonitor_to_scoreboard, predictor_to_comparator);
		comparator_h = new(this.v_inf, outputMonitor_to_scoreboard, predictor_to_comparator);
	endfunction

	virtual task execute();
		fork
			predictor_h.execute();
			comparator_h.execute();			
		join_none	
	endtask : execute

endclass :scoreboard


