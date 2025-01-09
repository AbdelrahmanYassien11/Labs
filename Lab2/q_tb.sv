class queue_controller;

	local int queue_c [$];

	function void new(int element);
		queue_c.push_back(element);
	endfunction 

	function void push_front_q(int element);
		if(quque_c.push_front(element))
		 	$display("POP_BACK");
	endfunction :push_front_q

	function int pop_front_q ();
		return queue_c.pop_front();
	endfunction :pop_front_q

	function void push_back_q (int element);
		 if(queue_c.push_back(element))
		 	$display("PUSHED_BACK");
	endfunction :push_back_q

	function int pop_back_q ();
		return queue_c.pop_back();
	endfunction :pop_back_q

	function int q_num();
		return queue_c.num();
	endfunction : q_num

	function void q_insert(int index, element);
		if(quque_c.size() >= index+1) begin
			queue_c.insert(index, element);
			$display("SUCCESSFUL INSERTION");
		end
		else begin
			$display("THE INDEX YOU SENT IS INVALID, THE CURRENT QUEUE SIZE IS: %0d",quque_c.size());
		end
	endfunction : q_insert 
endclass

module q_tb();

	bit clk;

	always #1 clk = ~clk;

	queue_controller q;

	initial begin
		q = new(5);
		@(posedge clk);
		$display("FIRST ELEMENT: %0d",q.pop_front_q());
		q.push_back_c(9);
		@(posedge clk);
		$display("SECOND ELEMENT: %0d",q.pop_back_c());
		@(posedge clk);
		q.push_front_c(8);
		q.push_front_c(7);
		q.push_front_c(6);
		$display("m3rfsh bgd");
		$display("%0d",q.q_num());
		q.q_insert(0,5);
	end

endmodule


