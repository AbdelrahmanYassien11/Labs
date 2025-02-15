class comparator#(type T = int) extends comparator_base#(T);

	T expected_item, actual_item;

	function new(virtual alu_f v_inf, mailbox #(T) outputMonitor_to_comparator, mailbox #(T) predictor_to_comparator);
		super.new(v_inf, outputMonitor_to_comparator, predictor_to_comparator);
	 	actual_item = new();
	 endfunction 

	task execute();
		forever begin
			expected_item = new();
			predictor_to_comparator.get(expected_item);
			$display("[COMPARATOR]: RECIEVED_EXPECTED_ITEM: %0s ", expected_item.output2string());
			outputMonitor_to_comparator.get(actual_item);
			$display("[COMPARATOR]: RECIEVED_ACTUAL_ITEM: %0s",actual_item.output2string());
			if(expected_item.C == actual_item.C) begin
				$display("[COMPARATOR]: %0t PASS: EXPECTED_ITEM_OUTPUT: %0d, ACTUAL_ITEM_OUTPUT: %0d",$time(), expected_item.C, actual_item.C);
				v_inf.correct_items = v_inf.correct_items + 1;
			end
			else begin
				$display("[COMPARATOR]: %0t FAIL: EXPECTED_ITEM_OUTPUT: %0d, ACTUAL_ITEM_OUTPUT: %0d ", $time(), expected_item.C, actual_item.C);
				v_inf.incorrect_items = v_inf.incorrect_items + 1;
			end
			if(T::NO_OF_ITEMS_ST == v_inf.incorrect_items + v_inf.correct_items) -> v_inf.finish_test;
		end
	endtask : execute

endclass