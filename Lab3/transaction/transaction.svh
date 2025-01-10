class transaction;
	
	rand bit in_a, in_b;
	rand bit en_i;
	logic out, en_o;

	rand int items_to_be_generated;
	static int items_to_be_generated_compared;

	constraint no_of_generated_items {items_to_be_generated inside {[100:150]}; 
									  items_to_be_generated%2 == 0; };

endclass : transaction