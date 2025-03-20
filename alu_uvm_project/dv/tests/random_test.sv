//---------------------------------------
// Random test - basic test with random operations
//---------------------------------------
class random_test extends base_test;
//   test_config test_cfg;


  // Register with factory
  `uvm_component_utils(random_test)
    string plusargs_queue[$];
    uvm_cmdline_processor cmd;

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	// override virtual sequence
//     test_cfg = new(base_v_seq, random_v_seq,UVM_ACTIVE,UVM_ACTIVE);
    //alu_reset_seq_item::no_of_resets = 3;
    base_v_seq::type_id::set_type_override(random_v_seq::type_id::get());
    v_seq 	= base_v_seq::type_id::create("v_seq", this);
   
     cmd = uvm_cmdline_processor::get_inst();
 	 cmd.get_plusargs(plusargs_queue);
    `uvm_info (get_type_name(), $sformatf("PLUSARGS = %p", plusargs_queue), UVM_LOW)
//     uvm_config_db#(test_config)::set(this,"env","test_cfg",test_cfg);
  endfunction : build_phase

  //---------------------------------------
  // Set Arbitration mode
  //---------------------------------------
  task cfg_arb_mode;
	 //env_h.alu_agnt.sequencer.set_arbitration(UVM_SEQ_ARB_WEIGHTED);
  endtask

  /*---------------------------------------
  Arbitration modes
  1. UVM_SEQ_ARB_FIFO
  2. UVM_SEQ_ARB_WEIGHTED
  3. UVM_SEQ_ARB_RANDOM
  4. UVM_SEQ_ARB_STRICT_FIFO
  5. UVM_SEQ_ARB_STRICT_RANDOM
  6. UVM_SEQ_ARB_USER
  ----------------------------------------*/


endclass : random_test