
// covergroup data_cg(input bit [DATA_WIDTH-1:0] );
   	
// endgroup : data_cg




class coverage;

	virtual alu_f v_inf;
	mailbox #(transaction) inputMonitor_to_coverage, outputMonitor_to_coverage;
	transaction input_cov, output_cov;

	function new(virtual alu_f v_inf, mailbox #(transaction) inputMonitor_to_coverage, outputMonitor_to_coverage);
		this.v_inf = v_inf;
		this.inputMonitor_to_coverage  = inputMonitor_to_coverage;
		this.outputMonitor_to_coverage = outputMonitor_to_coverage;
		input_cov = new();
		output_cov = new();
	endfunction 

	// covergroup data_cg();
	//    	df_A: coverpoint input_cov.A iff rst_n {
	//    		bins: A_df_cov = {};
	//    	}

	//    	df_B: coverpoint input_cov.B iff rst_n {
	//    		bins:
	//    	}
	// endgroup : data_cg

	task execute ();
		// forever begin
		// 	inputMonitor_to_coverage.get(input_cov);
		// 	outputMonitor_to_coverage.get(output_cov);
		// end
	endtask : execute 

	// task sample_inputs();
	// 	forever begin
	// 		inputMonitor_to_coverage.get(input_cov);
	// 	end
	// endtask : sample_inputs

	// task sample_outputs();
	// 	forever begin
	// 		outputMonitor_to_coverage.get(output_cov);
	// 	end
	// endtask : sample_outputs


endclass