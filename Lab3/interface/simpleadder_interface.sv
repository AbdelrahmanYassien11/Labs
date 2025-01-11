interface simpleadder_if(input bit clk);

	bit en_i;
	bit in_a;
	bit in_b;
	logic en_o;
	logic out;

	bit addition_initiated;

	event finish_the_test;
	event item_put_in_driver;
	event wait_till_item_driven;

	int correct_checks, incorrect_checks;

endinterface : simpleadder_if