class transaction;
	rand bit [INPUT_WIDTH-1:0] A, B;
	rand bit [2:0] a_op;
	rand bit [1:0] b_op;
	rand bit ALU_en, rst_n, a_en, b_en;
	logic C;

	constraint rst_n_c {rst_n dist {1:/95, 0:/5};}

	constraint ALU_en_c {ALU_en dist {1:/90, 0:/10};}

	constraint a_b_en_c { (a_en & b_en) dist {1:=1, 0:=1};} //

	constraint A_c { A dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint B_c { B dist {-15:=1, 15:=1, [-14:14]:=1};}

	constraint a_op_c { (a_en && !b_en)  -> a_op dist {[6:0]:=1};}

	constraint b_op_c { (a_en && b_en )  -> b_op dist {[3:0]:=1};
						(!a_en && b_en) ->  b_op dist {[2:0]:=1};
	}




endclass