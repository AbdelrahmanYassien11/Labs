virtual class driver_base#(type T = int);
	protected virtual alu_f v_inf;
	protected mailbox #(T) generator_to_driver;

	event finished_driving;

	function new(virtual alu_f v_inf, mailbox#(T) generator_to_driver, event finished_driving);
		this.v_inf = v_inf;
		this.generator_to_driver = generator_to_driver;
		this.finished_driving = finished_driving;
	endfunction 

	pure virtual task execute;

	//pure virtual function drive_item;
	
endclass : driver_base