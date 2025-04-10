module ALU #(parameter INPUT_WIDTH, OUTPUT_WIDTH, A_OP_WIDTH, B_OP_WIDTH) (
  // Clock and Reset
  input wire clk,      // Clock signal
  input wire rst_n,    // Active-low reset

  // Control Signals
  input wire ALU_en,   // ALU enable signal
  input wire a_en,     // Enable signal for operation set A
  input wire b_en,     // Enable signal for operation set B

  // Operation Selection
  input wire [A_OP_WIDTH-1:0] a_op, // Operation selector for set A
  input wire [B_OP_WIDTH-1:0] b_op, // Operation selector for set B

  // Data Inputs
  input wire signed [INPUT_WIDTH-1:0] A, // 5-bit signed input operand A
  input wire signed [INPUT_WIDTH-1:0] B, // 5-bit signed input operand B

  // Output
  output reg signed [OUTPUT_WIDTH-1:0] C // 6-bit signed output result
);

  // Operation Set A Parameters (Basic Arithmetic & Logic Operations)

  localparam [2:0] A_ADD   = 3'd0;
  localparam [2:0] A_SUB   = 3'd1;
  localparam [2:0] A_XOR   = 3'd2;
  localparam [2:0] A_AND1  = 3'd3;
  localparam [2:0] A_AND2  = 3'd4;
  localparam [2:0] A_OR    = 3'd5;
  localparam [2:0] A_XNOR  = 3'd6;
  localparam [2:0] A_NULL  = 3'd7;

  // Operation Set B Parameters (Additional Operations in Two Sets)

  // Operation Set B Parameters (Set 1)
  localparam [1:0] B01_NAND  = 2'd0;
  localparam [1:0] B01_ADD1  = 2'd1;
  localparam [1:0] B01_ADD2  = 2'd2;
  localparam [1:0] B01_NULL  = 2'd3;

  // Operation Set B Parameters (Set 2)
  localparam [1:0] B11_XOR     = 2'd0;
  localparam [1:0] B11_XNOR    = 2'd1;
  localparam [1:0] B11_A_SUB_1 = 2'd2;
  localparam [1:0] B11_B_ADD_2 = 2'd3;



  // Control signals determining which operation set is active
  wire operand_IDLE =  ~a_en  && ~b_en;           // IDLE MODE
  wire operand_A    =  a_en   && ~b_en;           // Set A operations
  wire operand_B01  =  ~a_en  && b_en;            // Set B (Subset 1) operations
  wire operand_B11  =  a_en   && b_en;            // Set B (Subset 2) operations
  wire valid_mode   =  rst_n && ALU_en;  // Valid Mode

  // Internal signal to hold the computed result
  reg signed [5:0] result;
  reg signed [5:0] prev_result;

  always@(negedge rst_n) begin
    if(~rst_n) begin
      prev_result = 0;
    end
  end

  // ALU Operation Logic - Determines the result based on the enabled operation set
  always @(*) begin
    result = 0;
    if(ALU_en) begin   
      if(operand_IDLE)begin
        result = prev_result;
        $display("Time:%0t HELLO RESULT %0d", $time() ,result);
      end
      else if (operand_A) begin
        // Execute operations from set A
        case (a_op)
          A_ADD:  result = {A[4],A} + {B[4],B};   // Addition
          A_SUB:  result = {A[4],A} - {B[4],B};   // Subtraction
          A_XOR:  result = {1'b0,A} ^ {1'b0,B};   // XOR
          A_AND1: result = {1'b0,A} & {1'b0,B};   // AND1
          A_AND2: result = {1'b0,A} & {1'b0,B};   // AND2
          A_OR:   result = {1'b0,A} | {1'b0,B};   // OR
          A_XNOR: result = ~({1'b0,A} ^ {1'b0,B}); // XNOR
          A_NULL: result = prev_result;  
          default: $error("X Propagation at a_op opcode");   // Default case
        endcase
      end
      else if (operand_B01) begin
        // Execute operations from set B (Subset 1)
        case (b_op)
          B01_NAND: result = ( (~{1'b0,A}) | (~{1'b0,B}));  // NAND
          B01_ADD1: result =     {A[4],A} + {B[4],B};     // Addition1
          B01_ADD2: result =     {A[4],A} + {B[4],B};     // Addition2
          B01_NULL: result = prev_result;
          default:  $error("X Propagation at b_op opcode");      // Default case
        endcase
      end
      else if (operand_B11) begin
        // Execute operations from set B (Subset 2)
        case (b_op)
          B11_XOR:      result = {1'b0,A} ^ {1'b0,B};    // XOR
          B11_XNOR:     result = ~({1'b0,A} ^ {1'b0,B}); // XNOR
          B11_A_SUB_1:  result = {A[4],A} - 6'd1; // Decrement A by 1
          B11_B_ADD_2:  result = {B[4],B} + 6'd2; // Increment B by 2
          default:      $error("X Propagation at b_op opcode");
        endcase
      end
      else begin
        $error("X Propagation at a_en or b_en");
      end
    end
    else if (~ALU_en) begin
      result = prev_result;
    end 
    else begin
      $error("X Propagation at ALU_en");
    end
  if(result == 7) $display("TIME %0t result = 7", $time());
  prev_result = result;
  end

  // Output Register - Captures the result at the rising edge of clk
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      C <= 6'b0; // Reset output to 0
    end
    else begin
      C <= result; // Store computed result
    end
  end

endmodule


module ALU #(parameter INPUT_WIDTH, OUTPUT_WIDTH, A_OP_WIDTH, B_OP_WIDTH) (
  // Clock and Reset
  input wire clk,      // Clock signal
  input wire rst_n,    // Active-low reset

  // Control Signals
  input wire ALU_en,   // ALU enable signal
  input wire a_en,     // Enable signal for operation set A
  input wire b_en,     // Enable signal for operation set B

  // Operation Selection
  input wire [A_OP_WIDTH-1:0] a_op, // Operation selector for set A
  input wire [B_OP_WIDTH-1:0] b_op, // Operation selector for set B

  // Data Inputs
  input wire signed [INPUT_WIDTH-1:0] A, // 5-bit signed input operand A
  input wire signed [INPUT_WIDTH-1:0] B, // 5-bit signed input operand B

  // Output
  output reg signed [OUTPUT_WIDTH-1:0] C // 6-bit signed output result
);

  // Operation Set A Parameters (Basic Arithmetic & Logic Operations)

  localparam [2:0] A_ADD   = 3'd0;
  localparam [2:0] A_SUB   = 3'd1;
  localparam [2:0] A_XOR   = 3'd2;
  localparam [2:0] A_AND1  = 3'd3;
  localparam [2:0] A_AND2  = 3'd4;
  localparam [2:0] A_OR    = 3'd5;
  localparam [2:0] A_XNOR  = 3'd6;
  localparam [2:0] A_NULL  = 3'd7;

  // Operation Set B Parameters (Additional Operations in Two Sets)

  // Operation Set B Parameters (Set 1)
  localparam [1:0] B01_NAND  = 2'd0;
  localparam [1:0] B01_ADD1  = 2'd1;
  localparam [1:0] B01_ADD2  = 2'd2;
  localparam [1:0] B01_NULL  = 2'd3;

  // Operation Set B Parameters (Set 2)
  localparam [1:0] B11_XOR     = 2'd0;
  localparam [1:0] B11_XNOR    = 2'd1;
  localparam [1:0] B11_A_SUB_1 = 2'd2;
  localparam [1:0] B11_B_ADD_2 = 2'd3;



  // Control signals determining which operation set is active
  wire operand_IDLE =  ~a_en  && ~b_en;           // IDLE MODE
  wire operand_A    =  a_en   && ~b_en;           // Set A operations
  wire operand_B01  =  ~a_en  && b_en;            // Set B (Subset 1) operations
  wire operand_B11  =  a_en   && b_en;            // Set B (Subset 2) operations
  wire valid_mode   =  rst_n && ALU_en;  // Valid Mode

  // Internal signal to hold the computed result
  reg signed [5:0] result;
  reg signed [5:0] prev_result;


  // ALU Operation Logic - Determines the result based on the enabled operation set
  always @(*) begin
    result = 0;
    if(ALU_en) begin   
      if(operand_IDLE)begin
        result = prev_result;
        $display("Time:%0t HELLO RESULT %0d", $time() ,result);
      end
      else if (operand_A) begin
        // Execute operations from set A
        case (a_op)
          A_ADD:  result = {A[4],A} + {B[4],B};   // Addition
          A_SUB:  result = {A[4],A} - {B[4],B};   // Subtraction
          A_XOR:  result = {1'b0,A} ^ {1'b0,B};   // XOR
          A_AND1: result = {1'b0,A} & {1'b0,B};   // AND1
          A_AND2: result = {1'b0,A} & {1'b0,B};   // AND2
          A_OR:   result = {1'b0,A} | {1'b0,B};   // OR
          A_XNOR: result = ~({1'b0,A} ^ {1'b0,B}); // XNOR
          A_NULL: result = prev_result;  
          default: $error("X Propagation at a_op opcode");   // Default case
        endcase
      end
      else if (operand_B01) begin
        // Execute operations from set B (Subset 1)
        case (b_op)
          B01_NAND: result = ( (~{1'b0,A}) | (~{1'b0,B}));  // NAND
          B01_ADD1: result =     {A[4],A} + {B[4],B};     // Addition1
          B01_ADD2: result =     {A[4],A} + {B[4],B};     // Addition2
          B01_NULL: result = prev_result;
          default:  $error("X Propagation at b_op opcode");      // Default case
        endcase
      end
      else if (operand_B11) begin
        // Execute operations from set B (Subset 2)
        case (b_op)
          B11_XOR:      result = {1'b0,A} ^ {1'b0,B};    // XOR
          B11_XNOR:     result = ~({1'b0,A} ^ {1'b0,B}); // XNOR
          B11_A_SUB_1:  result = {A[4],A} - 6'd1; // Decrement A by 1
          B11_B_ADD_2:  result = {B[4],B} + 6'd2; // Increment B by 2
          default:      $error("X Propagation at b_op opcode");
        endcase
      end
      else begin
        $error("X Propagation at a_en or b_en");
      end
    end
    else if (~ALU_en) begin
      result = prev_result;
    end 
    else begin
      $error("X Propagation at ALU_en");
    end
  if(result == 7) $display("TIME %0t result = 7", $time());
  prev_result = result;
  end

  // Output Register - Captures the result at the rising edge of clk
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      C <= 6'b0; // Reset output to 0
    end
    else begin
      C <= result; // Store computed result
    end
  end

  always@(negedge rst_n) begin
    if(~rst_n) begin
      prev_result = 0;
    end
  end

endmodule
