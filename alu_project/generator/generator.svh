class generator#(type T = int) extends generator_base#(T);

	T generated_item;
	function new(virtual alu_f v_inf, mailbox #(T) generator_to_driver, event finished_driving);
		super.new(v_inf, generator_to_driver, finished_driving);
		generated_item = new();
	endfunction

	virtual task execute();
		reset_item();
		@(finished_driving);
		assert(generated_item.randomize());
		generated_item.NO_OF_ITEMS.rand_mode(0);
		T::NO_OF_ITEMS_ST = generated_item.NO_OF_ITEMS;
		repeat(T::NO_OF_ITEMS_ST) begin
			generated_item = new();
		 	assert(generated_item.randomize());
		 	generator_to_driver.put(generated_item);
		 	$display("[SEQUENCE]: GENERATED_ITEM: %s",generated_item.input2string());
		 	@(finished_driving);
		end
	 endtask : execute


	virtual task reset_item();
		generated_item.rst_n = 0;
		generator_to_driver.put(generated_item);
		$display("[SEQUENCE]: GENERATED_ITEM: %s",generated_item.input2string());
	endtask : reset_item


endclass
