class transaction;
	
	rand bit in_a, in_b;
	rand bit en_i;
	logic out, en_o;

	rand int items_to_be_generated;
	static int items_to_be_generated_compared;

	string s;

	constraint no_of_generated_items {items_to_be_generated inside {[100:150]}; 
									  items_to_be_generated%2 == 0; };


    function string input2string();
    	string s;
    	s = $sformatf("TIME: %0t, in_a = %0d, in_b = %0d, en_i = %0d", $time(), in_a, in_b, en_i);
    	return s;
    endfunction : input2string

    function string output2string();
    	string s;
    	s = $sformatf("TIME: %0t, en_o = %0d, out = %0d", $time(), en_o, out);
    	return s;
    endfunction : output2string

endclass : transaction