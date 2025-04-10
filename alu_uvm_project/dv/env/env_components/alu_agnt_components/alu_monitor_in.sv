`define MONITOR_IF vif.MONITOR.monitor_cb

class alu_monitor_in extends uvm_monitor;

`uvm_analysis_imp_decl(_rst_n)
`uvm_analysis_imp_decl(_rst_p)
  
  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual alu_if vif;
  local bit reset_detection;
  local bit reset_deassertion;
  local int mon_pkts;

  //--------------------------------------- 
  // Declare TLM component for the reset
  //--------------------------------------- 
  uvm_analysis_imp_rst_n #(rst_seq_item, alu_monitor_in) reset_collected_imp_n;
  uvm_analysis_imp_rst_p #(rst_seq_item, alu_monitor_in) reset_collected_imp_p;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(alu_seq_item) item_collected_port_in;

  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  alu_seq_item trans_collected;

  `uvm_component_utils(alu_monitor_in)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port_in = new("item_collected_port_in", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset_collected_imp_n = new ("reset_collected_imp_n",this);
    reset_collected_imp_p = new ("reset_collected_imp_p",this);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    //Wait for reset de-assertion
    @(posedge reset_deassertion);
    while(1) begin
      fork
        start_monitoring_in();
        begin
        @(posedge reset_detection);
          reset_deassertion = 0;
        end
      join_any
            disable fork;
      @(posedge reset_deassertion);
      reset_detection = 0;
    end
  endtask : run_phase

  //---------------------------------------
  // start_monitoring_in: responsible for monitoring
  //---------------------------------------  
  task start_monitoring_in;
    forever begin
      @(posedge vif.MONITOR.clk);
      @(posedge vif.MONITOR.clk);
      trans_collected.ALU_en = `MONITOR_IF.ALU_en;
      trans_collected.a_en   = `MONITOR_IF.a_en;
      trans_collected.b_en   = `MONITOR_IF.b_en;
      trans_collected.a_op   = `MONITOR_IF.a_op;
      trans_collected.b_op   = `MONITOR_IF.b_op;
      trans_collected.A      = `MONITOR_IF.A;
      trans_collected.B      = `MONITOR_IF.B;

      trans_collected.ALU_EN_STATE_e 	= ALU_EN_STATE_t'(`MONITOR_IF.ALU_en);
      trans_collected.OP_A_e 	        = OP_A_t'(`MONITOR_IF.a_op);
      trans_collected.OP_B01_e 	      = OP_B01_t'(`MONITOR_IF.b_op);
      trans_collected.OP_B11_e 	      = OP_B11_t'(`MONITOR_IF.b_op);
      trans_collected.OP_MODE_e 	    = OP_MODE_t'({`MONITOR_IF.b_en, `MONITOR_IF.a_en});
      
      
      `uvm_info(get_full_name(), $sformatf("InputMonitor :\n %s", trans_collected.sprint), UVM_HIGH)

      item_collected_port_in.write(trans_collected); 
      mon_pkts++;
    end  
  endtask : start_monitoring_in

  function void write_rst_n(rst_seq_item t);
    reset_detection = 1;
  endfunction
              
  function void write_rst_p(rst_seq_item t);
    reset_deassertion = 1;
  endfunction

  //---------------------------------------
  // Report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), 
              $sformatf("\n Monitor_In Report:\n\tTotal Inputs_monitored_pkts: %0d",mon_pkts), UVM_LOW)

    `uvm_info(get_type_name(), "Monitor_In Report Phase Complete", UVM_LOW)
  endfunction : report_phase

endclass : alu_monitor_in
