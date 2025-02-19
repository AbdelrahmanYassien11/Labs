interface alu_f(input bit clk);

	import alu_pkg::*;

	bit ALU_en, rst_n;
	bit signed 	[INPUT_WIDTH-1:0] A, B;
	bit 	   	[A_OP_WIDTH:0] a_op;
	bit 		[B_OP_WIDTH:0] b_op;
	bit 		a_en, b_en;
	logic signed [OUTPUT_WIDTH-1:0] C;

	bit monitor_flag;
	event finish_test;
	int correct_items, incorrect_items;

	modport SVA (input clk, A, B, a_op, b_op, ALU_en, rst_n, a_en, b_en, C);
endinterface