class rst_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual rst_if r_vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(rst_seq_item) reset_collected_port_n;
  uvm_analysis_port #(rst_seq_item) reset_collected_port_p;

  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  rst_seq_item  reset_collected;

  `uvm_component_utils(rst_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    reset_collected_port_n = new("reset_collected_port_n", this);
    reset_collected_port_p = new("reset_collected_port_p", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual rst_if)::get(this, "", "r_vif", r_vif))
      `uvm_fatal("NOVIF",{"reset virtual interface must be set for: ",get_full_name(),".r_vif"});
    reset_collected = rst_seq_item::type_id::create("reset_collected",this);
  endfunction: build_phase

  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    start_monitoring();
  endtask : run_phase

  //---------------------------------------
  // start_monitoring_in: responsible for monitoring
  //---------------------------------------  
  task start_monitoring;
    `uvm_info(get_full_name(), $sformatf("INITIAL RESET Monitor :\n %s", reset_collected.sprint), UVM_HIGH)
    forever begin
      fork
        begin
          @(negedge r_vif.rst_n);
          reset_collected.reset_n = r_vif.rst_n;
          `uvm_info(get_full_name(), $sformatf("-ve ResetMonitor :\n %s", reset_collected.sprint), UVM_LOW)
          reset_collected_port_n.write(reset_collected);
        end
        begin
          @(posedge r_vif.rst_n);
          `uvm_info(get_full_name(), $sformatf("+ve ResetMonitor :\n %s", reset_collected.sprint), UVM_LOW)
          reset_collected_port_p.write(reset_collected);
        end
      join
    end  
  endtask : start_monitoring

endclass : rst_monitor
