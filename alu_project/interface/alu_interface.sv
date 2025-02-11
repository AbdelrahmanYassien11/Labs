interface alu_f(input bit clk);
	bit [INPUT_WIDTH-1:0] A, B;
	bit [2:0] a_op;
	bit [1:0] b_op;
	bit ALU_en, rst_n, a_en, b_en;
	logic C;
	
endinterface