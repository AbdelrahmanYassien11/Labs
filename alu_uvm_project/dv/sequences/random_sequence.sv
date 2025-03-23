class alu_sequence extends uvm_sequence #(alu_seq_item);
  
  // Register with factory
  `uvm_object_utils(alu_sequence)
  
  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "alu_sequence");
    super.new(name);
  endfunction
  
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
        
    forever begin
    req = alu_seq_item::type_id::create("req");
      start_item(req);
      
      if(!req.randomize())
        `uvm_error(get_type_name(), "Randomization failed")
      
      finish_item(req);
      
      if(alu_seq_item::cov_target && rst_seq_item::resets_done) break;
    end
  endtask
  
endclass: alu_sequence

//---------------------------------------
// Extended sequence for negative test cases
//---------------------------------------
class alu_negative_sequence extends alu_sequence;
  
  `uvm_object_utils(alu_negative_sequence)
  
  function new(string name = "alu_negative_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    // Test ALU disabled
    repeat(5) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      
      if(!req.randomize() with { 
        ALU_en == 0; 
      })
        `uvm_error(get_type_name(), "Randomization failed")
      
      finish_item(req);
    end
    
    // Test invalid mode (ALU enabled but no operation set enabled)
    repeat(5) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      
      if(!req.randomize() with { 
        ALU_en == 1; 
        a_en == 0; 
        b_en == 0;
      })
        `uvm_error(get_type_name(), "Randomization failed")
      
      finish_item(req);
    end
    
    // Test null operations
    repeat(5) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      
      if(!req.randomize() with { 
        ALU_en == 1; 
        a_en == 1; 
        b_en == 0;
        a_op == A_NULL; 
      })
        `uvm_error(get_type_name(), "Randomization failed")
      
      finish_item(req);
    end
  endtask
  
endclass: alu_negative_sequence