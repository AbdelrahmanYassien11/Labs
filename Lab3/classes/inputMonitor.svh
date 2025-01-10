class inputMonitor;
	transaction input_tr;
	mailbox #(transaction) inputMonitor_to_scoreboard;
	virtual simpleadder_if v_inf;
	
	function new(virtual simpleadder_if v_inf);
		this.v_inf = v_inf;
		input_tr = new();
	endfunction : new

	task startMonitoring();
		forever begin
			#1;
			@(posedge v_inf.en_i);
			input_tr.en_i = v_inf.en_i;
			input_tr.in_a = v_inf.in_a;
			input_tr.in_b = v_inf.in_b;
			$display("TIME: %0t INPUT_ITEM: %p", $time(), input_tr);
			//inputMonitor_to_scoreboard.put(input_tr);	
					
			@(posedge v_inf.clk);
			input_tr.en_i = v_inf.en_i;
			input_tr.in_a = v_inf.in_a;
			input_tr.in_b = v_inf.in_b;
			//driver_to_monitor.get(input_tr);
			$display("TIME: %0t INPUT_ITEM: %p", $time(), input_tr);
			//inputMonitor_to_scoreboard.put(input_tr);
		end
	endtask : startMonitoring
endclass : inputMonitor