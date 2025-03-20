class virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(virtual_sequencer)
  alu_sequencer		  seqr_ALU;
  rst_sequencer 	  seqr_RST;

  function new(string name = "virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass 