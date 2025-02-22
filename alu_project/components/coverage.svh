
covergroup A_cg_df(input int signed i, input transaction_base cov);
	option.weight = ((i == -16)? 0:1);
   	option.name = $sformatf("df = %0d",i);
   	option.per_instance = 1;
   	df: coverpoint cov.A iff (cov.rst_n && cov.ALU_en) {
   		bins A[] = {i};
   		`ifdef RANDOM_ERROR_INJECTION_TEST
			ignore_bins A_ignored[] = {-16};
		`else 
			illegal_bins A_illegal[] = {-16};
		`endif
   	}
endgroup : A_cg_df

covergroup B_cg_df(input int signed i, input transaction_base cov);
   	option.weight = ((i == -16)? 0:1);
   	option.name = $sformatf("df = %0d",i);
   	option.per_instance = 1;   	
   	df: coverpoint cov.B iff (cov.rst_n && cov.ALU_en) {
   		bins B[] = {i};
   		`ifdef RANDOM_ERROR_INJECTION_TEST
			ignore_bins A_ignored[] = {-16};
		`else 
			illegal_bins A_illegal[] = {-16};
		`endif
   	}
endgroup : B_cg_df

covergroup A_op_cg_df(input int i, input transaction_base cov);
	option.weight = ((i == 7)? 0:1);
	option.name = $sformatf("df = %0d",i);
	option.per_instance = 1;
	df: coverpoint cov.a_op iff (cov.rst_n && (cov.a_en & ~cov.b_en) && cov.ALU_en) {
		bins A_op[] = {i};
   		`ifdef RANDOM_ERROR_INJECTION_TEST
			ignore_bins A_op_ignored[] = {7};
		`else 
			illegal_bins A_op_illegal[] = {7};
		`endif
	}
endgroup : A_op_cg_df

covergroup A_op_cg_dt(input int i, input int k , input transaction_base cov);
	option.weight = ((k == 7 || i == 7)? 0:1);
	option.name = $sformatf("dt %0d => %0d", i, k);
   	option.per_instance = 1;
   	dt: coverpoint cov.a_op iff (cov.rst_n && (cov.a_en & ~cov.b_en) && cov.ALU_en) {
   		bins A_op[] = (i => k);
   		`ifdef RANDOM_ERROR_INJECTION_TEST
			ignore_bins A_op_ignored1[] = (i => 7);
   			ignore_bins A_op_ignored2[] = (7 => k);
		`else 
   			illegal_bins A_op_illegal1[] = (i => 7);
   			illegal_bins A_op_illegal2[] = (7 => k);
		`endif
   	}	
endgroup : A_op_cg_dt

covergroup B_op01_cg_df(input int i, input transaction_base cov);
	option.weight = ((i == 3)? 0:1);
	option.name   = $sformatf("df %0d",i);
	option.per_instance = 1;
	df: coverpoint cov.b_op iff (cov.rst_n && cov.ALU_en && (~cov.a_en && cov.b_en)) {
		bins B_op[] = {i};
   		`ifdef RANDOM_ERROR_INJECTION_TEST
			ignore_bins B_op_ignored[] = {3};
		`else 
			illegal_bins B_op_illegal[] = {3};
		`endif
	}
endgroup : B_op01_cg_df

covergroup B_op01_cg_dt(input int i, input int k , input transaction_base cov);
	option.weight = ((k == 3 || i == 3)? 0:1);
	option.name = $sformatf("dt %0d => %0d", i, k);
   	option.per_instance = 1;
   	dt: coverpoint cov.b_op iff (cov.rst_n && (~cov.a_en & cov.b_en) && cov.ALU_en) {
   		bins B_op[] = (i => k);
   		`ifdef RANDOM_ERROR_INJECTION_TEST
			ignore_bins B_op_ignored1[] = (i => 3);
   			ignore_bins B_op_ignored2[] = (3 => k);
		`else 
   			illegal_bins B_op_illegal1[] = (i => 3);
   			illegal_bins B_op_illegal2[] = (3 => k);
		`endif
   	}
endgroup : B_op01_cg_dt

covergroup B_op11_cg_df(input int i, input transaction_base cov);
	option.name   = $sformatf("df %0d",i);
	option.per_instance = 1;
	df: coverpoint cov.b_op iff (cov.rst_n && cov.ALU_en && (cov.a_en & cov.b_en)) {
		bins B_op[] = {i};
	}
endgroup : B_op11_cg_df

covergroup B_op11_cg_dt(input int i, input int k , input transaction_base cov);
	option.name = $sformatf("dt %0d => %0d", i, k);
   	option.per_instance = 1;
   	dt: coverpoint cov.b_op iff (cov.rst_n && (cov.a_en & cov.b_en) && cov.ALU_en) {
   		bins B_op[] = (i => k);
   	}
endgroup : B_op11_cg_dt

covergroup A_B_en_cg_df(input int i, input transaction_base cov);
	option.name = $sformatf("df = 'b%0b",i);
	option.per_instance = 1;
	df: coverpoint {cov.a_en,cov.b_en} iff (cov.rst_n && cov.ALU_en) {
		bins A_B_en[] = {i};
	}
endgroup : A_B_en_cg_df

covergroup A_B_en_cg_dt(input int i, input int k, input transaction_base cov);
	option.name = $sformatf("dt 'b%0b => 'b%0b", i, k);
	option.per_instance = 1;
	df: coverpoint {cov.a_en,cov.b_en} iff (cov.rst_n && cov.ALU_en) {
		bins A_B_en[] = (i => k);
	}
endgroup : A_B_en_cg_dt

covergroup ALU_en_cg_df(input int i, input transaction_base cov);
	option.name = $sformatf("df = %0d",i);
	option.per_instance = 1;
	df: coverpoint cov.ALU_en iff (cov.rst_n) {
		bins ALU_en[] = {i};
	}
endgroup : ALU_en_cg_df

covergroup ALU_en_cg_dt(input int i, input int k, input transaction_base cov);
	option.name = $sformatf("dt %0d => %0d",i, k);
	option.per_instance = 1;
	df: coverpoint cov.ALU_en iff (cov.rst_n) {
		bins ALU_en[] = (i => k);
	}
endgroup : ALU_en_cg_dt

covergroup rstn_cg_df(input int i, input transaction_base cov);
	option.name = $sformatf("df = %0d",i);
	option.per_instance = 1;
	df: coverpoint cov.rst_n {
		bins rst_n[] = {i};
	}
endgroup : rstn_cg_df

covergroup rstn_cg_dt(input int i, input int k, input transaction_base cov);
	option.name = $sformatf("dt %0d => %0d",i, k);
	option.per_instance = 1;
	df: coverpoint cov.rst_n {
		bins rst_n[] = (i => k);
	}
endgroup : rstn_cg_dt

covergroup rstn_thrice_consecutive (input int i, input transaction_base cov);
	option.name = $sformatf("df = %0d",i);
	option.per_instance = 1;
	df: coverpoint cov.rst_n{
		bins rst_n[] = (cov.rst_n[*i]);
	}
endgroup : rstn_thrice_consecutive

covergroup C_cg_df(input int signed i, input transaction_base cov);
	option.weight = ((i == -32 )?0:1);
	option.name = $sformatf("df = %0d",i);
	option.per_instance = 1;
	df: coverpoint cov.C iff (cov.rst_n) {
		bins C[] = {i};
		`ifdef RANDOM_ERROR_INJECTION_TEST
			ignore_bins C_ignored    = {-32};
		`else 
			illegal_bins C_illegal[] = {-32};
		`endif
	}
endgroup : C_cg_df

covergroup C_cg_dt(input int signed i, input int signed k, input transaction cov);
	option.weight = ((i == -32 || k == -32)?0:1);
	option.name = $sformatf("dt %0d => %0d", i, k);
	option.per_instance = 1;
	option.goal = 50;
	df: coverpoint cov.C iff (cov.rst_n) {
		bins C[] = (i => k);
		illegal_bins C_illegal1[] = (i => -32);
		illegal_bins C_illegal2[] = (-32 => k);
	}
endgroup : C_cg_dt

class coverage#(type T = int) extends coverage_base#(T);

	T input_cov, output_cov, input_cov_copied, output_cov_copied;
	
	protected int signed j, z;

	A_cg_df A_cg_df_vals [(2**INPUT_WIDTH)];
	B_cg_df B_cg_df_vals [(2**INPUT_WIDTH)];

	A_op_cg_df   A_op_cg_df_vals   [2**A_OP_WIDTH];
	B_op01_cg_df B_op01_cg_df_vals [2**B_OP_WIDTH];
	B_op11_cg_df B_op11_cg_df_vals [2**B_OP_WIDTH];

	A_op_cg_dt A_op_cg_dt_vals [(2**A_OP_WIDTH)][(2**A_OP_WIDTH)];

	B_op01_cg_dt B_op01_cg_dt_vals [(2**B_OP_WIDTH)][(2**B_OP_WIDTH)];
	B_op11_cg_dt B_op11_cg_dt_vals [(2**B_OP_WIDTH)][(2**B_OP_WIDTH)];

	A_B_en_cg_df A_B_en_cg_df_vals [2**(2*1)];
	A_B_en_cg_dt A_B_en_cg_dt_vals [2**(2*1)][2**(2*1)];

	ALU_en_cg_df ALU_en_cg_df_vals [2**1];
	ALU_en_cg_dt ALU_en_cg_dt_vals [2**1][2**1];

	rstn_cg_df rstn_cg_df_vals [2**1];
	rstn_cg_dt rstn_cg_dt_vals [2**1][2**1];
	rstn_thrice_consecutive rstn_thrice_consecutive_vals [3:1];

	C_cg_df C_cg_df_vals [(2**OUTPUT_WIDTH)];
	C_cg_dt C_cg_dt_vals [(2**OUTPUT_WIDTH)][(2**OUTPUT_WIDTH)];



	// covergroup inputs_cg();
	// 	option.per_instance = 1;
	// 	A_df:coverpoint input_cov_copied.A iff (input_cov_copied.ALU_en & input_cov_copied.rst_n){
	// 		option.weight = ((input_cov_copied.A == -16)?0:1);
	// 		//option.per_instance = 1;
	// 		bins A[] = {[-16:15]};
	// 		`ifdef RANDOM_ERROR_INJECTION_TEST
	// 			ignore_bins A_ignored[] = {-16};
	// 		`else 
	// 			illegal_bins A_illegal[] = {-16};
	// 		`endif
	// 	}

	// 	B_df:coverpoint input_cov_copied.B iff (input_cov_copied.ALU_en & input_cov_copied.rst_n){
	// 		option.weight = ((input_cov_copied.B == -16)?0:1);
	// 		//option.per_instance = 1;
	// 		bins B[] = {[-16:15]};
	// 		`ifdef RANDOM_ERROR_INJECTION_TEST
	// 			ignore_bins B_ignored[] = {-16};
	// 		`else 
	// 			illegal_bins B_illegal[] = {-16};
	// 		`endif
	// 	}

	// 	A_en_df:coverpoint input_cov_copied.a_en iff (input_cov_copied.ALU_en & input_cov_copied.rst_n){
	// 		bins A_en[] = {0,1};
	// 	}

	// 	B_en_df:coverpoint input_cov_copied.b_en iff (input_cov_copied.ALU_en & input_cov_copied.rst_n){
	// 		bins B_en[] = {0,1};
	// 	}

	// 	A_op_df:coverpoint input_cov_copied.a_op iff (input_cov_copied.ALU_en & input_cov_copied.rst_n && (input_cov_copied.a_en & ~input_cov_copied.b_en)){
	// 		option.weight = ((input_cov_copied.a_op == 7)?0:1);
	// 		bins A_op[] = {[0:7]};
	// 		`ifdef RANDOM_ERROR_INJECTION_TEST
	// 			ignore_bins A_op_ignored[] = {7};
	// 		`else 
	// 			illegal_bins A_op_illegal[] = {7};
	// 		`endif
	// 	}

	// 	B_op01_df:coverpoint input_cov_copied.b_op iff (input_cov_copied.ALU_en & input_cov_copied.rst_n && (~input_cov_copied.a_en & input_cov_copied.b_en)){
	// 		option.weight = ((input_cov_copied.b_op == 3)?0:1);
	// 		//option.per_instance = 1;
	// 		bins B_op01[] = {[0:3]};
	// 		`ifdef RANDOM_ERROR_INJECTION_TEST
	// 			ignore_bins B_op01_ignored[] = {3};
	// 		`else 
	// 			illegal_bins B_op01_illegal[] = {3};
	// 		`endif
	// 	}

	// 	B_op11_df:coverpoint input_cov_copied.b_op iff (input_cov_copied.ALU_en & input_cov_copied.rst_n && (input_cov_copied.a_en & input_cov_copied.b_en)){
	// 		bins B_op11[] = {[0:3]};
	// 	}

	// 	A_B_Aen_Ben_Aop: cross A_df, B_df, A_en_df, B_en_df, A_op_df {
	// 		option.cross_retain_auto_bins = 0;
 //        	bins A_op_cases	= binsof(A_df) && binsof(B_df) && binsof(A_en_df) intersect {1} && 
 //        					  binsof(B_en_df) intersect {0} && binsof(A_op_df);
	// 	}

	// 	A_B_Aen_Ben_Bop01: cross A_df, B_df, A_en_df, B_en_df, B_op01_df {
	// 		option.cross_retain_auto_bins = 0;
 //        	bins B_op01_cases = binsof(A_df) && binsof(B_df) && binsof(A_en_df) intersect {0} &&
 //        					    binsof(B_en_df) intersect {1} && binsof(B_op01_df);
	// 	}

	// 	A_B_Aen_Ben_Bop11: cross A_df, B_df, A_en_df, B_en_df, B_op11_df iff {
	// 		option.cross_retain_auto_bins = 0;

 //        	bins B_op11_cases = binsof(A_df) && binsof(B_df) && binsof(A_en_df) intersect {1} &&
 //        					    binsof(B_en_df) intersect {1} && binsof(B_op11_df);
	// 	}

	// endgroup : inputs_cg

	// covergroup outputs_cg();

	// 	C_df:coverpoint output_cov_copied.A iff (output_cov_copied.rst_n){
	// 		option.weight = ((output_cov_copied.C == -32)?0:1);
	// 		bins C[] = {[-16:15]};
	// 		`ifdef RANDOM_ERROR_INJECTION_TEST
	// 			ignore_bins C_ignored[] = {-32};
	// 		`else 
	// 			illegal_bins C_illegal[] = {-32};
	// 		`endif
	// 	}
	   	
	endgroup : outputs_cg

	function new(virtual alu_f v_inf, mailbox #(T) inputMonitor_to_coverage, outputMonitor_to_coverage);
		super.new(v_inf, inputMonitor_to_coverage, outputMonitor_to_coverage);
		input_cov = new();
		output_cov = new();
		input_cov_copied = new();
		output_cov_copied = new();

		j = -(2**(INPUT_WIDTH-1));//-16
		for (int i = 0; i < (2**(INPUT_WIDTH)) ; i++) begin //0 to 31
			A_cg_df_vals[i] = new(j, input_cov_copied);
			B_cg_df_vals[i] = new(j, input_cov_copied);
			j = j + 1;
		end

		j = -(2**(OUTPUT_WIDTH-1));//-32
		for (int i = 0; i < (2**(OUTPUT_WIDTH)) ; i++) begin
			C_cg_df_vals[i] = new(j, output_cov_copied);
			j = j + 1;
		end

		z = -(2**(OUTPUT_WIDTH-1));//-32
		for (int i = 0; i < (2**(OUTPUT_WIDTH)) ; i++) begin
			j = -(2**(OUTPUT_WIDTH-1));
			for (int k = 0; k < (2**(OUTPUT_WIDTH)); k++) begin
				C_cg_dt_vals[i][k] = new(z, j, output_cov_copied);
				j = j + 1;
			end
			z = z + 1;
		end

		foreach(A_op_cg_df_vals[i]) A_op_cg_df_vals[i] 	   = new(i, input_cov_copied);
		foreach(B_op01_cg_df_vals[i]) B_op01_cg_df_vals[i] = new(i, input_cov_copied);
		foreach(B_op11_cg_df_vals[i]) B_op11_cg_df_vals[i] = new(i, input_cov_copied);

		foreach(A_op_cg_dt_vals[i,j]) A_op_cg_dt_vals[i][j] 	= new(i, j, input_cov_copied);
		foreach(B_op01_cg_dt_vals[i,j]) B_op01_cg_dt_vals[i][j] = new(i, j, input_cov_copied);
		foreach(B_op11_cg_dt_vals[i,j]) B_op11_cg_dt_vals[i][j] = new(i, j, input_cov_copied);

		foreach(A_B_en_cg_df_vals[i]) A_B_en_cg_df_vals[i] = new(i, input_cov_copied);
		foreach(A_B_en_cg_dt_vals[i,j]) A_B_en_cg_dt_vals[i][j] = new(i, j, input_cov_copied);

		foreach(ALU_en_cg_df_vals[i]) ALU_en_cg_df_vals[i] = new(i,input_cov_copied);
		foreach(ALU_en_cg_dt_vals[i,j]) ALU_en_cg_dt_vals[i][j] = new(i,j,input_cov_copied);

		foreach(rstn_cg_df_vals[i]) rstn_cg_df_vals[i] = new(i,input_cov_copied);
		foreach(rstn_cg_dt_vals[i,j]) rstn_cg_dt_vals[i][j] = new(i,j,input_cov_copied);
		
		for (int i = 1; i < 4 ; i++) begin
			rstn_thrice_consecutive_vals[i] = new(i, input_cov_copied);
		end

		inputs_cg  = new();

		outputs_cg = new();
		

	endfunction 

	task execute ();
		fork
			sample_inputs();
			sample_outputs();
		join_none
	endtask : execute 


	task sample_inputs();
		forever begin
			input_cov = new();
			inputMonitor_to_coverage.get(input_cov);
			input_cov_copied.do_copy(input_cov);
			foreach(A_cg_df_vals[i]) A_cg_df_vals[i].sample();
			foreach(B_cg_df_vals[i]) B_cg_df_vals[i].sample();

			foreach(A_op_cg_dt_vals[i,j]) A_op_cg_dt_vals[i][j].sample();
			foreach(B_op01_cg_dt_vals[i,j]) B_op01_cg_dt_vals[i][j].sample();
			foreach(B_op11_cg_dt_vals[i,j]) B_op11_cg_dt_vals[i][j].sample();

			foreach(A_op_cg_df_vals[i]) A_op_cg_df_vals[i].sample();
			foreach(B_op01_cg_df_vals[i]) B_op01_cg_df_vals[i].sample();
			foreach(B_op11_cg_df_vals[i]) B_op11_cg_df_vals[i].sample();			

			foreach(A_B_en_cg_df_vals[i]) A_B_en_cg_df_vals[i].sample();

			foreach(A_B_en_cg_dt_vals[i,j]) A_B_en_cg_dt_vals[i][j].sample();

			foreach(ALU_en_cg_df_vals[i]) ALU_en_cg_df_vals[i].sample();
			foreach(ALU_en_cg_dt_vals[i,j]) ALU_en_cg_dt_vals[i][j].sample();

			foreach(rstn_cg_df_vals[i]) rstn_cg_df_vals[i].sample();
			foreach(rstn_cg_dt_vals[i,j]) rstn_cg_dt_vals[i][j].sample();
			foreach(rstn_thrice_consecutive_vals[i]) rstn_thrice_consecutive_vals[i].sample();

			inputs_cg.sample();
			outputs_cg.sample();
		end
	endtask : sample_inputs

	task sample_outputs();
		forever begin
			output_cov = new();
			outputMonitor_to_coverage.get(output_cov);
			output_cov_copied.do_copy(output_cov);
			foreach(C_cg_df_vals[i]) C_cg_df_vals[i].sample();
			foreach(C_cg_dt_vals[i,j]) C_cg_dt_vals[i][j].sample();
		end
	endtask : sample_outputs


endclass