class randomized_sequence;
	transaction randomized_tr;

	virtual simpleadder_if v_inf;
	
	mailbox #(transaction) sequence_to_driver;
	function new(virtual simpleadder_if v_inf);
		this.v_inf = v_inf;
		randomized_tr = new();
	endfunction : new

	task generateStimulus();
		randomized_tr.randomize();
		randomized_tr.items_to_be_generated.rand_mode(0);
		transaction::items_to_be_generated_compared = randomized_tr.items_to_be_generated;
		for (int i = 0; i < randomized_tr.items_to_be_generated; i++) begin
			assert(randomized_tr.randomize() with {((i%2 == 0) -> en_i);
												   ((i%2 != 0) -> ~en_i);
												  });
			sequence_to_driver.put(randomized_tr);
			$display("TIME: %0t GENERATED_ITEM: %p", $time(), randomized_tr);
			if(randomized_tr.en_i) addition_initiated_checker(randomized_tr);
			#1;
		end
	endtask : generateStimulus

	function void addition_initiated_checker(transaction driven_tr);
		if(driven_tr.en_i) begin
			$display("TIME: %0t addition_initiated", $time());
			v_inf.addition_initiated = 1;
		end
	endfunction


endclass : randomized_sequence
