class randomized_sequence;
	transaction randomized_tr;
	transaction randomized_tests;

	virtual simpleadder_if v_inf;
	
	mailbox #(transaction) sequence_to_driver;

	function new(virtual simpleadder_if v_inf, mailbox #(transaction) sequence_to_driver);
		this.v_inf = v_inf;
		randomized_tr = new();
		randomized_tests = new();
		this.sequence_to_driver = sequence_to_driver;
	endfunction : new

	task generateStimulus();
		randomized_tests.randomize();
		randomized_tests.items_to_be_generated.rand_mode(0);
		transaction::items_to_be_generated_compared = randomized_tests.items_to_be_generated;
		$display("items_to_be_generated_compared: %0d",transaction::items_to_be_generated_compared);
		for (int i = 0; i < randomized_tests.items_to_be_generated; i++) begin
			randomized_tr = new();
			//wait(v_inf.wait_till_item_driven.triggered());
			// assert(randomized_tr.randomize() with {((i%2 == 0) -> en_i);
			// 									   ((i%2 != 0) -> ~en_i);
			// 									  });

			assert(randomized_tr.randomize() with { if( i%2 == 0) {
														en_i == 1;	
													}
												  else {
												  		en_i == 0;
												  	}
												  });

			sequence_to_driver.put(randomized_tr);
			$display("i = %0d, GENERATED_ITEM: %s", i, randomized_tr.input2string);
			//$display("SEQUENCE: AFTER PUT");
			//-> v_inf.item_put_in_driver;
			if(randomized_tr.en_i) addition_initiated_checker(randomized_tr);
		end
	endtask : generateStimulus

	function void addition_initiated_checker(transaction driven_tr);
		if(driven_tr.en_i) begin
			//$display("TIME: %0t addition_initiated", $time());
			v_inf.addition_initiated = 1;
		end
	endfunction


endclass : randomized_sequence
