class transactionx extends transaction_base;

	function new ();
		super.new();
	endfunction

	constraint rst_n_c {rst_n dist {1:/95, 0:/5};}

	constraint ALU_en_c {ALU_en dist {1:/95, 0:/5};}

	constraint a_b_en_c { {a_en, b_en} dist { 2'b00:=10, 2'b01:=30, 2'b10:=30, 2'b11:=30};}

	constraint A_c { A dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint B_c { B dist {-15:=1, 15:=1, [-14:14]:=1};}
	
	constraint op_c { 	/*soft*/ ( a_en && ~b_en)  -> a_op dist {[0:6]:=1};
						/*soft*/ ( a_en &&  b_en)  -> b_op dist {[0:3]:=1};
						/*soft*/ (~a_en &&  b_en)  -> b_op dist {[0:2]:=1};
	}


	constraint randomized_no_of_items { NO_OF_ITEMS inside {[10000:11000]};
	}


endclass : transactionx

class transaction extends transaction_base;


	function new ();
		super.new();
	endfunction

	constraint rst_n_c {rst_n dist {1:/95, 0:/5};}

	constraint ALU_en_c {ALU_en dist {1:/95, 0:/5};}

	constraint a_b_en_c { {a_en, b_en} dist { 2'b00:=10, 2'b01:=30, 2'b10:=30, 2'b11:=30};}

	constraint A_c { A dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint B_c { B dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint op_c { 	/*soft*/ ( a_en && ~b_en)  -> a_op dist {[0:6]:=1};
						/*soft*/ ( a_en &&  b_en)  -> b_op dist {[0:3]:=1};
						/*soft*/ (~a_en &&  b_en)  -> b_op dist {[0:2]:=1};
	}

	constraint randomized_no_of_items { NO_OF_ITEMS inside {[11000:12000]};
	}


endclass
