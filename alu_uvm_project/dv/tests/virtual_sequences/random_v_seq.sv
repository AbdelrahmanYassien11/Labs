class random_v_seq extends base_v_seq;
  alu_sequence   alu_seq;  

  `uvm_object_utils(random_v_seq)

  function new (string name = "random_v_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "random_v_seq: Inside Body", UVM_LOW);
    do begin
      rst_seq = reset_sequence::type_id::create("rst_seq");
      alu_seq = alu_sequence::type_id::create("alu_seq");
      fork
        begin
          rst_seq.start(p_sequencer.seqr_RST);
          `uvm_info(get_name, $sformatf("seqr_RST Arbitration mode = %s", seqr_RST.get_arbitration()), UVM_LOW)
        end
        begin
        alu_seq.start(p_sequencer.seqr_ALU);
        end
        begin
           #test_timeout;
          `uvm_info(get_name,("TIME OUT!!"), UVM_LOW)
          alu_seq_item::cov_target=1;
          rst_seq_item::resets_done=1;
        end
      join_any
            disable fork;
    end while ((!alu_seq_item::cov_target) || (!rst_seq_item::resets_done));
  endtask

endclass