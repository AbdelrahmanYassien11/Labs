class predictor;
	transaction predictor_tr;

	mailbox #(transaction) scoreboard_to_predictor;
	mailbox #(transaction) predictor_to_comparator;

	virtual simpleadder_if v_inf;
	
	function new(virtual simpleadder_if v_inf);
		this.v_inf = v_inf;
		//predictor_tr = new();
	endfunction : new

	task predict();
		forever begin
			scoreboard_to_predictor.get(predictor_tr);
			$display("TIME: %0t CALLING ADDITION", $time());
			$display("RECIEVED ITEM IN PREDICTOR %p",predictor_tr);
			addition(predictor_tr);
			//@(posedge v_inf.clk);
		end
	endtask : predict

	task addition(input transaction input_transaction);
		static logic [1:0] ina_tb, inb_tb;
		static logic [2:0] out_tb;
		if(v_inf.addition_initiated & ~input_transaction.en_i) begin
			ina_tb = ina_tb << 1;
			inb_tb = inb_tb << 1;
			$display("TIME: %0t ADDITION: SECOND_CYCLE",$time());
		end
			$display("TIME: %0t ADDITION: FIRST_SECOND_CYCLE",$time());
		ina_tb[0] = input_transaction.in_a;
		inb_tb[0] = input_transaction.in_b;

		if(v_inf.addition_initiated & ~input_transaction.en_i) begin
			out_tb  = ina_tb + inb_tb;
			$display("TIME: %0t, CALLING SERIALIZER out_tb:%0d",$time(), out_tb);
			serializer(out_tb);
		end
	endtask : addition

	task serializer(input logic [2:0] out_tb);
		transaction expected_output_tr = new();
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