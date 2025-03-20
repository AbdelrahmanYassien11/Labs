interface alu_if (input logic clk);

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

    
endinterface