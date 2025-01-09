interface simpleAdder_if(bit clk);

	bit clk;
	bit en_i;
	bit in_a;
	bit in_b;
	logic en_o;
	logic out;

endinterface : simpleAdder_if


class inputMonitor;
	transaction input_tr;
	task startMonitoring();
		forever begin
			driver_to_monitor.get(input_tr);
			$display("TIME: %0t INPUT_ITEM: %p", $time(), input_tr);
			inputMonitor_to_predictor.put(input_tr);
		end
	endtask : startMonitoring
endclass : inputMonitor


	task predictor(input transaction input_transaction);
		if((input_transaction.en_i & addition_initiated) | (~input_transaction.en_i & addition_initiated)) begin
			$display("TIME: %0t CALLING ADDITION", $time());
			addition(input_transaction);
		end
	endtask : predictor

class predictor;
	transaction predicted_tr;

	task predict();
		
	endtask : predict



endclass : predictor


class sequence;
	transaction randomized_tr;

	task generateStimulus();
		for (int i = 0; i < randomized_tests; i++) begin
			this.i = randomized_tr.i;
			assert(randomized_tr.randomize() with {(i%2 == 0 -> en_i);
												   (i%2 != 0 -> ~en_i);
												  });
			sequence_to_driver.put(randomized_tr);
			$display("TIME: %0t GENERATED_ITEM: %p", $time(), randomized_tr);
			if(randomized_tr.en_i) addition_initiated_checker(randomized_tr);
		end
	endtask : generateStimulus

	function void addition_initiated_checker(transaction driven_tr);
		if(driven_tr.en_i) begin
			$display("TIME: %0t addition_initiated", $time());
			addition_initiated = 1;
		end
	endfunction


endclass : sequence


class transaction;
	
	rand bit in_a, in_b;
	bit en_i;
	logic out, en_o;
	bit addition_initiated;

	static addition_initiated_i;

endclass : transaction

class driver;
	transaction driven_tr;

	task drive();
		forever begin
			@(negedge clk);
			sequence_to_driver.get(driven_tr);
			en_i <= driven_tr.en_i;
			in_a <= driven_tr.in_a;
			in_b <= driven_tr.in_b;

			addition_initiated_checker(driven_tr);

			if((addition_initiated == 1) && (driven_tr.en_i == 0)) begin
				repeat(4) begin
					$display("TIME: %0t DELAYING DRIVER",$time());
					@(negedge clk);
				end
				addition_initiated = 0;
			end			
		end
	endtask : drive


endclass : driver

