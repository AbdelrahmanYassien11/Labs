`uvm_analysis_imp_decl(_reset)
class alu_sequencer extends uvm_sequencer#(alu_seq_item);

  `uvm_component_utils(alu_sequencer) 
  
  rst_seq_item rst_seq_item_h;
  uvm_analysis_imp_reset #(rst_seq_item, alu_sequencer) resetflag_imp;
  

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Construct TLM component
    resetflag_imp = new("resetflag_imp", this);
    // Construct reset seq 
    rst_seq_item_h = rst_seq_item::type_id::create("rst_seq_item_h");
  endfunction : build_phase

  virtual function void write_reset(rst_seq_item t);
    `uvm_info(get_full_name(), "stop sequences called", UVM_LOW)
    stop_sequences();
  endfunction : write_reset


endclass

