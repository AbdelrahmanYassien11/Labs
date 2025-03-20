class alu_agent extends uvm_agent;
  //register within the factory
  `uvm_component_utils(alu_agent)

  //port_list type used for get_provided_to and get_connected_to
  uvm_port_list list;

  //---------------------------------------
  // component instances
  //---------------------------------------
  alu_driver        driver_h;
  alu_sequencer     sequencer_h;
  alu_monitor_in    monitor_in_h;
  alu_monitor_out   monitor_out_h;

  // Virtual ALU interface handle  
  virtual alu_if vif;
  alu_agent_config alu_agnt_cfg;
  
  //---------------------------------------
  // Declare TLM component for reset
  //---------------------------------------
  uvm_analysis_export #(rst_seq_item) reset_collected_export_n;
  uvm_analysis_export #(rst_seq_item) reset_collected_export_p;

  uvm_analysis_port #(alu_seq_item) inputMon2agent;
  uvm_analysis_port #(alu_seq_item) outputMon2agent;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //setter and getter for alu interface
    if(!uvm_config_db#(alu_agent_config)::get(this, "", "alu_agnt_cfg", alu_agnt_cfg))
      `uvm_fatal("NOVIF",{"agent config must be set for: ",get_full_name()});
    
    is_active = alu_agnt_cfg.get_is_active();
    uvm_config_db#(virtual alu_if)::set(this,"driver_h","vif",alu_agnt_cfg.alu_agent_config_my_vif);
    uvm_config_db#(virtual alu_if)::set(this,"monitor_in_h","vif",alu_agnt_cfg.alu_agent_config_my_vif);
    uvm_config_db#(virtual alu_if)::set(this,"monitor_out_h","vif",alu_agnt_cfg.alu_agent_config_my_vif);
   
    reset_collected_export_n = new ("reset_collected_export_n",this); 
    reset_collected_export_p = new ("reset_collected_export_p",this);

    inputMon2agent  = new("inputMon2agent", this);
    outputMon2agent = new("outputMon2agent", this);

    monitor_in_h  = alu_monitor_in::type_id::create("monitor_in_h", this);
    monitor_out_h = alu_monitor_out::type_id::create("monitor_out_h", this);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver_h    = alu_driver::type_id::create("driver_h", this);
      sequencer_h = alu_sequencer::type_id::create("sequencer_h", this);
    end
  endfunction : build_phase

  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    monitor_in_h.item_collected_port_in.connect(inputMon2agent);
    monitor_out_h.item_collected_port_out.connect(outputMon2agent);

    reset_collected_export_n.connect(sequencer_h.resetflag_imp);
    reset_collected_export_n.connect(driver_h.reset_collected_imp_n);// driver
    reset_collected_export_n.connect(monitor_in_h.reset_collected_imp_n);// mon_in
    reset_collected_export_n.connect(monitor_out_h.reset_collected_imp_n);// mon_out

    reset_collected_export_p.connect(driver_h.reset_collected_imp_p);// driver
    reset_collected_export_p.connect(monitor_in_h.reset_collected_imp_p);// mon_in
    reset_collected_export_p.connect(monitor_out_h.reset_collected_imp_p);// mon_out

    if(get_is_active() == UVM_ACTIVE) begin
      driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
    end
  endfunction : connect_phase
  
endclass : alu_agent