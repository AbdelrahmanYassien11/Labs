//---------------------------------------
// Extended sequence for directed testing of Set A operations
//---------------------------------------
class alu_op_a_repi_sequence extends alu_sequence;
  
  `uvm_object_utils(alu_op_a_repi_sequence)
  
  function new(string name = "alu_op_a_repi_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    forever begin
      req = alu_seq_item::type_id::create("req");
      `uvm_info(get_name, "seq op a ", UVM_LOW)
      if(!req.randomize() with { 
        ALU_en == 1; 
        a_en == 1; 
        b_en == 0;
        a_op dist {[A_ADD:A_XNOR]:= 1};
      }) `uvm_error(get_type_name(), "Randomization failed")

        repeat(10) begin
//         if(!req.A.randomize())`uvm_error(get_type_name(), "Randomization failed")
//         if(!req.B.randomize())`uvm_error(get_type_name(), "Randomization failed")
        start_item(req);
        finish_item(req);
      end

      if(alu_seq_item::a_op_cov_repi_trgt && rst_seq_item::resets_done) break;
      					
    end
  endtask
  
endclass: alu_op_a_repi_sequence

class alu_op_b01_repi_sequence extends alu_sequence;
  
  `uvm_object_utils(alu_op_b01_repi_sequence)
  
  function new(string name = "alu_op_b01_repi_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    forever begin
      req = alu_seq_item::type_id::create("req");
      `uvm_info(get_name, "seq op b01 ", UVM_LOW)
      if(!req.randomize() with { 
        ALU_en == 1; 
        a_en == 0; 
        b_en == 1;
        b_op dist {[B01_NAND:B01_ADD2] := 1};
      }) `uvm_error(get_type_name(), "Randomization failed")

        repeat(10) begin
//         if(!req.A.randomize())`uvm_error(get_type_name(), "Randomization failed")
//         if(!req.B.randomize())`uvm_error(get_type_name(), "Randomization failed")
        start_item(req);
        finish_item(req);
      end

      if(alu_seq_item::b_op01_cov_repi_trgt && rst_seq_item::resets_done) break;
    end
  endtask
  
endclass: alu_op_b01_repi_sequence

class alu_op_b11_repi_sequence extends alu_sequence;
  
  `uvm_object_utils(alu_op_b11_repi_sequence)
  
  function new(string name = "alu_op_b11_repi_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    forever begin
      req = alu_seq_item::type_id::create("req");
      `uvm_info(get_name, "seq op b11 ", UVM_LOW)
      if(!req.randomize() with { 
        ALU_en == 1; 
        a_en == 1; 
        b_en == 1;
        b_op dist {[B11_XOR:B11_B_ADD_2] := 1};
      }) `uvm_error(get_type_name(), "Randomization failed")

        repeat(10) begin
//         if(!req.A.randomize())`uvm_error(get_type_name(), "Randomization failed")
//         if(!req.B.randomize())`uvm_error(get_type_name(), "Randomization failed")
        start_item(req);
        finish_item(req);
      end

      if(alu_seq_item::b_op11_cov_repi_trgt && rst_seq_item::resets_done) break;
    end
  endtask
  
endclass: alu_op_b11_repi_sequence