class driver;
	transaction driven_tr;
	mailbox #(transaction) sequence_to_driver;

	virtual simpleadder_if v_inf;

	function new(virtual simpleadder_if v_inf);
		this.v_inf = v_inf;
		driven_tr = new();
	endfunction

	task drive();
		forever begin
			@(negedge v_inf.clk);
			sequence_to_driver.get(driven_tr);
			v_inf.en_i <= driven_tr.en_i;
			v_inf.in_a <= driven_tr.in_a;
			v_inf.in_b <= driven_tr.in_b;

			$display("TIME: %0t DRIVEN_ITEM = %p", $time(), driven_tr);

			//addition_initiated_checker(driven_tr);

			if((v_inf.addition_initiated == 1) && (driven_tr.en_i == 0)) begin
				repeat(4) begin
					$display("TIME: %0t DELAYING DRIVER",$time());
					@(negedge v_inf.clk);
				end
				v_inf.addition_initiated = 0;
			end			
		end
	endtask : drive


endclass : driver