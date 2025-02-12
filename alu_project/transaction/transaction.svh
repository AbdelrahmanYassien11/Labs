class transaction;
	rand bit signed [INPUT_WIDTH-1:0] A, B;
	rand bit [2:0] a_op;
	rand bit [1:0] b_op;
	rand bit ALU_en, rst_n, a_en, b_en;
	logic signed [OUTPUT_WIDTH-1:0]C;
	rand int NO_OF_ITEMS;
	static int NO_OF_ITEMS_ST;


	constraint rst_n_c {rst_n dist {1:/95, 0:/5};}

	constraint ALU_en_c {ALU_en dist {1:/90, 0:/10};}

	constraint a_b_en_c { (a_en & b_en) dist {1:=1, 0:=1};} //

	constraint A_c { A dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint B_c { B dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint a_op_c { (a_en && !b_en)  -> a_op dist {[0:6]:=1};}

	constraint b_op_c { (a_en && b_en )  -> b_op dist {[0:3]:=1};
						(!a_en && b_en) ->  b_op dist {[0:2]:=1};
	}

	constraint randomized_no_of_items { NO_OF_ITEMS inside {[20:40]};
	}


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