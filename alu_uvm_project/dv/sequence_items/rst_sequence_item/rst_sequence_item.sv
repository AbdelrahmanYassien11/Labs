class rst_seq_item extends uvm_sequence_item;

  bit reset_n;
  rand bit reset_on;
  static int unsigned no_of_resets;
  static bit unsigned resets_done;

  //---------------------------------------
  // Reset Metadata
  //---------------------------------------
  local static int  unsigned pkt_ID_RST; 
  rand  	  	 time 			   reset_duation;
  time 			                 start_reset;
  time			                 end_reset;
  static       int  unsigned reset_count;
  rand			 	 time			     reset_delay;

  //---------------------------------------
  // Randomization Constraints
  //---------------------------------------    
  constraint reset_power 		     { reset_on dist {1 := 20, 0 := 80} ;} // active low reset
  
  constraint reset_time 		     { reset_duation inside {[100:150]};} // reset duration inside 200:500 ns
  constraint time_between_reset  { reset_delay   inside {[200:500]}  ;} // time between resets inside 200:500 ns
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(rst_seq_item)
  `uvm_field_int(pkt_ID_RST,UVM_ALL_ON | UVM_DEC)
  `uvm_field_int(reset_n,UVM_ALL_ON)
  `uvm_field_int(reset_on,UVM_ALL_ON)
  `uvm_field_int(start_reset,UVM_ALL_ON | UVM_DEC)
  `uvm_field_int(end_reset,UVM_ALL_ON | UVM_DEC)
  `uvm_field_int(reset_duation,UVM_ALL_ON | UVM_DEC)
  `uvm_field_int(reset_delay,UVM_ALL_ON | UVM_DEC)
  `uvm_field_int(reset_count,UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end

  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "rst_seq_item");
    super.new(name);
    reset_n = 1;
  endfunction

  //---------------------------------------
  //Constructor
  //---------------------------------------
  function void post_randomize();
    pkt_ID_RST++;
    if (reset_on)  begin
      start_reset = $time;
      end_reset   = start_reset + reset_duation;
    end
  endfunction


endclass