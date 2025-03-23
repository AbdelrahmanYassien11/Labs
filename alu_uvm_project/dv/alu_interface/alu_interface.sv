interface alu_if (input logic clk);

  import alu_uvm_pkg::*;
  //-----------------------------------------------
  //declaring the enums for different input states
  //-----------------------------------------------
  OP_MODE_t       OP_MODE_o;
  ALU_EN_STATE_t  ALU_EN_STATE_o;
  OP_A_t          OP_A_o;
  OP_B01_t        OP_B01_o;
  OP_B11_t        OP_B11_o;


  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  logic          ALU_en;
  logic          a_en;
  logic          b_en;
  logic    [2:0] a_op;
  logic    [1:0] b_op;
  logic signed [4:0] A;
  logic signed [4:0] B;
  logic signed [5:0] C;

  //---------------------------------------
  //driver clocking block
  //---------------------------------------

  default clocking driver_cb @(negedge clk);
    default input #1 output #2;
    output ALU_en;
    output a_en;
    output b_en;
    output a_op;
    output b_op;
    output A;
    output B;
    input  #2 C;
  endclocking

  //---------------------------------------
  //monitor clocking block
  //---------------------------------------

  clocking monitor_cb @(posedge clk);
    default input #0 output #1;
    input ALU_en;
    input a_en;
    input b_en;
    input a_op;
    input b_op;
    input A;
    input B;
    input C;
  endclocking

  //---------------------------------------
  //driver modport
  //---------------------------------------

        modport DRIVER (clocking driver_cb, input clk);

  //---------------------------------------
  //monitor modport  
  //---------------------------------------

        modport MONITOR (clocking monitor_cb, input clk);



  always @(*) begin
    if(~ALU_en) begin
      ALU_EN_STATE_o = ALU_OFF;
    end
    else if(ALU_en) begin
      ALU_EN_STATE_o = ALU_ON;
      if(~a_en & ~b_en) begin
        OP_MODE_o = MODE_IDLE;
      end
      else if ( a_en &  ~b_en) begin
        OP_MODE_o = MODE_A;
        case(a_op)
          A_ADD:    OP_A_o = A_ADD;
          A_SUB:    OP_A_o = A_SUB;
          A_XOR:    OP_A_o = A_XOR;
          A_AND1:   OP_A_o = A_AND1;
          A_AND2:   OP_A_o = A_AND2;
          A_OR:     OP_A_o = A_OR;
          A_XNOR:   OP_A_o = A_XNOR;
          A_NULL:   OP_A_o = A_NULL;
          default:  $error("op_a X propagation");
        endcase // op_a
      end
      else if (~a_en &  b_en) begin
        OP_MODE_o = MODE_B01;
        case(b_op)
          B01_NAND:   OP_B01_o = B01_NAND;
          B01_ADD1:   OP_B01_o = B01_ADD1;
          B01_ADD2:   OP_B01_o = B01_ADD2;
          B01_NULL:   OP_B01_o = B01_NULL;
          default:    $error("op_b01 X propagation");
        endcase              
      end
      else if ( a_en &  b_en) begin
        OP_MODE_o = MODE_B11;
        case(b_op)
          B11_XOR:     OP_B11_o = B11_XOR;
          B11_XNOR:    OP_B11_o = B11_XNOR;
          B11_A_SUB_1: OP_B11_o = B11_A_SUB_1;
          B11_B_ADD_2: OP_B11_o = B11_B_ADD_2;
          default:     $error("op_b11 X propagation");
        endcase      
      end
      else begin
        $error("a_en & b_en X propagation");
      end      
    end
    else begin
      $error("ALU_en X propagation");
    end
  end
    
endinterface