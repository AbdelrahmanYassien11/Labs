//---------------------------------------
// Random test - basic test with random operations
//---------------------------------------
class repitition_test extends base_test;

  // Register with factory
  `uvm_component_utils(repitition_test)


  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "repitition_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // override virtual sequence
    //alu_reset_seq_item::no_of_resets = 3;
	base_v_seq::type_id::set_type_override(repi_v_seq::type_id::get());
    v_seq 	= base_v_seq::type_id::create("v_seq", this);
  endfunction : build_phase

  //---------------------------------------
  // Set Arbitration mode
  //---------------------------------------
  task cfg_arb_mode;
    /*
Arbitration modes
1. UVM_SEQ_ARB_FIFO
2. UVM_SEQ_ARB_WEIGHTED
3. UVM_SEQ_ARB_RANDOM
4. UVM_SEQ_ARB_STRICT_FIFO
5. UVM_SEQ_ARB_STRICT_RANDOM
6. UVM_SEQ_ARB_USER
*/
	//env_h.alu_agnt.sequencer.set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);
  endtask

endclass : repitition_test