//-------------------------------------------------------------------------
//				            sva_interface.sv
//-------------------------------------------------------------------------
interface sva_if(alu_if alu_intf, rst_if rst_intf, input logic rst_n, input logic clk);
  import alu_uvm_pkg::*;
  import sva_helper_pkg::*;

  //---------------------------------------
  //Output after reset check using Assertions
  //---------------------------------------
  property p_output_update;
    disable iff (~rst_n)
    @(alu_intf.driver_cb)
    $changed({alu_intf.ALU_EN_STATE_o, alu_intf.OP_MODE_o, alu_intf.OP_A_o, alu_intf.OP_B01_o, 
              alu_intf.OP_B11_o, alu_intf.A, alu_intf.B}) |=>
    
    // First check for NULL operation - this should cause assertion failure
    !is_null_operation($past(alu_intf.ALU_EN_STATE_o), $past(alu_intf.OP_MODE_o), $past(alu_intf.OP_A_o), 
                        $past(alu_intf.OP_B01_o), $past(alu_intf.OP_B11_o)) &&
    
    // Then check for forbidden results (-32, or MODE_B2 special forbidden values)
    !is_forbidden_result($past(alu_intf.ALU_EN_STATE_o), $past(alu_intf.OP_MODE_o), $past(alu_intf.OP_A_o), 
                        $past(alu_intf.OP_B01_o), $past(alu_intf.OP_B11_o), 
                        $past(alu_intf.A), $past(alu_intf.B)) &&

    // Then check for expected output value based on the mode
    alu_intf.C == compute_result(1, $past(alu_intf.ALU_EN_STATE_o), $past(alu_intf.OP_MODE_o), $past(alu_intf.OP_A_o), 
                                $past(alu_intf.OP_B01_o), $past(alu_intf.OP_B11_o), 
                                $past(alu_intf.A), $past(alu_intf.B));
  endproperty
  
  property valid_control;
    @(alu_intf.driver_cb)
    alu_intf.ALU_EN_STATE_o |-> (##[0:$] (alu_intf.ALU_EN_STATE_o && (alu_intf.OP_MODE_o inside {[MODE_A:MODE_B11]})));
  endproperty

  // Property to check the output's behavior after reset
  property output_during_reset_p;
    @(negedge rst_n)
    1'b1 |=> @(posedge clk) (alu_intf.C == compute_result(0, $past(alu_intf.ALU_EN_STATE_o), $past(alu_intf.OP_MODE_o), $past(alu_intf.OP_A_o), 
                                $past(alu_intf.OP_B01_o), $past(alu_intf.OP_B11_o), 
                                $past(alu_intf.A), $past(alu_intf.B)));
  endproperty
  
  a_output_update: assert property(p_output_update)
    //$info("\033[32m ALU output updated correctly based on operation mode");
    else $error("\033[31m Invalid ALU computation result detected  en_a %d , en_b %d , a_op %d , b_op %d ,A %0d, B%0d, actual_c %0d, expected_c %0d", alu_intf.a_en , alu_intf.b_en,alu_intf.a_op,alu_intf.b_op,alu_intf.A, alu_intf.B,alu_intf.C,
      compute_result(1, $past(alu_intf.ALU_EN_STATE_o), $past(alu_intf.OP_MODE_o), $past(alu_intf.OP_A_o), 
                                $past(alu_intf.OP_B01_o), $past(alu_intf.OP_B11_o), 
                                $past(alu_intf.A), $past(alu_intf.B)));


  c_output_update: cover property(p_output_update);

  a_valid_control: assert property(valid_control)
    //$info("\033[32m Control signals are properly coordinated");
  else $error("\033[31m Invalid control signal combination detected");
   
  c_valid_control: cover property(valid_control);

  //---------------------------------------
  // Parameterized Properties
  //---------------------------------------
  // Generic property for operation result range check
  property p_op_result_range(
    OP_MODE_t op_MODE,         // Mode control
    OP_A_t op_A, 
    OP_B01_t op_B01, 
    OP_B11_t op_B11, // Operation
    int signed low_range, int signed high_range,          // Valid range [low:high]
    int signed invalid_min, int signed invalid_max        // Invalid values or specific exclusions
  );
    @(alu_intf.monitor_cb) disable iff (!rst_n)
      (alu_intf.ALU_EN_STATE_o == ALU_ON && 
       alu_intf.OP_MODE_o == op_MODE && 
      (op_MODE == MODE_A   ? (alu_intf.OP_A_o == op_A) : 1'b1) &&
      (op_MODE == MODE_B01 ? (alu_intf.OP_B01_o == op_B01) : 1'b1) && 
      (op_MODE == MODE_B11 ? (alu_intf.OP_B11_o == op_B11) : 1'b1) &&
     (!(op_MODE == MODE_IDLE))) 
     |=>  (alu_intf.C inside {[low_range:high_range]} && !(alu_intf.C inside {[invalid_min:invalid_max]}));
  endproperty 

  // Properties for specific operations using parameterized templates
  // Mode A operations
  property p_mode_a_add;
    p_op_result_range(MODE_A, A_ADD, 'x, 'x, -30, 30, -32, -31);
  endproperty
  
  property p_mode_a_sub;
    p_op_result_range(MODE_A, A_SUB, 'x, 'x, -30, 30, -32, -31);
  endproperty
  
  property p_mode_a_logical;
    p_op_result_range(MODE_A, A_XOR, 'x, 'x, 0, 31, -32, -1);
  endproperty
  
  property p_mode_a_xnor;
    p_op_result_range(MODE_A, A_XNOR, 'x, 'x, -31, -1, -32, -32);
  endproperty
  
  // Mode B1 operations
  property p_mode_b1_nand;
    p_op_result_range(MODE_B01, 'x, B01_NAND, 'x, -31, -1, -32, -32);
  endproperty
  
  property p_mode_b1_add;
    p_op_result_range(MODE_B01, 'x, B01_ADD1, 'x, -30, 30, -32, -31);
  endproperty
  
  // Mode B2 operations
  property p_mode_b2_xor;
    p_op_result_range(MODE_B11, 'x, 'x, B11_XOR, 0, 31, -32, -1);
  endproperty   
    
  property p_mode_b2_xnor;
    p_op_result_range(MODE_B11, 'x, 'x, B11_XNOR, -31, -1, 0, 31);
  endproperty  

  // Add assertions and cover directives for all mode operations
  // Mode A operations assertions and cover
  a_mode_a_add: assert property(p_mode_a_add)
    //$info("Mode A ADD operation result within valid range");
  else $error("Mode A ADD operation resulted in invalid value");
  c_mode_a_add: cover property(p_mode_a_add);

  a_mode_a_sub: assert property(p_mode_a_sub)
    //$info("Mode A SUB operation result within valid range");
  else $error("Mode A SUB operation resulted in invalid value");
  c_mode_a_sub: cover property(p_mode_a_sub);

  a_mode_a_logical: assert property(p_mode_a_logical)
    //$info("Mode A logical operation result within valid range");
  else $error("Mode A logical operation resulted in invalid value");
  c_mode_a_logical: cover property(p_mode_a_logical);

  a_mode_a_xnor: assert property(p_mode_a_xnor)
    //$info("Mode A XNOR operation result within valid range");
  else $error("Mode A XNOR operation resulted in invalid value");
  c_mode_a_xnor: cover property(p_mode_a_xnor);

  // Mode B1 operations assertions and cover
  a_mode_b1_nand: assert property(p_mode_b1_nand)
    //$info("Mode B1 NAND operation result within valid range");
  else $error("Mode B1 NAND operation resulted in invalid value");
  c_mode_b1_nand: cover property(p_mode_b1_nand);

  a_mode_b1_add: assert property(p_mode_b1_add)
    //$info("Mode B1 ADD operation result within valid range");
  else $error("Mode B1 ADD operation resulted in invalid value");
  c_mode_b1_add: cover property(p_mode_b1_add);

  // Mode B2 operations assertions and cover
  a_mode_b2_xor: assert property(p_mode_b2_xor)
    //$info("Mode B2 XOR operation result within valid range");
  else $error("Mode B2 XOR operation resulted in invalid value");
  c_mode_b2_xor: cover property(p_mode_b2_xor);

  a_mode_b2_xnor: assert property(p_mode_b2_xnor)
    //$info("Mode B2 XNOR operation result within valid range");
  else $error("Mode B2 XNOR operation resulted in invalid value");
  c_mode_b2_xnor: cover property(p_mode_b2_xnor);

  // Simplified version for single excluded value
  property p_op_result_single_exclusion(
    OP_MODE_t op_MODE,        // Mode control
    OP_A_t op_A, 
    OP_B01_t op_B01, 
    OP_B11_t op_B11,// Operation
    int signed low_range, int signed high_range,          // Valid range [low:high]
    int signed excluded_value                      // Single excluded value
  );
    @(alu_intf.monitor_cb) disable iff (!rst_n)
    (alu_intf.ALU_EN_STATE_o == ALU_ON && 
     alu_intf.OP_MODE_o == op_MODE &&
      (op_MODE == MODE_A   ? (alu_intf.OP_A_o == op_A) : 1'b1) &&
      (op_MODE == MODE_B01 ? (alu_intf.OP_B01_o == op_B01) : 1'b1) && 
      (op_MODE == MODE_B11 ? (alu_intf.OP_B11_o == op_B11) : 1'b1) &&
      (!(op_MODE == MODE_IDLE)))

      |=> (alu_intf.C inside {[low_range:high_range]} && !(alu_intf.C == excluded_value));
  endproperty

  property p_mode_b2_a_sub_1;
    p_op_result_single_exclusion(MODE_B11, 'x, 'x, B11_A_SUB_1, -16, 14, -17);
  endproperty

  property p_mode_b2_b_add_2;
    p_op_result_single_exclusion(MODE_B11, 'x, 'x, B11_B_ADD_2, -13, 17, -14);
  endproperty

  a_mode_b2_a_sub_1: assert property(p_mode_b2_a_sub_1)
    //$info("Mode B2 A-1 operation result within valid range");
  else $error("Mode B2 A-1 operation resulted in invalid value");
  c_mode_b2_a_sub_1: cover property(p_mode_b2_a_sub_1);

  a_mode_b2_b_add_2: assert property(p_mode_b2_b_add_2)
    //$info("Mode B2 B+2 operation result within valid range");
  else $error("Mode B2 B+2 operation resulted in invalid value");
  c_mode_b2_b_add_2: cover property(p_mode_b2_b_add_2);    
  
  // Property to check valid control signals
  property p_valid_control;
    @(alu_intf.driver_cb) disable iff (!rst_n)
    alu_intf.ALU_EN_STATE_o |-> (##[0:$] (alu_intf.ALU_EN_STATE_o && (alu_intf.OP_MODE_o inside {[MODE_A:MODE_B11]} )));
  endproperty
  
  // Check the general valid control property
  a_valid_control_general: assert property(p_valid_control)
    //$info("Control signals are valid");
  else $error("Invalid control signal combination");
  c_valid_control_general: cover property(p_valid_control);

  //---------------------------------------
  // Parameterized Sequences
  //---------------------------------------

  // Generic parameterized sequence for mode transitions
  sequence seq_mode_transition(OP_MODE_t FROM, OP_MODE_t TO);
    (alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == FROM) ##1 
    (alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == TO  );
  endsequence

  //---------------------------------------
  // Derived Sequences using the parameterized templates
  //---------------------------------------
  // Mode transition sequences
  sequence seq_set_a_to_set_b1;
    seq_mode_transition(MODE_A, MODE_B01);
  endsequence

  sequence seq_set_a_to_set_b2;
    seq_mode_transition(MODE_A, MODE_B11);
  endsequence

  sequence seq_set_b1_to_set_a;
    seq_mode_transition(MODE_B01, MODE_A);
  endsequence

  sequence seq_set_b1_to_set_b2;
    seq_mode_transition(MODE_B01, MODE_B11);
  endsequence

  sequence seq_set_b2_to_set_a;
    seq_mode_transition(MODE_B11, MODE_A);
  endsequence

  sequence seq_set_b2_to_set_b1;
    seq_mode_transition(MODE_B11, MODE_B01);
  endsequence

  // Add cover directives for all mode transitions
  c_set_a_to_set_b1: cover property(@(alu_intf.driver_cb) seq_set_a_to_set_b1);
    //$info("Covered: Transition from Set A to Set B1");

  c_set_a_to_set_b2: cover property(@(alu_intf.driver_cb) seq_set_a_to_set_b2);
    //$info("Covered: Transition from Set A to Set B2");

  c_set_b1_to_set_a: cover property(@(alu_intf.driver_cb) seq_set_b1_to_set_a);
    //$info("Covered: Transition from Set B1 to Set A");

  c_set_b1_to_set_b2: cover property(@(alu_intf.driver_cb) seq_set_b1_to_set_b2);
    //$info("Covered: Transition from Set B1 to Set B2");

  c_set_b2_to_set_a: cover property(@(alu_intf.driver_cb) seq_set_b2_to_set_a);
    //$info("Covered: Transition from Set B2 to Set A");

  c_set_b2_to_set_b1: cover property(@(alu_intf.driver_cb) seq_set_b2_to_set_b1);
    //$info("Covered: Transition from Set B2 to Set B1");  


  // Mode A operation sequence
  sequence seq_mode_a_op(OP_A_t op_A);
    (alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == MODE_A && (alu_intf.OP_A_o == op_A));
  endsequence

  // Mode B1 operation sequence
  sequence seq_mode_b1_op(OP_B01_t op_B01);
    (alu_intf.ALU_en && alu_intf.OP_MODE_o == MODE_B01 && (alu_intf.OP_B01_o == op_B01));
  endsequence

  // Mode B2 operation sequence
  sequence seq_mode_b2_op(OP_B11_t op_B11);
    (alu_intf.ALU_en && alu_intf.OP_MODE_o == MODE_B11 && (alu_intf.OP_B11_o == op_B11));
  endsequence

  // Sequence for N consecutive operations
  sequence seq_repeat_n_times(sequence base_seq, int n);
    base_seq[*n];
  endsequence

  //---------------------------------------
  // Operation Specific Sequences (10 times execution)
  //---------------------------------------
  // Mode A operation sequences
  sequence seq_a_add_10_times;
    seq_repeat_n_times(seq_mode_a_op(A_ADD), 10);
  endsequence

  sequence seq_a_sub_10_times;
    seq_repeat_n_times(seq_mode_a_op(A_SUB), 10);
  endsequence

  sequence seq_a_xor_10_times;
    seq_repeat_n_times(seq_mode_a_op(A_XOR), 10);
  endsequence

  sequence seq_a_and1_10_times;
    seq_repeat_n_times(seq_mode_a_op(A_AND1), 10);
  endsequence

  sequence seq_a_and2_10_times;
    seq_repeat_n_times(seq_mode_a_op(A_AND2), 10);
  endsequence

  sequence seq_a_or_10_times;
    seq_repeat_n_times(seq_mode_a_op(A_OR), 10);
  endsequence

  sequence seq_a_xnor_10_times;
    seq_repeat_n_times(seq_mode_a_op(A_XNOR), 10);
  endsequence

  // Mode B1 operation sequences
  sequence seq_b1_nand_10_times;
    seq_repeat_n_times(seq_mode_b1_op(B01_NAND), 10);
  endsequence

  sequence seq_b1_add1_10_times;
    seq_repeat_n_times(seq_mode_b1_op(B01_ADD1), 10);
  endsequence

  sequence seq_b1_add2_10_times;
    seq_repeat_n_times(seq_mode_b1_op(B01_ADD2), 10);
  endsequence

  // Mode B2 operation sequences
  sequence seq_b2_xor_10_times;
    seq_repeat_n_times(seq_mode_b2_op(B11_XOR), 10);
  endsequence

  sequence seq_b2_xnor_10_times;
    seq_repeat_n_times(seq_mode_b2_op(B11_XNOR), 10);
  endsequence

  sequence seq_b2_a_sub_1_10_times;
    seq_repeat_n_times(seq_mode_b2_op(B11_A_SUB_1), 10);
  endsequence

  sequence seq_b2_b_add_2_10_times;
    seq_repeat_n_times(seq_mode_b2_op(B11_B_ADD_2), 10);
  endsequence

  // Add cover directives for repeated operation sequences
  // Mode A operations (10 times)
  c_a_add_10_times: cover property(@(alu_intf.driver_cb) seq_a_add_10_times);
    //$info("Covered: ADD operation executed 10 consecutive times");

  c_a_sub_10_times: cover property(@(alu_intf.driver_cb) seq_a_sub_10_times);
    //$info("Covered: SUB operation executed 10 consecutive times");

  c_a_xor_10_times: cover property(@(alu_intf.driver_cb) seq_a_xor_10_times);
    //$info("Covered: XOR operation executed 10 consecutive times");

  c_a_and1_10_times: cover property(@(alu_intf.driver_cb) seq_a_and1_10_times);
    //$info("Covered: AND1 operation executed 10 consecutive times");

  c_a_and2_10_times: cover property(@(alu_intf.driver_cb) seq_a_and2_10_times);
    //$info("Covered: AND2 operation executed 10 consecutive times");

  c_a_or_10_times: cover property(@(alu_intf.driver_cb) seq_a_or_10_times);
    //$info("Covered: OR operation executed 10 consecutive times");

  c_a_xnor_10_times: cover property(@(alu_intf.driver_cb) seq_a_xnor_10_times);
    //$info("Covered: XNOR operation executed 10 consecutive times");

  // Mode B1 operations (10 times)
  c_b1_nand_10_times: cover property(@(alu_intf.driver_cb) seq_b1_nand_10_times);
    //$info("Covered: B1 NAND operation executed 10 consecutive times");

  c_b1_add1_10_times: cover property(@(alu_intf.driver_cb) seq_b1_add1_10_times);
    //$info("Covered: B1 ADD1 operation executed 10 consecutive times");

  c_b1_add2_10_times: cover property(@(alu_intf.driver_cb) seq_b1_add2_10_times);
    //$info("Covered: B1 ADD2 operation executed 10 consecutive times");

  // Mode B2 operations (10 times)
  c_b2_xor_10_times: cover property(@(alu_intf.driver_cb) seq_b2_xor_10_times);
    //$info("Covered: B2 XOR operation executed 10 consecutive times");

  c_b2_xnor_10_times: cover property(@(alu_intf.driver_cb) seq_b2_xnor_10_times);
    //$info("Covered: B2 XNOR operation executed 10 consecutive times");

  c_b2_a_sub_1_10_times: cover property(@(alu_intf.driver_cb) seq_b2_a_sub_1_10_times);
    //$info("Covered: B2 A-1 operation executed 10 consecutive times");

  c_b2_b_add_2_10_times: cover property(@(alu_intf.driver_cb) seq_b2_b_add_2_10_times);
    //$info("Covered: B2 B+2 operation executed 10 consecutive times");

  // Consecutive operations
  // Consecutive operations with changing opcode
  sequence seq_consecutive_ops_set_a;
    ((alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == MODE_A) ##1 
    (alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == MODE_A && $changed(alu_intf.OP_A_o)))[*3];
  endsequence

  sequence seq_consecutive_ops_set_b1;
    ((alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == MODE_B01) ##1 
    ( alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == MODE_B01 && $changed(alu_intf.OP_B01_o)))[*3];
  endsequence
  
  sequence seq_consecutive_ops_set_b2;
    ((alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == MODE_B11) ##1 
    ( alu_intf.ALU_EN_STATE_o == ALU_ON && alu_intf.OP_MODE_o == MODE_B11 && $changed(alu_intf.OP_B11_o)))[*3];
  endsequence

  // Add cover directives for consecutive operations with changing opcodes
  c_consecutive_ops_set_a: cover property(@(alu_intf.driver_cb) seq_consecutive_ops_set_a);
    //$info("Covered: 3 consecutive Set A operations with changing opcodes");

  c_consecutive_ops_set_b1: cover property(@(alu_intf.driver_cb) seq_consecutive_ops_set_b1);
    //$info("Covered: 3 consecutive Set B1 operations with changing opcodes");

  c_consecutive_ops_set_b2: cover property(@(alu_intf.driver_cb) seq_consecutive_ops_set_b2);
    //$info("Covered: 3 consecutive Set B2 operations with changing opcodes");


  // Assertion to validate the output's behavior after reset
  // Note: This assertion should not be disabled when rst_n is low
  output_during_reset_p_assertion: assert property(output_during_reset_p)
    rst_intf.output_reset_matches = rst_intf.output_reset_matches + 1;
  else begin
    rst_intf.output_reset_mismatches = rst_intf.output_reset_mismatches + 1;
    $display("time: %0t output incorrect after reset", $time());
  end

  // Cover to report the output's behavior after reset
  output_during_reset_p_coverage: cover property(output_during_reset_p);

  // Final block for assertion coverage
  final begin
    $display("--------------------------------------------------------------------------------");
    $display("\nSVA Interface Report: \n\t Assertion coverage completed");
    $display("--------------------------------------------------------------------------------");
  end

endinterface