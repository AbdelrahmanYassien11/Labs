class error_sequence extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(error_sequence)

  // Constructor
  function new(string name = "error_sequence");
    super.new(name);
  endfunction

  // Main sequence body
  virtual task body();

    `uvm_info(get_type_name(), "Starting error injection sequence", UVM_LOW)

    `uvm_info(get_type_name(), "1. XNOR for op_b2 - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 1;
      b_en == 1;
      b_op == B11_XNOR;
      A == 5'b10101; 
      B == 5'b01010; 
    })

    // 1. NULL_OP for op_a
    // 2. NULL_OP for op_b1
    // 3. XOR giving -32
    `uvm_info(get_type_name(), "2. NULL_OP for op_a - completed", UVM_LOW)
    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 1;
      b_en == 0;
      a_op == A_NULL;
    })

    `uvm_info(get_type_name(), "3. NULL_OP for op_b1 - completed", UVM_LOW)
    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 0;
      b_en == 1;
      b_op == B01_NULL;
    })


    `uvm_info(get_type_name(), "4. XNOR op_a - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 1;
      b_en == 0;
      a_op == A_XNOR;
      A == 5'b11111; //
      B == 5'b00000; //
    })
    // 4. NAND giving -32
    `uvm_info(get_type_name(), "5. NAND op_b1 - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 0;
      b_en == 1;
      b_op == B01_NAND;
      A == 5'b11111;
      B == 5'b11111;
    })
    // 5. ADD op_a gives -32
    `uvm_info(get_type_name(), "6. ADD op_a gives -32 - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 1;
      b_en == 0;
      a_op == A_ADD;
      A == -16; // -16
      B == -16; // -16
    })
    // 6a. ADD1 op_b gives -32
    `uvm_info(get_type_name(), "7a. ADD1 op_b1 gives -32 - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 0;
      b_en == 1;
      b_op == B01_ADD1;
      A == 5'b10000; // -16
      B == 5'b10000; // -16
    })
    // 6b. ADD2 op_b gives -32
    `uvm_info(get_type_name(), "7b. ADD2 op_b1 gives -32 - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 0;
      b_en == 1;
      b_op == B01_ADD2;
      A == 5'b10000; // -16
      B == 5'b10000; // -16
    })
    // 7. SUB, op_a gives -32
    `uvm_info(get_type_name(), "8. SUB op_a gives -32 - completed", UVM_LOW)
    // ========================================
    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 1;
      b_en == 0;
      a_op == A_SUB;
      A == 5'b10000; // -16
      B == 5'b01111; // 15
    })
    // 8. A_SUB_1 gives -17
    `uvm_info(get_type_name(), "9. A_SUB_1 op_b2 gives -17 - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 1;
      b_en == 1;
      b_op == B11_A_SUB_1;
      A == 5'b10000; // -16
      B != 0; 
    })
    // 9. B_ADD_2 gives -14
    `uvm_info(get_type_name(), "10. B_ADD_2 op_b2  gives -14 - completed", UVM_LOW)

    `uvm_do_with(req, {
      ALU_en == 1;
      a_en == 1;
      b_en == 1;
      b_op == B11_B_ADD_2;
      B == 5'b10000; // -16
      A == 0; 
    })



    `uvm_info(get_type_name(), "Error sequence completed", UVM_LOW)

  endtask
endclass