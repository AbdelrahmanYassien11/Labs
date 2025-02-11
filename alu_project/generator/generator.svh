class generator();

	virtual alu_f v_inf;
	mailbox#(transaction) generator_to_driver;
	transaction generated_item;

	function void (virtual alu_f v_inf, mailbox #(transaction) generator_to_driver);
		this.v_inf = v_inf;
		this.generator_to_driver = generator_to_driver;
		generated_item = new();
	endfunction

	virtual task execute();
	 	assert(generated_item.randomize());
	 	generator_to_driver.put(generated_item);
	 	$display("GENERATED_ITEM: %s",generated_item.input2string());
	 endtask : execute




endclass