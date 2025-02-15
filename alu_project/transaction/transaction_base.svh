class transaction_base;

	rand bit signed [INPUT_WIDTH-1:0] A, B;
	rand bit [2:0] a_op;
	rand bit [1:0] b_op;
	rand bit ALU_en, rst_n, a_en, b_en;
	logic signed [OUTPUT_WIDTH-1:0]C;
	rand int NO_OF_ITEMS;
	static int NO_OF_ITEMS_ST;

	function new ();
		
	endfunction 

	function do_copy (transaction_base t);
		transaction_base to_be_copied;

      	assert(t != null) else
        	$fatal(1,"Tried to copy null transaction");

      	assert($cast(to_be_copied,t)) else
        	$fatal(1,"Faied cast in do_copy");

		rst_n = to_be_copied.rst_n;
		ALU_en = to_be_copied.ALU_en;
		a_en   = to_be_copied.a_en;
		b_en   = to_be_copied.b_en;
		a_op   = to_be_copied.a_op;
		b_op   = to_be_copied.b_op;
		A = to_be_copied.A;
		B = to_be_copied.B;
		C = to_be_copied.C;
	endfunction : do_copy

	function string input2string();
		string s;
		s = $sformatf("Time:%0t rst_n:%0d ALU_en:%0d, a_en:%0d, b_en:%0d, A:%0d, B:%0d, a_op:%0d, b_op:%0d", $time(), rst_n, ALU_en, a_en, b_en, A, B, a_op, b_op);
		return s;
	endfunction : input2string

	function string output2string();
		string s;
		s = $sformatf("Time:%0t C:%0d", $time(), C);
		return s;
	endfunction : output2string

	function string item2string();
		string s;
		s = $sformatf("Time:%0t rst_n:%0d ALU_en:%0d, a_en:%0d, b_en:%0d, A:%0d, B:%0d, a_op:%0d, b_op:%0d, C:%0d", $time(), rst_n, ALU_en, a_en, b_en, A, B, a_op, b_op, C);
		return s;
	endfunction : item2string

endclass;