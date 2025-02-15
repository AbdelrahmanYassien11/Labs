class base;
  protected int x;
endclass

class child extends base;
endclass

module test_child;

	base b;
	child c1;
	child c2;
	child c3;

	initial begin
		b  = new();
		c1 = new();
		//c1.x = 2;
		c2 = new c1;
		c3 = c1;
		//c1.x = 1;
		//c3.x = 5;
		$display("c1.x:%0d, c2.x:%0d, b.x:%0d, c3.x:%0d", c1.x, c2.x, b.x, c3.x);
	end

endmodule : test_child