class generator;

	virtual alu_f v_inf;
	mailbox #(transaction) generator_to_driver;
	transaction generated_item;
	event finished_driving;

	function new(virtual alu_f v_inf, mailbox #(transaction) generator_to_driver, event finished_driving);
		this.v_inf = v_inf;
		this.generator_to_driver = generator_to_driver;
		generated_item = new();
		this.finished_driving = finished_driving;
	endfunction

	virtual task execute();
		assert(generated_item.randomize());
		generated_item.NO_OF_ITEMS.rand_mode(0);
		transaction::NO_OF_ITEMS_ST = generated_item.NO_OF_ITEMS;
		repeat(generated_item.NO_OF_ITEMS) begin
		 	assert(generated_item.randomize());
		 	generator_to_driver.put(generated_item);
		 	$display("[SEQUENCE]: GENERATED_ITEM: %s",generated_item.input2string());
		 	@(finished_driving);
		end
	 endtask : execute




endclass