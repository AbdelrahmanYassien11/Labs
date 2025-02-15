class transactionx /* extends transaction_base*/;

	rand bit signed [INPUT_WIDTH-1:0] A, B;
	rand bit [2:0] a_op;
	rand bit [1:0] b_op;
	rand bit ALU_en, rst_n, a_en, b_en;
	logic signed [OUTPUT_WIDTH-1:0]C;
	rand int NO_OF_ITEMS;
	static int NO_OF_ITEMS_ST;

	// function new ();
	// 	super.new();
	// endfunction

	constraint rst_n_c {rst_n dist {1:/95, 0:/5};}

	constraint ALU_en_c {ALU_en dist {1:/95, 0:/5};}

	constraint a_b_en_c { {a_en, b_en} dist { 2'b00:=10, 2'b01:=30, 2'b10:=30, 2'b11:=30};}

	constraint A_c { A dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint B_c { B dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint a_op_c { (a_en && !b_en)  -> a_op dist {[0:6]:=1};}

	constraint b_op_c { (a_en && b_en )  -> b_op dist {[0:3]:=1};
						(!a_en && b_en) ->  b_op dist {[0:2]:=1};
	}

	constraint randomized_no_of_items { NO_OF_ITEMS inside {[2000:2500]};
	}

	function do_copy (transactionx t);
		transactionx to_be_copied;

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

endclass : transactionx

class transaction /*extends transaction_base*/;

	rand bit signed [INPUT_WIDTH-1:0] A, B;
	rand bit [2:0] a_op;
	rand bit [1:0] b_op;
	rand bit ALU_en, rst_n, a_en, b_en;
	logic signed [OUTPUT_WIDTH-1:0]C;
	rand int NO_OF_ITEMS;
	static int NO_OF_ITEMS_ST;

	// function new ();
	// 	super.new();
	// endfunction

	constraint rst_n_c {rst_n dist {1:/95, 0:/5};}

	constraint ALU_en_c {ALU_en dist {1:/95, 0:/5};}

	constraint a_b_en_c { {a_en, b_en} dist { 2'b00:=10, 2'b01:=30, 2'b10:=30, 2'b11:=30};}

	constraint A_c { A dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint B_c { B dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint a_op_c { (a_en && !b_en)  -> a_op dist {[0:6]:=1};}

	constraint b_op_c { (a_en && b_en )  -> b_op dist {[0:3]:=1};
						(!a_en && b_en) ->  b_op dist {[0:2]:=1};
	}

	constraint randomized_no_of_items { NO_OF_ITEMS inside {[2000:2500]};
	}

	function do_copy (transaction t);
		transaction to_be_copied;

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
endclass

// class transaction_base;



// endclass : transaction_base