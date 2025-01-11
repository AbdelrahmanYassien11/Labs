class driver;
	transaction driven_tr;
	mailbox #(transaction) sequence_to_driver;

	virtual simpleadder_if v_inf;

	function new(virtual simpleadder_if v_inf, mailbox #(transaction) sequence_to_driver);
		this.v_inf = v_inf;
		driven_tr = new();
		this.sequence_to_driver = sequence_to_driver;
	endfunction

	task drive();
		forever begin
			@(negedge v_inf.clk);
			//$display("DRIVER: BEFORE GETTING ITEM");
			sequence_to_driver.get(driven_tr);
			$display("DRIVEN_ITEM = %s", driven_tr.input2string());
			v_inf.en_i <= driven_tr.en_i;
			v_inf.in_a <= driven_tr.in_a;
			v_inf.in_b <= driven_tr.in_b;

			addition_initiated_checker(driven_tr);

			//addition_initiated_checker(driven_tr);
			//$display("driven_tr.en_i: %0d",driven_tr.en_i);
			//$display("v_inf.addition_initiated: %0d",v_inf.addition_initiated);
			if((v_inf.addition_initiated == 1) && (driven_tr.en_i == 0)) begin
				repeat(4) begin
					//$display("TIME: %0t DELAYING DRIVER",$time());
					@(negedge v_inf.clk);
				end
				v_inf.addition_initiated = 0;
			end			
		end
	endtask : drive

	function void addition_initiated_checker(transaction driven_tr);
		if(driven_tr.en_i) begin
			//$display("TIME: %0t addition_initiated", $time());
			v_inf.addition_initiated = 1;
		end
	endfunction


endclass : driver