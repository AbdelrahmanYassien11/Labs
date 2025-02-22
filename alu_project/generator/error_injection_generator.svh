class error_injection_generator#(type T = int) extends reset_generator#(T);

	T generated_item;
	function new(virtual alu_f v_inf, mailbox #(T) generator_to_driver, event finished_driving);
		super.new(v_inf, generator_to_driver, finished_driving);
		generated_item = new();
	endfunction

	virtual task execute();
		super.execute();
		@(finished_driving);
		assert(generated_item.randomize());
		generated_item.NO_OF_ITEMS.rand_mode(0);
		T::NO_OF_ITEMS_ST = generated_item.NO_OF_ITEMS;
		repeat(T::NO_OF_ITEMS_ST) begin
			generated_item = new();
		 	generated_item.op_c.constraint_mode(0);
		 	generated_item.A_c.constraint_mode(0);
		 	generated_item.B_c.constraint_mode(0);
		 	assert(generated_item.randomize() with { 
		 		A dist {[-16:15]:=1};
		 		B dist {[-16:15]:=1};
		 		if 		({a_en, ~b_en}) {a_op dist {[0:7]:=1};}
		 		else if ({a_en,  b_en}) {b_op dist {[0:3]:=1};}
		 		else if ({~a_en, b_en}) {b_op dist {[0:3]:=1};}});
		 	generator_to_driver.put(generated_item);
		 	$display("[SEQUENCE]: GENERATED_ITEM: %s",generated_item.input2string());
		 	@(finished_driving);
		end
	 endtask : execute

endclass