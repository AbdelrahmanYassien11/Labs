`timescale 1ns/1ns 

module simpleadder_tb();

	bit clk;
	bit en_i;
	bit in_a;
	bit in_b;
	logic en_o;
	logic out;

	always #5 clk = ~clk;


	typedef struct {
		rand bit in_a;
		rand bit in_b;
		rand bit en_i;
		bit en_o;
		bit out;
	} transaction;

	transaction randomized_tr, driven_tr, input_tr, expected_output_tr, actual_output_tr;

	mailbox #(transaction) sequence_to_driver = new(1);
	mailbox #(transaction) driver_to_monitor  = new(1);
	mailbox #(transaction) output_monitor_to_checker  = new(1);
	mailbox #(transaction) input_monitor_to_checker  = new(1);

	logic [1:0] ina_tb, inb_tb;
	logic [2:0] out_tb;

	simpleadder simp1(
		.clk(clk),
		.en_i(en_i),
		.ina(in_a),
		.inb(in_b),
		.en_o(en_o),
		.out(out)
		);
	
	bit addition_initiated;


	initial begin
		fork
			generateStimulus();
			driver();
			outputMonitor();
			inputMonitor();
			tr_checker();
		join_none
		#1000;
		$finish;
	end


	task generateStimulus();
		for (int i = 0; i < 100; i++) begin
			randomized_tr.en_i = (i%2 == 0)? 1:0; //randomized_tr.en_i = $random();
			randomized_tr.in_a = $random();
			randomized_tr.in_b = $random();
			// randomized_tr.randomize() with { addition_initiated -> randomized_tr.en_i == 0;};
			sequence_to_driver.put(randomized_tr);
			$display("TIME: %0t GENERATED_ITEM: %p", $time(), randomized_tr);
			if(randomized_tr.en_i) addition_initiated_checker(randomized_tr);
		end
	endtask : generateStimulus

	task driver();
		forever begin
			@(negedge clk);

			sequence_to_driver.get(driven_tr);
			$display("TIME: %0t DRIVEN_ITEM: %p", $time(), driven_tr);
			en_i <= driven_tr.en_i;
			in_a <= driven_tr.in_a;
			in_b <= driven_tr.in_b;

			addition_initiated_checker(driven_tr);
	
			driver_to_monitor.put(driven_tr);

			if((addition_initiated == 1) && (driven_tr.en_i == 0)) begin
				repeat(4) begin
					$display("TIME: %0t DELAYING DRIVER",$time());
					@(negedge clk);
				end
				addition_initiated = 0;
			end

		end
	endtask : driver

	task inputMonitor();
		forever begin
			driver_to_monitor.get(input_tr);
			$display("TIME: %0t INPUT_ITEM: %p", $time(), input_tr);
			predictor(input_tr);
		end
	endtask : inputMonitor

	task predictor(input transaction input_transaction);
		if((input_transaction.en_i & addition_initiated) | (~input_transaction.en_i & addition_initiated)) begin
			$display("TIME: %0t CALLING ADDITION", $time());
			addition(input_transaction);
		end
		// else begin
		// 	do_nothing();
		// end
	endtask : predictor


	// function void addition_initiated_checker_d(transaction driven_tr);
	// 	if(driven_tr.en_i) begin
	// 		$display("TIME: %0t addition_initiated", $time());
	// 		addition_initiated_d = 1;
	// 	end
	// endfunction

	function void addition_initiated_checker(transaction driven_tr);
		if(driven_tr.en_i) begin
			$display("TIME: %0t addition_initiated", $time());
			addition_initiated = 1;
		end
	endfunction

	task serializer(input logic [2:0] out_tb);
		for (int i = 2; i >= 0; i--) begin
			expected_output_tr.out = out_tb[i];
			if(i == 2) begin
				expected_output_tr.en_o = 1;
			end
			else begin
				expected_output_tr.en_o = 0;
			end
			input_monitor_to_checker.put(expected_output_tr);
			$display("TIME: %0t SERIALIZER: SENT OUTPUT TO CHECKER",$time());
		end
	endtask : serializer

	task addition(input transaction input_transaction);
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
	task outputMonitor();
		forever begin
			@(posedge en_i);
			$display("TIME: %0t ENTERED OUTPUTMONITOR", $time());
			repeat(3) begin
				@(negedge clk);
			end
			actual_output_tr.en_o = en_o;
			actual_output_tr.out  = out;

			$display("TIME: %0t FIRST ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			output_monitor_to_checker.put(actual_output_tr);

			@(negedge clk);

			actual_output_tr.en_o = en_o;
			actual_output_tr.out  = out;

			$display("TIME: %0t SECOND ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			output_monitor_to_checker.put(actual_output_tr);
			@(negedge clk);

			actual_output_tr.en_o = en_o;
			actual_output_tr.out  = out;

			$display("TIME: %0t THIRD ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			output_monitor_to_checker.put(actual_output_tr);

		end
	endtask : outputMonitor


	task tr_checker();
		transaction expected_output; 
		transaction actual_output;
		forever begin
			input_monitor_to_checker.get(expected_output);
			$display("TIME: %0t EXPECTED_OUTPUT RECIEVED",$time());
			output_monitor_to_checker.get(actual_output);
			$display("TIME: %0t ACTUAL_OUTPUT RECIEVED",$time());
			if((expected_output.en_o == actual_output.en_o) & (expected_output.out == actual_output.out)) begin
				$display("TIME: %0t CORRECT OUTPUT", $time());
			end
			else begin
				$display("INCORRECT OUTPUT");
				$display("TIME: %0t EXPECTED: en_o = %0d, out = %0d, but ACTUAL: en_o = %0d, out = %0d", $time(), expected_output.en_o, expected_output.out, actual_output.en_o, actual_output.out);
			end
		end
	endtask : tr_checker


	final begin


	end

endmodule : simpleadder_tb