//-------------------------------------------------------------------------
//				            alu_top_tb.sv
//-------------------------------------------------------------------------

module alu_top_tb;

  import uvm_pkg::*;
  //`include "uvm_macros.svh"
  // import rst_uvm_pkg::*;
  import alu_uvm_pkg::*;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit clk;
  bit rst_n;
  int no_of_resets;
  int test_timeout;

  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 clk = ~clk;

  //---------------------------------------
  //reset Generation Task
  //---------------------------------------
  task rst;
    rst_n = 0;
    #173;
    rst_n = 1;
  endtask

  //---------------------------------------
  //reset Generation
  //---------------------------------------  
  initial begin
    rst();
    //     #194;
    //     rst();
    //     #99;
    //     rst();
    //     #375;
    //     rst();
  end

  //---------------------------------------
  //interfaces instance
  //---------------------------------------
  alu_if alu_intf(clk);
  rst_if rst_intf(rst_n);
  sva_if sva_intf(alu_intf,rst_intf,rst_n,clk);

  //---------------------------------------
  //DUT instance
  //---------------------------------------
  ALU #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH), .A_OP_WIDTH(A_OP_WIDTH), .B_OP_WIDTH(B_OP_WIDTH)) ALU1 (
    .clk(clk),
    .rst_n(rst_n),
    .ALU_en(alu_intf.ALU_en),
    .a_en(alu_intf.a_en),
    .b_en(alu_intf.b_en),
    .a_op(alu_intf.a_op),
    .b_op(alu_intf.b_op),
    .A(alu_intf.A),
    .B(alu_intf.B),
    .C(alu_intf.C)
  );

  //---------------------------------------
  // Reset monitor process
  //---------------------------------------

  initial begin
    forever begin
      @(rst_intf.need_reset);
      $display("[time is %0t] Reset event detected", $time);
      rst_n = 0;
      #rst_intf.delay_global;
      rst_n = 1;
      $display("[time is %0t] Reset sequence completed", $time);
    end
  end

  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  test_config t_cfg;
  initial begin
    no_of_resets = 4;
    test_timeout = 5000;

    // Create and initialize test config
    t_cfg = test_config::type_id::create("t_cfg");
    t_cfg.set_config(UVM_ACTIVE, UVM_ACTIVE, rst_intf, alu_intf, no_of_resets, test_timeout);
    
    // Set in config DB
    uvm_config_db#(test_config)::set(uvm_root::get(),"uvm_test_top","test_cfg",t_cfg);

    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end

  //---------------------------------------
  //calling reset and test
  //---------------------------------------
  initial begin 
    run_test();
  end

    // Use runtime selection to set the VPD file and choose the test
  initial begin
    string test_name;
    string vpd_file;
    #1ns;
    if(!(uvm_config_db#(string)::get(null,"uvm_test_top.env_h","test_name",test_name)))
      `uvm_fatal("ALU_TOP_TB", "COULDN'T GET TEST NAME")
      
    // Select VPD file based on runtime UVM_TESTNAME
    case (test_name)
      "random_test":      vpd_file = "output/random_test.vpd";
      "repitition_test":  vpd_file = "output/repitition_test.vpd";
      "error_test":       vpd_file = "output/error_test.vpd";
      default :           vpd_file = "output/random_test.vpd";
    endcase

    // Open the VPD file and start dumping signals
    $vcdplusfile(vpd_file);
    $vcdpluson;
  end

endmodule : alu_top_tb