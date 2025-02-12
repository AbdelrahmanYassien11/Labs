interface alu_f(input bit clk);
	import alu_pkg::*;
	bit signed [INPUT_WIDTH-1:0] A, B;
	bit [2:0] a_op;
	bit [1:0] b_op;
	bit ALU_en, rst_n, a_en, b_en;
	logic signed [OUTPUT_WIDTH-1:0] C;
	bit monitor_flag;
	event finish_test;
	int correct_items, incorrect_items;
endinterface