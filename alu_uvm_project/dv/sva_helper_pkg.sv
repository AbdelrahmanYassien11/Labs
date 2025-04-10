//-------------------------------------------------------------------------
//				            sva_helper_pkg
//-------------------------------------------------------------------------
package sva_helper_pkg;
  import rst_uvm_pkg::*;
  import alu_uvm_pkg::*;
//---------------------------------------
// Type definitions
//---------------------------------------
OP_MODE_t       OP_MODE_o;
ALU_EN_STATE_t  ALU_EN_STATE_o;
OP_A_t          OP_A_o;
OP_B01_t        OP_B01_o;
OP_B11_t        OP_B11_o;


typedef bit        [A_OP_WIDTH-1:0] a_op_t;
typedef bit        [B_OP_WIDTH-1:0] b_op_t;
typedef bit signed [INPUT_WIDTH-1:0] operand_t;
typedef bit signed [OUTPUT_WIDTH-1:0] result_t;

bit signed [OUTPUT_WIDTH-1:0] result, prev_result;

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
// Result computation functions
function automatic result_t compute_result(
  input bit rst_an,
  input ALU_EN_STATE_t ALU_EN_STATE,
  input OP_MODE_t OP_MODE,
  input OP_A_t         OP_A,
  input OP_B01_t       OP_B01,
  input OP_B11_t       OP_B11,

  input operand_t A,
  input operand_t B
);
  //result_t result;
if(~rst_an) begin
result = 0;
end
else begin
  if(ALU_EN_STATE == ALU_ON) begin
    if (OP_MODE == MODE_A) begin
      case(OP_A)
        A_ADD:    result =   {A[4],A} + {B[4],B};
        A_SUB:    result =   {A[4],A} - {B[4],B};
        A_XOR:    result =   {1'b0,A} ^ {1'b0,B};
        A_AND1:   result =   {1'b0,A} & {1'b0,B};
        A_AND2:   result =   {1'b0,A} & {1'b0,B};
        A_OR:     result =   {1'b0,A} | {1'b0,B};
        A_XNOR:   result = ~({1'b0,A} ^ {1'b0,B});
        A_NULL:   result = 6'b0;
        default:  $error("[SVA_HELPER_PKG] X proapgation B_op11 value");
      endcase
    end
    else if (OP_MODE == MODE_B01) begin
      case(OP_B01)
        B01_NAND:   result = ~({1'b0,A} & {1'b0,B});
        B01_ADD1:   result =   {A[4],A} + {B[4],B};
        B01_ADD2:   result =   {A[4],A} + {B[4],B};
        B01_NULL:   result = 6'b0;
        default:    $error("[SVA_HELPER_PKG] X proapgation B_op01 value");
      endcase
    end
    else if(OP_MODE == MODE_B11) begin
      case(OP_B11)
        B11_XOR:     result =   {1'b0,A} ^ {1'b0,B};
        B11_XNOR:    result = ~({1'b0,A} ^ {1'b0,B});
        B11_A_SUB_1: result =   {A[4],A} - 6'd1;
        B11_B_ADD_2: result =   {B[4],B} + 6'd2;
        default:     $error("[SVA_HELPER_PKG] X propagation B_op11 value");
      endcase
    end
 end
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
  return $sformatf("%s operation failed: A=%0d, B=%0d, Expected=%0d, Actual=%0d", op_name, A, B, expected, actual);
endfunction

// Function to check if operation is NULL
function automatic bit is_null_operation(
  input ALU_EN_STATE_t ALU_EN_STATE,
  input OP_MODE_t OP_MODE,
  input OP_A_t         OP_A,
  input OP_B01_t       OP_B01,
  input OP_B11_t       OP_B11
);
  case(OP_MODE)
    MODE_A: begin
      // Check for A_NULL in MODE_A
      if (OP_A == A_NULL)
        return 1'b1;
      else
        return 1'b0;
    end
    // Check for B01_NULL in MODE_B01
    MODE_B01: begin
      if (OP_B01 == B01_NULL)
        return 1'b1;
      else
        return 1'b0;
    end
    default: begin
      return 1'b0;
    end
  endcase // OP_MODE
endfunction

// / Function to check if result is forbidden (-32, or specific MODE_B2 forbidden values)
function automatic bit is_forbidden_result(
  input ALU_EN_STATE_t ALU_EN_STATE,
  input OP_MODE_t OP_MODE,
  input OP_A_t         OP_A,
  input OP_B01_t       OP_B01,
  input OP_B11_t       OP_B11,
  input operand_t A,
  input operand_t B
);
  result_t result;
  result = compute_result(1, ALU_EN_STATE, OP_MODE, OP_A, OP_B01, OP_B11, A, B);

  // Determine which operating mode we're in
  if (OP_MODE == MODE_A) begin

    // Different checks based on operation type
    case (OP_A)
      A_ADD, A_SUB:
        return (result == -31 || result == -32);
      
      A_XOR, A_AND1, A_AND2:
        return (result < 0 ); // These operations must have positive results
        
      default:
        return (result == -32); // For other operations, -32 is forbidden
    endcase
  end
  else if (OP_MODE == MODE_B01) begin
    case (OP_B01)
      B01_ADD1, B01_ADD2:
        return (result == -31 || result == -32);
        
      B01_NAND:
        return (result > 0 || result == -32); // NAND cannot be positive
        
      default:
        return (result == -32);
    endcase
  end
  else if (OP_MODE == MODE_B11) begin
    // Special cases for MODE_B2 operations
    case (OP_B11)
      B11_XOR:
        return (result < 0);
        
      B11_XNOR:
        return (result > 0 || result == -32);
        
      B11_A_SUB_1:
        return (result == -17 || result == -32);
        
      B11_B_ADD_2:
        return (result == -14 || result == -32);
        
      default:
        return (result == -32);
    endcase
  end
  else begin
  return (result == -32);    //return 1'b0;
  end
endfunction


endpackage : sva_helper_pkg