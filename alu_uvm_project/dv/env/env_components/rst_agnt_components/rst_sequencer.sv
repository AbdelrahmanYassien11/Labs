class rst_sequencer extends uvm_sequencer#(rst_seq_item);

  `uvm_component_utils(rst_sequencer) 
  
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
  endfunction : build_phase

endclass : rst_sequencer