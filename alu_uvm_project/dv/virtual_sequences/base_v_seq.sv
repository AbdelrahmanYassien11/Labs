class base_v_seq extends uvm_sequence;
  reset_sequence rst_seq;
    
  alu_sequencer		  seqr_ALU;
  rst_sequencer     seqr_RST;
  test_config test_cfg;
  int test_timeout;

  `uvm_object_utils(base_v_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)

  function new (string name = "base_v_seq");
    super.new(name);
  endfunction

 virtual task body();
    `uvm_info(get_type_name(), "base_v_seq: Inside Body", UVM_LOW);
  endtask

endclass