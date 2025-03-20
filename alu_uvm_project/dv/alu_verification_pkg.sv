//-------------------------------------------------------------------------
//				            alu_verification_pkg
//-------------------------------------------------------------------------
package alu_verification_pkg;
  import rst_uvm_pkg::*;
  import alu_uvm_pkg::*;
//---------------------------------------
// Type definitions
//---------------------------------------
typedef logic        [A_OP_WIDTH-1:0] a_op_t;
typedef logic        [B_OP_WIDTH-1:0] b_op_t;
typedef logic signed [INPUT_WIDTH-1:0] operand_t;
typedef logic signed [OUTPUT_WIDTH-1:0] result_t;

//---------------------------------------
// Assertion counters
//---------------------------------------
int unsigned pass_count = 0;
int unsigned fail_count = 0;
int unsigned op_a_pass_count = 0;
int unsigned op_a_fail_count = 0;
int unsigned op_b1_pass_count = 0;
int unsigned op_b1_fail_count = 0;
int unsigned op_b2_pass_count = 0;
int unsigned op_b2_fail_count = 0;
int unsigned reset_pass_count = 0;
int unsigned reset_fail_count = 0;
int unsigned null_op_count = 0;
int unsigned forbidden_result_count = 0;

//---------------------------------------
// Helper Functions
//---------------------------------------

// Get the current ALU mode based on control signals
function automatic OP_MODE_t get_alu_mode(logic a_en, logic b_en);
  if      (~a_en && ~b_en) return MODE_IDLE;
  else if ( a_en && ~b_en) return MODE_A;
  else if (~a_en &&  b_en) return MODE_B01;
  else if ( a_en &&  b_en) return MODE_B11;
  else                     return $error("[ALU_VERIFICATION_PKG] Incorrect Mode inputs");
endfunction

// Result computation functions
function automatic result_t compute_result(
  input a_op_t op_a,
  input b_op_t op_b,
  input operand_t A,
  input operand_t B
);
  if(get_alu_mode(a_en, b_en) == MODE_IDLE)begin
    return prev_result
  end
  else if (get_alu_mode(a_en, b_en) == MODE_A) begin
    case(op_a)
      A_ADD:    return   {A[4],A} + {B[4],B};
      A_SUB:    return   {A[4],A} - {B[4],B};
      A_XOR:    return   {1'b0,A} ^ {1'b0,B};
      A_AND1:   return   {1'b0,A} & {1'b0,B};
      A_AND2:   return   {1'b0,A} & {1'b0,B};
      A_OR:     return   {1'b0,A} | {1'b0,B};
      A_XNOR:   return ~({1'b0,A} ^ {1'b0,B});
      default:  return '0;
    endcase
  end
  else if (get_alu_mode(a_en, b_en) == MODE_B01) begin
    case(op_b)
      B01_NAND:   return ~({1'b0,A} & {1'b0,B});
      B01_ADD1:   return   {A[4],A} + {B[4],B};
      B01_ADD2:   return   {A[4],A} + {B[4],B};
      default:    return '0;
    endcase
  end
  else if(get_alu_mode(a_en, b_en) == MODE_B11) begin
    case(op_b)
      B11_XOR:     return   {1'b0,A} ^ {1'b0,B};
      B11_XNOR:    return ~({1'b0,A} ^ {1'b0,B});
      B11_A_SUB_1: return   {A[4],A} - 6'd1;
      B11_B_ADD_2: return   {B[4],B} + 6'd2;
      default:     return $error("[ALU_VERIFICATION_PKG] Incorrect B_op11 value");
    endcase
  end
  else begin
    return $error("[ALU_VERIFICATION_PKG] Incorrect Mode inputs");
  end
endfunction

// Compute the expected result based on all control signals
function automatic result_t compute_expected_result(
  input logic ALU_en,
  input logic a_en,
  input logic b_en,
  input a_op_t a_op,
  input b_op_t b_op,
  input operand_t A,
  input operand_t B,
  input result_t prev_result
);
  result_t result;

  if (~ALU_en) begin
    return prev_result;
  end
  else begin
    result = compute_result(a_op, b_op, A, B);
  end

  return result;
endfunction

// Format an error message for assertion failures
function automatic string format_error_msg(
  input string op_name,
  input operand_t A,
  input operand_t B,
  input result_t actual,
  input result_t expected
);
  return $sformatf("%s operation failed: A=%0d, B=%0d, Expected=%0d, Actual=%0d",
                   op_name, A, B, expected, actual);
endfunction

// Function to check if operation is NULL
function automatic bit is_null_operation(
  input logic a_en,
  input logic b_en,
  input a_op_t a_op,
  input b_op_t b_op
);
  // Check for A_NULL in MODE_A
  if ( a_en && ~b_en && a_op == A_NULL)
    return 1'b1;
  
  // Check for B01_NULL in MODE_B01
  if (~a_en &&  b_en && b_op == B01_NULL)
    return 1'b1;
    
  return 1'b0;
endfunction

// Function to check if result is forbidden (-32, or specific MODE_B11 forbidden values)
function automatic bit is_forbidden_result(
  input logic a_en,
  input logic b_en,
  input a_op_t a_op,
  input b_op_t b_op,
  input operand_t A,
  input operand_t B
);
  result_t result;
  
  if (a_en && !b_en && !(a_op == A_XOR || a_op == A_AND1 || a_op == A_AND2 )) begin
      result = compute_result(a_op, b_op, A, B);
    return (result < 0);
  end
  else if (a_en && !b_en && !(a_op == A_SUB || a_op == A_ADD )) begin
    // MODE_A
    result = compute_result(a_op, b_op, A, B);
    return (result == -32);
    end
  else if (a_en && !b_en && a_op == A_SUB || a_op == A_ADD ) begin
     result = compute_result(a_op, b_op, A, B);
      return (result == -31);
    end
  else if (!a_en && b_en && !(b_op == B01_ADD1 || b_op == B01_ADD2)) begin
    // MODE_B11
    result = compute_result(a_op, b_op, A, B, 1'b0);
    return (result == -32);
  end 
  else if  (!a_en && b_en && (b_op == B01_ADD1 || b_op == B01_ADD2)) begin
    // MODE_B11
    result = compute_result(a_op, b_op, A, B, 1'b0);
    return (result == -31);
  end
  else if (a_en && b_en && (b_op == B01_NAND)) begin
    result = compute_result(a_op, b_op, A, B, 1'b0);
    return (result > 0);
    end
  else if (a_en && b_en) begin
    // MODE_B11
    result = compute_result_b(a_op, b_op, A, B, 1'b1);
    
    // Check for general forbidden value
    if (result == -32) return 1'b1;
    
    // Check for special MODE_B11 forbidden values
    case (b_op)
      B11_A_SUB_1: if (result == -17) return 1'b1;
      B11_B_ADD_2: if (result == -14) return 1'b1;
      B11_XOR:     if (result < 0)    return 1'b1; 
      B11_XNOR:     if (result > 0) return 1'b1;
      default: return 1'b0;
    endcase
  end else begin
    // MODE_IDLE
    return 1'b0;
  end
endfunction



endpackage : alu_verification_pkg