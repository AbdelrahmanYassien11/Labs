//-------------------------------------------------------------------------
//						env
//-------------------------------------------------------------------------
class env extends uvm_env;

  // Register within factory
  `uvm_component_utils(env)

  // Virtual ALU interface handle  
  virtual alu_if vif;
  
  // Virtual rst interface handle  
  virtual rst_if r_vif;
  
  env_config env_cfg;
  
  rst_agent_config rst_agnt_cfg;
  alu_agent_config alu_agnt_cfg;
  
  // Component instances
  rst_agent         rst_agent_h;
  alu_agent         alu_agent_h;
  virtual_sequencer v_seqr;
  scoreboard        scb_h;
  subscriber        sub_h;
  uvm_port_list     list;
  uvm_analysis_port #(rst_seq_item) reset_collected_port_n;
  uvm_analysis_port #(rst_seq_item) reset_collected_port_p;

  uvm_analysis_port #(alu_seq_item) alu_in_env_ap;
  uvm_analysis_port #(alu_seq_item) alu_out_env_ap;

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create Reset Agent Component and TLM Component
    reset_collected_port_n = new("reset_collected_port_n", this);
    reset_collected_port_p = new("reset_collected_port_p", this);
    alu_in_env_ap   = new("alu_in_env_ap", this);
    alu_out_env_ap  = new("alu_out_env_ap", this);

    // Create components
    v_seqr        = virtual_sequencer::type_id::create("v_seqr", this);
    rst_agent_h   = rst_agent::type_id::create("rst_agent_h", this);    
    alu_agent_h   = alu_agent::type_id::create("alu_agent_h", this);
    scb_h         = scoreboard::type_id::create("scb_h", this);
    sub_h         = subscriber::type_id::create("sub_h", this);

    // Get environment configuration
    if(!uvm_config_db#(env_config)::get(this, "", "env_cfg", env_cfg))
      `uvm_fatal("NOVIF",{"env_config must be set for: ",get_full_name()});

    // Create and configure agent configurations
    rst_agnt_cfg = rst_agent_config::type_id::create("rst_agnt_cfg");
    alu_agnt_cfg = alu_agent_config::type_id::create("alu_agnt_cfg");

    rst_agnt_cfg.initialize(env_cfg.env_config_my_r_vif, env_cfg.rst_get_is_active());
    alu_agnt_cfg.initialize(env_cfg.env_config_my_vif, env_cfg.alu_get_is_active());

    // Set agent configurations in config DB
    uvm_config_db#(alu_agent_config)::set(this,"alu_agent_h","alu_agnt_cfg",alu_agnt_cfg);
    uvm_config_db#(rst_agent_config)::set(this,"rst_agent_h","rst_agnt_cfg",rst_agnt_cfg);
  endfunction : build_phase

  //---------------------------------------
  // Connect phase
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);



    // Connect alu agent to env TLM
    alu_agent_h.inputMon2agent.connect(alu_in_env_ap);
    alu_agent_h.outputMon2agent.connect(alu_out_env_ap);

    // Connect env to scoreboard
    alu_in_env_ap.connect(scb_h.analysis_export_inputs);
    alu_out_env_ap.connect(scb_h.analysis_export_actual_outputs);

    // Connect env to subscriber
    alu_in_env_ap.connect(sub_h.analysis_export_inputs);
    alu_out_env_ap.connect(sub_h.analysis_export_outputs);

/******************************************************************************************************/    

    // Connect reset agent to env
    rst_agent_h.reset_collected_port_n.connect(reset_collected_port_n); // reset_agent_to_env
    rst_agent_h.reset_collected_port_p.connect(reset_collected_port_p); // reset_agent_to_env

    // Connect env to alu agent
    reset_collected_port_n.connect(alu_agent_h.reset_collected_export_n);
    reset_collected_port_p.connect(alu_agent_h.reset_collected_export_p);

    // Connect reset to alu agent    
    reset_collected_port_n.connect(scb_h.reset_collected_export); // scoreboard we may send posedge rst later
    reset_collected_port_n.connect(sub_h.reset_collected_export); // subscriber we may send posedge rst later

/******************************************************************************************************/  
    // sequencers connection
    v_seqr.seqr_ALU = alu_agent_h.sequencer_h;
    v_seqr.seqr_RST = rst_agent_h.sequencer_h;


  endfunction : connect_phase

  //---------------------------------------
  // End of elaboration phase -  for reporting connection details
  //---------------------------------------  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // Set verbosity level for the scoreboard
    // scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);

//     // Log connections and provided ports/exports
//     alu_agnt.driver.reset_collected_imp.get_provided_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);

//     alu_agnt.driver.reset_collected_imp.get_connected_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);

//     alu_reset_agnt.monitor.reset_collected_port.get_provided_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);

//     alu_reset_agnt.monitor.reset_collected_port.get_connected_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);

//     alu_reset_agnt.reset_collected_port.get_provided_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);

//     alu_reset_agnt.reset_collected_port.get_connected_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);

//     alu_agnt.reset_collected_export.get_provided_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);

//     alu_agnt.reset_collected_export.get_connected_to(list);
//     `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);


    $display("ENV end_of_elaboration_phase");
  endfunction


  //---------------------------------------
  // Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase

  //---------------------------------------
  // Report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "Environment Report Complete", UVM_LOW)
  endfunction : report_phase




endclass : env

