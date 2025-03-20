class repi_v_seq extends base_v_seq;
  alu_op_a_repi_sequence      op_a_seq_h;  
  alu_op_b01_repi_sequence    op_b01_seq_h;
  alu_op_b11_repi_sequence    op_b11_seq_h;
  `uvm_object_utils(repi_v_seq)

  function new (string name = "repi_v_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "repi_v_seq: Inside Body", UVM_LOW)
    do begin
      rst_seq = reset_sequence::type_id::create("rst_seq");
      op_a_seq_h = alu_op_a_repi_sequence::type_id::create("op_a_seq_h");
      op_b01_seq_h = alu_op_b01_repi_sequence::type_id::create("op_b01_seq_h");
      op_b11_seq_h = alu_op_b11_repi_sequence::type_id::create("op_b11_seq_h");
      fork
        begin
          rst_seq.start(p_sequencer.seqr_RST);
          `uvm_info(get_name, $sformatf("seqr_RST Arbitration mode = %s", seqr_RST.get_arbitration()), UVM_LOW)
        end
        begin
          fork 
            begin
            op_a_seq_h.start(p_sequencer.seqr_ALU  , .this_priority(100));
            op_b01_seq_h.start(p_sequencer.seqr_ALU , .this_priority(200));
            op_b11_seq_h.start(p_sequencer.seqr_ALU , .this_priority(300));
            end
            // op_a_seq_h.start(p_sequencer.seqr_ALU  , .this_priority(100));
            // op_b01_seq_h.start(p_sequencer.seqr_ALU , .this_priority(200));
            // op_b11_seq_h.start(p_sequencer.seqr_ALU , .this_priority(300));
          join
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