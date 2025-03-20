class rst_driver extends uvm_driver #(rst_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual rst_if r_vif;
  `uvm_component_utils(rst_driver)

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
    //setter and getter for rst virtual interface    
    if(!uvm_config_db#(virtual rst_if)::get(this, "", "r_vif", r_vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".r_vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    //     @(posedge vif.rst_n);
    forever
      begin
        seq_item_port.get_next_item(req);
        `uvm_info(get_full_name(), $sformatf("Generaged Reset_Item :\n %s", req.sprint), UVM_HIGH)
        if(req.reset_on) begin
          if (rst_seq_item::reset_count < rst_seq_item::no_of_resets) begin
            rst_seq_item::reset_count = rst_seq_item::reset_count + 1;
            `uvm_info(get_type_name(),"RESET SEQUENCE INITIATED",UVM_HIGH)   
            r_vif.reset(req.reset_duation);
          end
          else begin
            rst_seq_item::resets_done = 1;
            $display ("resets_done asserted");
          end
          @(posedge r_vif.rst_n);
          //           req.end_reset = $time;
          seq_item_port.item_done();
          $display("reset_count: %0d", rst_seq_item::reset_count);
        end
        else begin
          #req.reset_delay;
          `uvm_info(get_type_name(),"RESET DELAY ON",UVM_HIGH)   
          seq_item_port.item_done();
        end
      end
  endtask : run_phase

  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
  endtask : drive

  //---------------------------------------
  // Report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), 
              $sformatf("\nReset Driver Report:\n\tTotal Resets: %0d",rst_seq_item::reset_count), UVM_LOW)

    `uvm_info(get_type_name(), "Reset Driver Report Phase Complete", UVM_LOW)
  endfunction : report_phase


endclass : rst_driver