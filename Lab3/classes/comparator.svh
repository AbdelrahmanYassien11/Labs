class comparator;
	transaction expected_output; 
	transaction actual_output;

	mailbox #(transaction) scoreboard_to_comparator;
	mailbox #(transaction) predictor_to_comparator;
	virtual simpleadder_if v_inf;
	
	function new(virtual simpleadder_if v_inf, mailbox #(transaction) scoreboard_to_comparator);
		this.v_inf = v_inf;
		this.scoreboard_to_comparator = scoreboard_to_comparator;
	endfunction : new

	task start_checking();
		forever begin
			expected_output = new();
			actual_output = new();
			//$display("predictor_to_comparator NO.: %0d ",predictor_to_comparator.num());
			//$display("scoreboard_to_comparator NO.: %0d ",scoreboard_to_comparator.num());
			predictor_to_comparator.get(expected_output);
			//$display("TIME: %0t EXPECTED_OUTPUT RECIEVED",$time());
			scoreboard_to_comparator.get(actual_output);
			//$display("TIME: %0t ACTUAL_OUTPUT RECIEVED",$time());
			if((expected_output.en_o == actual_output.en_o) & (expected_output.out == actual_output.out)) begin
				$display("TIME: %0t CORRECT OUTPUT", $time());
				v_inf.correct_checks = v_inf.correct_checks + 1;
			end
			else begin
				$display("INCORRECT OUTPUT");
				v_inf.incorrect_checks = v_inf.incorrect_checks + 1;
				$display("EXPECTED: , but ACTUAL: en_o = %0d, out = %0d", $time(), expected_output.output2string(), actual_output.output2string());
			end
			if(v_inf.correct_checks + v_inf.incorrect_checks == transaction::items_to_be_generated_compared)  -> v_inf.finish_the_test;
		end				
	endtask : start_checking

endclass : comparator
