class putter;

	mailbox #(int) putter_mbx;

	function new(mailbox #(int) putter_mbx);
		this.putter_mbx = putter_mbx;
	endfunction

	task execute();
		for (int i = 0; i < 3; i++) begin
			putter_mbx.put(i);
		end
	endtask : execute

endclass : putter


class getter1;

	mailbox #(int) getter1_mbx;
	int get1;

	function new(mailbox #(int) getter1_mbx);
		this.getter1_mbx = getter1_mbx;
	endfunction

	task execute();
		repeat(3) begin
			getter1_mbx.get(get1);
			$display("TIME: %0t, get1:%0d",$time(), get1);
		end
	endtask : execute

endclass : getter1

class getter2;

	mailbox #(int) getter2_mbx;
	int get2;

	function new(mailbox #(int) getter2_mbx);
		this.getter2_mbx = getter2_mbx;
	endfunction

	task execute();
		repeat(3) begin
			getter2_mbx.get(get2);
			$display("TIME: %0t, get2:%0d",$time(), get2);
		end
	endtask : execute

endclass : getter2

class atlas;

	mailbox #(int) atlas;
	putter putter_h;
	getter1 getter1_h;
	getter2 getter2_h;

	function new();
		atlas = new(1);
		putter_h = new(atlas);
		getter1_h = new(atlas);
		getter2_h = new(atlas);
	endfunction  

	task execute();
		fork
		 	putter_h.execute();
		 	getter1_h.execute();
		 	getter2_h.execute();			
		join_none
	endtask : execute

endclass : atlas


module mailbox_test();

	atlas atlas_h;

	initial begin
		atlas_h = new();
		atlas_h.execute();
	end

endmodule