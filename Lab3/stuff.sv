










class inputMonitor;
	transaction input_tr;

	virtual interface v_inf;
	
	function void new(virtual interface v_inf);
		this.v_inf = v_inf;
	endfunction : new

	task startMonitoring();
		forever begin

			@(posedge v_inf.en_i);
			input_tr.en_i = v_inf.en_i;
			input_tr.in_a = v_inf.in_a;
			input_tr.in_b = v_inf.in_b;
			$display("TIME: %0t INPUT_ITEM: %p", $time(), input_tr);
			inputMonitor_to_predictor.put(input_tr);	
					
			@(posedge v_inf.clk);
			input_tr.en_i = v_inf.en_i;
			input_tr.in_a = v_inf.in_a;
			input_tr.in_b = v_inf.in_b;
			//driver_to_monitor.get(input_tr);
			$display("TIME: %0t INPUT_ITEM: %p", $time(), input_tr);
			inputMonitor_to_predictor.put(input_tr);
		end
	endtask : startMonitoring
endclass : inputMonitor


class outputMonitor;


	transaction actual_output_tr;

	virtual interface v_inf;
	
	function void new(virtual interface v_inf);
		this.v_inf = v_inf;
	endfunction : new

	task startMonitoring();
		forever begin
			@(posedge v_inf.en_i);
			$display("TIME: %0t ENTERED OUTPUTMONITOR", $time());
			repeat(3) begin
				@(negedge clk);
			end
			actual_output_tr.en_o = v_inf.en_o;
			actual_output_tr.out  = v_inf.out;

			$display("TIME: %0t FIRST ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			outputMonitor_to_comparator.put(actual_output_tr);

			@(negedge clk);

			actual_output_tr.en_o = v_inf.en_o;
			actual_output_tr.out  = v_inf.out;

			$display("TIME: %0t SECOND ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			outputMonitor_to_comparator.put(actual_output_tr);
			@(negedge clk);

			actual_output_tr.en_o = v_inf.en_o;
			actual_output_tr.out  = v_inf.out;

			$display("TIME: %0t THIRD ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			outputMonitor_to_comparator.put(actual_output_tr);
		end
	endtask : startMonitoring

endclass : outputMonitor



class predictor;
	transaction predictor_tr;

	mailbox predictor_to_comparator;

	virtual interface v_inf;
	
	function void new(virtual interface v_inf);
		this.v_inf = v_inf;
	endfunction : new

	task predict();
		if((predicted_tr.en_i & addition_initiated) | (~predicted_tr.en_i & addition_initiated)) begin
			$display("TIME: %0t CALLING ADDITION", $time());
			addition(predictor_tr);
		end		
	endtask : predict

	task addition(input transaction input_transaction);
		static logic [1:0] ina_tb, inb_tb;
		static logic [2:0] out_tb;
		if(addition_initiated & ~input_transaction.en_i) begin
			ina_tb = ina_tb << 1;
			inb_tb = inb_tb << 1;
			$display("TIME: %0t ADDITION: SECOND_CYCLE",$time());
		end
			$display("TIME: %0t ADDITION: FIRST_SECOND_CYCLE",$time());
		ina_tb[0] = input_transaction.in_a;
		inb_tb[0] = input_transaction.in_b;

		if(addition_initiated & ~input_transaction.en_i) begin
			out_tb  = ina_tb + inb_tb;
			$display("TIME: %0t, CALLING SERIALIZER out_tb:%0d",$time(), out_tb);
			serializer(out_tb);
		end
	endtask : addition

	task serializer(input logic [2:0] out_tb);
		transaction expected_output_tr;
		for (int i = 2; i >= 0; i--) begin
			expected_output_tr.out = out_tb[i];
			if(i == 2) begin
				expected_output_tr.en_o = 1;
			end
			else begin
				expected_output_tr.en_o = 0;
			end
			predictor_to_comparator.put(expected_output_tr);
			$display("TIME: %0t SERIALIZER: SENT OUTPUT TO CHECKER",$time());
		end
	endtask : serializer


endclass : predictor


class randomized_sequence;
	transaction randomized_tr;

	virtual interface v_inf;
	
	function void new(virtual interface v_inf);
		this.v_inf = v_inf;
	endfunction : new

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
			v_inf.addition_initiated = 1;
		end
	endfunction


endclass : randomized_sequence


class transaction;
	
	rand bit in_a, in_b;
	bit en_i;
	logic out, en_o;
	bit addition_initiated;

	static rand int items_to_be_generated;

	static bit addition_initiated_i;

	constraint no_of_generated_items{ (items_to_be_generated inside {[100:150]}) && (items_to_be_generated%2 == 0) };

endclass : transaction

class driver;
	transaction driven_tr;

	virtual interface v_inf;
	
	function void new(virtual interface v_inf);
		this.v_inf = v_inf;
	endfunction : new

	task drive();
		forever begin
			@(negedge v_inf.clk);
			sequence_to_driver.get(driven_tr);
			v_inf.en_i <= driven_tr.en_i;
			v_inf.in_a <= driven_tr.in_a;
			v_inf.in_b <= driven_tr.in_b;

			addition_initiated_checker(driven_tr);

			if((v_inf.addition_initiated == 1) && (driven_tr.en_i == 0)) begin
				repeat(4) begin
					$display("TIME: %0t DELAYING DRIVER",$time());
					@(negedge v_inf.clk);
				end
				addition_initiated = 0;
			end			
		end
	endtask : drive


endclass : driver

