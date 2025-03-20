//---------------------------------------
// Random test - basic test with random operations
//---------------------------------------
class error_test extends base_test;

  // Register with factory
  `uvm_component_utils(error_test)


  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "error_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // override virtual sequence
    base_v_seq::type_id::set_type_override(error_v_seq::type_id::get());
    v_seq 	= base_v_seq::type_id::create("v_seq", this);
    alu_seq_item::type_id::set_type_override(error_seq_item::type_id::get());
    
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
//	env.alu_agnt.sequencer.set_arbitration(UVM_SEQ_ARB_FIFO);
  endtask

endclass : error_test
