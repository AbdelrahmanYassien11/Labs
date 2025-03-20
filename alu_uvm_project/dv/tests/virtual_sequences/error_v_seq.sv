class error_v_seq extends base_v_seq;
  `uvm_object_utils(error_v_seq)
  error_sequence error_seq;  

  function new (string name = "error_v_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "error_v_seq: Inside Body", UVM_LOW);
    rst_seq = reset_sequence::type_id::create("rst_seq");
    fork
      begin
        rst_seq.start(p_sequencer.seqr_RST);
        `uvm_info(get_name, $sformatf("seqr_RST Arbitration mode = %s", seqr_RST.get_arbitration()), UVM_LOW);
      end
      @(posedge rst_seq_item::resets_done);
    join_any
            disable fork;
    fork
      begin
    error_seq = error_sequence::type_id::create("error_seq");
    error_seq.start(p_sequencer.seqr_ALU);
      end
      begin
        #1000;
        `uvm_info(get_name,("TIME OUT!!"), UVM_LOW)
        alu_seq_item::cov_target=1;
        rst_seq_item::resets_done=1;
      end
    join_any;

              
  endtask

endclass