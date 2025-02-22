virtual class scoreboard_base#(type T = int);

	protected mailbox #(T) predictor_to_comparator;
	protected virtual alu_f v_inf;

	function new(virtual alu_f v_inf);
		this.v_inf = v_inf;			
		predictor_to_comparator = new(1);
	endfunction

	pure virtual task execute;
	
endclass : scoreboard_base