interface rst_if (input rst_n);

  //---------------------------------------
  // Reset Items  
  //---------------------------------------

  event need_reset;
  int delay_global;
  int output_reset_matches;
  int output_reset_mismatches;

  //   logic signed [5:0] C;

  //---------------------------------------
  // Reset Method
  //---------------------------------------

  task reset(int reset_duration);
    delay_global = reset_duration;
    -> need_reset;
    $display("[time is %0t] reset task called, rst value is %0d", $time, rst_n);
  endtask

endinterface