class base_test extends uvm_test;
  
  
  // Virtual ALU interface handle  
  virtual alu_if vif;
  virtual rst_if r_vif;
  test_config test_cfg;
  env_config env_cfg;
  
  // Environment instance
  env env_h;
  base_v_seq v_seq;
  
  // Register with factory
  `uvm_component_utils(base_test)
  
  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env_h = env::type_id::create("env_h", this);

    // Set verbosity level
    uvm_top.set_report_verbosity_level(UVM_MEDIUM);

    uvm_config_db#(string)::set(this,"*","test_name",get_type_name());

    //setter and getter for rst interface    
    if(!uvm_config_db#(test_config)::get(this, "", "test_cfg", test_cfg))
      `uvm_fatal("NOVIF",{"Couldn't get TEST CONFIG: ",get_full_name()});

    // Create and set environment configuration
    env_cfg = env_config::type_id::create("env_cfg");
    env_cfg.initialize(test_cfg.test_cfg_vif, test_cfg.test_cfg_r_vif, 
                       test_cfg.alu_get_is_active(), test_cfg.rst_get_is_active());

    uvm_config_db#(env_config)::set(this,"env_h","env_cfg",env_cfg);

    // Configure reset count
    rst_seq_item::no_of_resets = test_cfg.no_of_resets;

  endfunction : build_phase

  //---------------------------------------
  // Arbitration mode method
  //---------------------------------------
  
  virtual task cfg_arb_mode;
  endtask

  //---------------------------------------
  // End of elaboration phase
  //---------------------------------------
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    
    // Print the topology
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase
  
  //---------------------------------------
  // Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);
//     v_seq 	= base_v_seq::type_id::create("v_seq", this);
    super.run_phase(phase);
     v_seq.test_timeout = test_cfg.test_timeout;
    // Raise objection to keep the test from completing
    phase.raise_objection(this);
    cfg_arb_mode();
    `uvm_info(get_name, $sformatf("Arbitration mode for ALU SQR = %s", env_h.alu_agent_h.sequencer_h.get_arbitration()), UVM_LOW);
    `uvm_info(get_name, $sformatf("Arbitration mode for RST SQR = %s", env_h.rst_agent_h.sequencer_h.get_arbitration()), UVM_LOW);

    //v_seq.start(null); //virtual sequences can be started on NULL/no sequencer
    v_seq.start(env_h.v_seqr);
    
    `uvm_info(get_type_name(), "Base test started", UVM_HIGH)
        
    `uvm_info(get_type_name(), "Base test completed", UVM_MEDIUM)
   
    // Drop objection to allow the test to complete :(
    phase.drop_objection(this);
  endtask : run_phase
  
  //---------------------------------------
  // Report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    uvm_report_server server = uvm_report_server::get_server();
    
    if (server.get_severity_count(UVM_FATAL) + 
        server.get_severity_count(UVM_ERROR) == 0)
      `uvm_info(get_type_name(), "TEST PASSED", UVM_LOW)
    else
      `uvm_info(get_type_name(), "TEST FAILED", UVM_LOW)
  endfunction : report_phase
  
endclass : base_test