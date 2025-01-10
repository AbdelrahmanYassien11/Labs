class outputMonitor;

	mailbox #(transaction) outputMonitor_to_scoreboard;
	transaction actual_output_tr;

	virtual simpleadder_if v_inf;
	
	function new(virtual simpleadder_if v_inf);
		this.v_inf = v_inf;
		actual_output_tr = new();
	endfunction : new

	task startMonitoring();
		forever begin
			@(posedge v_inf.en_i);
			$display("TIME: %0t ENTERED OUTPUTMONITOR", $time());
			repeat(3) begin
				@(negedge v_inf.clk);
			end
			actual_output_tr.en_o = v_inf.en_o;
			actual_output_tr.out  = v_inf.out;

			$display("TIME: %0t FIRST ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			outputMonitor_to_scoreboard.put(actual_output_tr);

			@(negedge v_inf.clk);

			actual_output_tr.en_o = v_inf.en_o;
			actual_output_tr.out  = v_inf.out;

			$display("TIME: %0t SECOND ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			outputMonitor_to_scoreboard.put(actual_output_tr);
			@(negedge v_inf.clk);

			actual_output_tr.en_o = v_inf.en_o;
			actual_output_tr.out  = v_inf.out;

			$display("TIME: %0t THIRD ADDITION OUTPUT: en_o = %0d, out = %0d ",$time(), actual_output_tr.en_o, actual_output_tr.out);

			outputMonitor_to_scoreboard.put(actual_output_tr);
		end
	endtask : startMonitoring

endclass : outputMonitor