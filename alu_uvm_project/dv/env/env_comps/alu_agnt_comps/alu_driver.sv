`define DRIVER_IF vif.DRIVER.driver_cb

class alu_driver extends uvm_driver #(alu_seq_item);
`uvm_analysis_imp_decl(_rst_n)
`uvm_analysis_imp_decl(_rst_p)
  
  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual alu_if vif;

  int driven_pkts;
  local bit reset_detection;
  local bit reset_deassertion;
  rst_seq_item rst_seq_item_h;

  `uvm_component_utils(alu_driver)

  //--------------------------------------- 
  // Declare TLM component for the reset
  //--------------------------------------- 
  uvm_analysis_imp_rst_n #(rst_seq_item, alu_driver) reset_collected_imp_n;
  uvm_analysis_imp_rst_p #(rst_seq_item, alu_driver) reset_collected_imp_p;

  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset_collected_imp_n = new ("reset_collected_imp_n",this);
    reset_collected_imp_p = new ("reset_collected_imp_p",this);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    rst_seq_item_h = rst_seq_item::type_id::create("rst_seq_item_h");

  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    //---------------------------------------
    //Wait for reset de-assertion
    //---------------------------------------   
    @(posedge reset_deassertion); // first reset obologatry 
    `uvm_info(get_full_name(), $sformatf("first reset detect :\n"), UVM_HIGH)
    while(1) begin
      fork
        begin
          @(posedge reset_detection);
          reset_deassertion = 0;
        end
        begin
          drive();
        end

      join_any
            disable fork;
      @(posedge reset_deassertion);
      reset_detection = 0;
    end
  endtask : run_phase

  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_full_name(), $sformatf("Driver :\n %s", req.sprint), UVM_HIGH)
      @(negedge vif.DRIVER.clk);
      `DRIVER_IF.ALU_en <= req.ALU_en;
      `DRIVER_IF.a_en   <= req.a_en;
      `DRIVER_IF.b_en   <= req.b_en;
      `DRIVER_IF.a_op   <= req.a_op;
      `DRIVER_IF.b_op   <= req.b_op;
      `DRIVER_IF.A      <= req.A;
      `DRIVER_IF.B      <= req.B;
      driven_pkts++;
      // Wait for posedge where result becomes available
      @(posedge vif.DRIVER.clk);
      // Wait for full idle cycle to complete
      @(posedge vif.DRIVER.clk);
      seq_item_port.item_done();
    end
  endtask : drive

  //---------------------------------------
  // Report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), 
              $sformatf("\nALU driver Report:\n\tTotal driven_pkts: %0d",driven_pkts), UVM_LOW)

    `uvm_info(get_type_name(), "ALU Driver Report Phase Complete", UVM_LOW)
  endfunction : report_phase

  function void write_rst_n(rst_seq_item t);
    reset_detection = 1;
  endfunction
              
  function void write_rst_p(rst_seq_item t);
    reset_deassertion = 1;
  endfunction


endclass : alu_driver