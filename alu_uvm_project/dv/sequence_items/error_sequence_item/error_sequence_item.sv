class error_seq_item extends alu_seq_item;

bit error_injection_enabled = 1;
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(error_seq_item)
    `uvm_field_int(error_injection_enabled, UVM_DEFAULT)
  `uvm_object_utils_end

  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "error_seq_item");
    super.new(name);
    // Disable parent constraints in constructor
      valid_ops.constraint_mode(0);
      c_not_all_ones_xnor.constraint_mode(0);
      c_not_all_ones_nand.constraint_mode(0);
      c_input_ranges.constraint_mode(0);
  endfunction
  
  //---------------------------------------
  // New constraints for error injection
  //---------------------------------------
  
  // Extended range for A and B to include -16 (out of original range)
  constraint c_extended_input_ranges {
    A dist { [-16:15]:= 1};
    B dist { [-16:15]:= 1};
  }

endclass