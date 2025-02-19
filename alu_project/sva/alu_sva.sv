module alu_sva #(INPUT_WIDTH, OUTPUT_WIDTH, A_OP_WIDTH, B_OP_WIDTH)(alu_f.SVA a_if);

	bit clk;
	bit ALU_en, rst_n;
	bit signed 	[INPUT_WIDTH-1:0] A, B;
	bit 	   	[A_OP_WIDTH:0] a_op;
	bit 		[B_OP_WIDTH:0] b_op;
	bit 		a_en, b_en;
	logic signed [OUTPUT_WIDTH-1:0] C;

	parameter CLK_PERIOD = 5;

	assign clk 		= a_if.clk;
	assign rst_n 	= a_if.rst_n;
	assign ALU_en 	= a_if.ALU_en;
	assign A   		= a_if.A;
	assign B   		= a_if.B;
	assign a_en 	= a_if.a_en;
	assign b_en 	= a_if.b_en;
	assign a_op 	= a_if.a_op;
	assign b_op 	= a_if.b_op;

	assign C 		= a_if.C;

	property clk_period;
		realtime tt;
		@(posedge clk) (1, tt = $realtime()) |=> ((tt + (2*CLK_PERIOD)) == $realtime()); 

	endproperty

	property rstn_output;

		@(posedge clk)	$fell(rst_n) |=> (C == 0);

	endproperty

	property ALUen_stable_out;

		@(posedge clk) disable iff(~rst_n) $fell(ALU_en) |=> $stable(C);

	endproperty

	property ALUen_past_out;

		@(posedge clk) disable iff(~rst_n) $fell(ALU_en) |=> ($past(C,1) == C);

	endproperty

	property a_op_illegal;

		@(posedge clk) disable iff(~rst_n || ~ALU_en) ($rose(a_en) && $fell(b_en)) |-> a_op != 7 ;

	endproperty

	property b_op_illegal;

		@(posedge clk) disable iff(~rst_n || ~ALU_en) (~a_en && b_en) |-> b_op != 3;

	endproperty



/**************************************************************************ALU OPERATIONS OUTPUT CHECK*************************************************************/
/*********************************************************************************(a_en & ~b_en)?*******************************************************************/

	property no_en_output_past;

		@(posedge clk) disable iff(~rst_n || ~ALU_en) (~a_en & ~b_en) |=> C == $past(C, 1) ;

	endproperty

	property no_en_output_stable;

		@(posedge clk) disable iff(~rst_n || ~ALU_en) (~a_en & ~b_en) |=> $stable(C) ;

	endproperty

/*********************************************************************************(a_en & ~b_en)?*******************************************************************/
	
	property a_op_0;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 0) |=> C == ($past(A, 1) + $past(B,1));

	endproperty

	property a_op_1;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 1) |=> C == ($past(A, 1) - $past(B,1));

	endproperty

	property a_op_2;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 2) |=> C == ($past(A, 1) ^ $past(B,1));

	endproperty

	property a_op_3;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 3) |=> C == ($past(A, 1) & $past(B,1));

	endproperty

	property a_op_4;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 4) |=> C == ($past(A, 1) & $past(B,1));

	endproperty

	property a_op_5;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 5) |=> C == ($past(A, 1) | $past(B,1));

	endproperty

	property a_op_6;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 6) |=> C == ~($past(A, 1) ^ $past(B,1));

	endproperty

	property a_op_7_past;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 7) |=> C == $past(C, 1) ;

	endproperty

	property a_op_7_stable;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & ~b_en) && a_op == 7) |=> $stable(C) ;

	endproperty

/*********************************************************************************(~a_en & b_en)?*******************************************************************/

	property b_op10_0;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((~a_en & b_en) && b_op == 0) |=> C == ~($past(A, 1) & $past(B,1));

	endproperty

	property b_op10_1;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((~a_en & b_en) && b_op == 1) |=> C == ($past(A, 1) + $past(B,1));

	endproperty

	property b_op10_2;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((~a_en & b_en) && b_op == 2) |=> C == ($past(A, 1) + $past(B,1));

	endproperty

	property b_op10_3_past;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((~a_en & b_en) && b_op == 3) |=> C == $past(C,1);

	endproperty

	property b_op10_3_stable;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((~a_en & b_en) && b_op == 3) |=> $stable(C);

	endproperty


/*********************************************************************************(a_en & b_en)?*******************************************************************/

	property b_op11_0;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & b_en) && b_op == 0) |=> C == ($past(A, 1) ^ $past(B,1));

	endproperty

	property b_op11_1;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & b_en) && b_op == 1) |=> C == ~($past(A, 1) ^ $past(B,1));

	endproperty

	property b_op11_2;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & b_en) && b_op == 2) |=> C == ($past(A, 1) - 1);

	endproperty

	property b_op11_3;

		@(posedge clk) disable iff((~rst_n) || ~ALU_en) ((a_en & b_en) && b_op == 3) |=> C == ($past(B,1) + 2);

	endproperty


/*************************************************************************************************************************************************************************************************************/

	clk_period_assert: 			assert property (clk_period);
	rstn_output_assert: 		assert property (rstn_output);
	ALUen_stable_out_assert: 	assert property (ALUen_stable_out);
	ALUen_past_out_assert: 		assert property (ALUen_past_out);
	a_op_illegal_assert: 		assert property (a_op_illegal);
	b_op_illegal_assert: 		assert property (b_op_illegal);

	no_en_output_stable_assert: assert property  (no_en_output_stable);
	no_en_output_psat_assert:	assert property  (no_en_output_past);

	q_op_0_assert:				assert property (a_op_0);
	q_op_1_assert:				assert property (a_op_1);
	q_op_2_assert:				assert property (a_op_2);
	q_op_3_assert:				assert property (a_op_3);
	q_op_4_assert:				assert property (a_op_4);
	q_op_5_assert:				assert property (a_op_5);
	q_op_6_assert:				assert property (a_op_6);
	q_op_7_past_assert:			assert property (a_op_7_past);
	q_op_7_stable_assert:		assert property (a_op_7_stable);

	b_op10_0_assert:  			assert property (b_op10_0);
	b_op10_1_assert:  			assert property (b_op10_1);
	b_op10_2_assert:  			assert property (b_op10_2);
	b_op10_3_past_assert:  		assert property (b_op10_3_past);
	b_op10_3_stable_assert:  	assert property (b_op10_3_stable);

	b_op11_0_assert:  			assert property (b_op11_0);
	b_op11_1_assert:  			assert property (b_op11_1);
	b_op11_2_assert:  			assert property (b_op11_2);
	b_op11_3_assert:  			assert property (b_op11_3);

	// Assertions coverage

	clk_period_cover:			cover property (clk_period);
	rstn_output_cover: 			cover property (rstn_output);
	ALUen_stable_out_cover: 	cover property (ALUen_stable_out);
	ALUen_past_out_cover: 		cover property (ALUen_past_out);
	a_op_illegal_cover: 		cover property (a_op_illegal);
	b_op_illegal_cover: 		cover property (b_op_illegal);


	q_op_0_cover:				cover property (a_op_0);
	q_op_1_cover:				cover property (a_op_1);
	q_op_2_cover:				cover property (a_op_2);
	q_op_3_cover:				cover property (a_op_3);
	q_op_4_cover:				cover property (a_op_4);
	q_op_5_cover:				cover property (a_op_5);
	q_op_6_cover:				cover property (a_op_6);
	q_op_7_past_cover:			cover property (a_op_7_past);
	q_op_7_stable_cover:		cover property (a_op_7_stable);

	b_op10_0_cover:  			cover property (b_op10_0);
	b_op10_1_cover:  			cover property (b_op10_1);
	b_op10_2_cover:  			cover property (b_op10_2);
	b_op10_3_past_cover:  		cover property (b_op10_3_past);
	b_op10_3_stable_cover:  	cover property (b_op10_3_stable);

	b_op11_0_cover:  			cover property (b_op11_0);
	b_op11_1_cover:  			cover property (b_op11_1);
	b_op11_2_cover:  			cover property (b_op11_2);
	b_op11_3_cover:  			cover property (b_op11_3);



endmodule : alu_sva











