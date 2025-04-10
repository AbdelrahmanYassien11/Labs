class alu_seq_item extends uvm_sequence_item;

  local static int unsigned pkt_ID; 
  static bit cov_target, a_op_cov_trgt, b_op01_cov_trgt, b_op11_cov_trgt;
  static bit a_op_cov_repi_trgt, b_op01_cov_repi_trgt, b_op11_cov_repi_trgt;

  //---------------------------------------
  // Transaction counters
  //---------------------------------------
  static int unsigned txn_counter_expected;
  static int unsigned txn_counter_actual;

  OP_MODE_t      OP_MODE_e;
  ALU_EN_STATE_t ALU_EN_STATE_e;
  OP_A_t         OP_A_e;
  OP_B01_t       OP_B01_e;
  OP_B11_t       OP_B11_e;

  //---------------------------------------
  //data and control fields
  //---------------------------------------
  rand bit                            ALU_en;
  rand bit                            a_en;
  rand bit                            b_en;
  rand bit         [A_OP_WIDTH-1:0]   a_op;
  rand bit         [B_OP_WIDTH-1:0]   b_op;
  rand bit  signed [INPUT_WIDTH-1:0]  A;
  rand bit  signed [INPUT_WIDTH-1:0]  B;
  bit       signed [OUTPUT_WIDTH-1:0] C;

  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(alu_seq_item)
  `uvm_field_int(pkt_ID,UVM_ALL_ON | UVM_DEC)
  `uvm_field_enum(ALU_EN_STATE_t, ALU_EN_STATE_e, UVM_DEFAULT)
  `uvm_field_enum(OP_MODE_t, OP_MODE_e, UVM_DEFAULT)
  `uvm_field_enum(OP_A_t, OP_A_e, UVM_DEFAULT) 
  `uvm_field_enum(OP_B01_t, OP_B01_e, UVM_DEFAULT)
  `uvm_field_enum(OP_B11_t, OP_B11_e, UVM_DEFAULT)
  `uvm_field_int(A,UVM_ALL_ON  | UVM_DEC)
  `uvm_field_int(B,UVM_ALL_ON  | UVM_DEC)
  `uvm_field_int(C,UVM_ALL_ON  | UVM_DEC)
  `uvm_field_int(ALU_en,UVM_ALL_ON)
  `uvm_field_int(a_en,UVM_ALL_ON)
  `uvm_field_int(b_en,UVM_ALL_ON)
  `uvm_field_int(b_op,UVM_ALL_ON)
  `uvm_field_int(a_op,UVM_ALL_ON)
  `uvm_object_utils_end

  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "alu_seq_item");
    super.new(name);
  endfunction

  //---------------------------------------
  // Post randomize 
  //---------------------------------------
  function void post_randomize();
    pkt_ID++;
    `uvm_info(get_full_name(), "post_randomize", UVM_HIGH)

    // Set device state (ON/OFF)
    ALU_EN_STATE_e = ALU_en ? ALU_ON : ALU_OFF;

    // Set the current ALU operation mode based on control signals
    if (!a_en && !b_en) begin
      OP_MODE_e = MODE_IDLE;
    end
    else if (a_en && !b_en) begin
      OP_MODE_e = MODE_A;
      OP_A_e = OP_A_t'(a_op);
    end
    else if (!a_en && b_en) begin
      OP_MODE_e = MODE_B01;
      OP_B01_e = OP_B01_t'(b_op);
    end
    else if (a_en && b_en) begin
      OP_MODE_e = MODE_B11;
      OP_B11_e = OP_B11_t'(b_op);
    end
  endfunction

  //---------------------------------------
  //constraint, Enable signals distribution
  //---------------------------------------
  constraint enables {
    ALU_en dist {1 := 90, 0 := 10};
    ({a_en , b_en}) dist {2'b00 := 20, 2'b01 := 20, 2'b10:=20, 2'b11 := 20};
  }

  //-----------------------------------------------------
  //constraint, Valid operations based on enable signals
  //-----------------------------------------------------
  constraint valid_ops {
    // MODE_A 
    ( a_en && !b_en ) -> a_op dist {[A_ADD:A_XNOR]:=1};
    // MODE_B01
    (!a_en &&  b_en ) -> b_op dist {[B01_NAND:B01_ADD2]:= 1};
    // MODE_B011
    ( a_en &&  b_en ) -> b_op inside {[B11_XOR:B11_B_ADD_2]};
  }

 //-----------------------------------------------------
 //constraint, Input value ranges
 //-----------------------------------------------------
	constraint c_input_ranges {
                A dist {[-15:15]:=1};
                B dist {[-15:15]:=1};
  }

 //-----------------------------------------------------
 //Constraints to avoid the output reaching -32 value
 //-----------------------------------------------------
  // to avoid C = -32 
  constraint c_not_all_ones_xnor { ((a_op == A_XNOR && a_en && ~b_en) || (b_op == B11_XNOR && a_en && b_en)) -> (A^B) != 5'b11111;}

  // to avoid C = -32 
  constraint c_not_all_ones_nand { (b_op == B01_NAND && ~a_en && b_en) -> (A&B) != 5'b11111;}

endclass