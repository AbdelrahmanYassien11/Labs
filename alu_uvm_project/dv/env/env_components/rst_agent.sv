class rst_agent extends uvm_agent;
  
  //registiration within factory
  `uvm_component_utils(rst_agent)
  
  // Virtual rst interface handle  
  virtual rst_if r_vif;
  rst_agent_config rst_agnt_cfg;
  
  //---------------------------------------
  // component instances
  //---------------------------------------
  rst_driver        driver_h;
  rst_sequencer     sequencer_h;
  rst_monitor       monitor_h;

  //---------------------------------------
  // Construct TLM Component
  //---------------------------------------
  uvm_analysis_port #(rst_seq_item) reset_collected_port_p;
  uvm_analysis_port #(rst_seq_item) reset_collected_port_n;


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

    //setter and getter for rst interface    
    if(!uvm_config_db#(rst_agent_config)::get(this, "", "rst_agnt_cfg", rst_agnt_cfg))
      `uvm_fatal("NOVIF",{"failed to get agent config: ",get_full_name()});
	
    this.is_active = rst_agnt_cfg.get_is_active(); 
    uvm_config_db#(virtual rst_if)::set(this,"driver_h","r_vif",rst_agnt_cfg.rst_agent_config_my_r_vif);
    uvm_config_db#(virtual rst_if)::set(this,"monitor_h","r_vif",rst_agnt_cfg.rst_agent_config_my_r_vif);
  
    reset_collected_port_p = new ("reset_collected_port_p",this);
    reset_collected_port_n = new ("reset_collected_port_n",this);

    monitor_h	= rst_monitor::type_id::create("monitor_h", this);

    //     creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver_h    = rst_driver::type_id::create("driver_h", this);
      sequencer_h = rst_sequencer::type_id::create("sequencer_h", this);
    end
  endfunction : build_phase

  //   ---------------------------------------  
  //   connect_phase - connecting the driver and sequencer port
  //   ---------------------------------------
  function void connect_phase(uvm_phase phase);
    monitor_h.reset_collected_port_n.connect(reset_collected_port_n);
    monitor_h.reset_collected_port_p.connect(reset_collected_port_p);
    if(get_is_active() == UVM_ACTIVE) begin
      driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
    end
  endfunction : connect_phase

endclass : rst_agent