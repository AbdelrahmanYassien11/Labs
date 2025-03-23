class subscriber extends uvm_component;

  //uvm_component test_name;
  string test_name;
  rst_seq_item reset_seq_h;
  alu_seq_item output_cov_copied;
  alu_seq_item input_item, output_item;

  //---------------------------------------
  // Declare TLM component for reset
  //---------------------------------------
  uvm_analysis_export #(rst_seq_item) reset_collected_export;

  // Analysis exports
  uvm_analysis_export #(alu_seq_item) analysis_export_inputs;
  uvm_analysis_export #(alu_seq_item) analysis_export_outputs;

  // TLM FIFOs
  uvm_tlm_analysis_fifo #(rst_seq_item) reset_fifo;
  uvm_tlm_analysis_fifo #(alu_seq_item) inputs_fifo;
  uvm_tlm_analysis_fifo #(alu_seq_item) outputs_fifo;

  // Transaction counter
  int count_trans;

  // Previous operation signals for transitions
  bit       prev_a_en;
  bit       prev_b_en;
  OP_A_t    prev_a_op;
  bit [1:0] prev_b_op;
 
  // Coverage groups
  covergroup control_cg with function sample(alu_seq_item in_trans);
    // 1,2,3: Basic enable signals
    ALU_en_cp: coverpoint in_trans.ALU_en {
      bins ALU_off = {0};
      bins ALU_on  = {1};
    }

    a_en_cp: coverpoint in_trans.a_en {
      bins a_en_enabled  = {1};
    }

    b_en_cp: coverpoint in_trans.b_en {
      bins b_en_enabled  = {1};
    }

     //4: ALU modes cross coverage
   /* modes_cross: cross ALU_en_cp, a_en_cp, b_en_cp {
        bins valid_modes = binsof(ALU_en_cp.ALU_on) &&
                          (binsof(a_en_cp.a_en_enabled) || binsof(b_en_cp.b_en_enabled));
    }*/
    
  endgroup

  // Operation covergroups
  covergroup a_operations_cg with function sample(alu_seq_item in_trans);
    a_op_cp: coverpoint in_trans.a_op {
      bins a_op_values[] = {
        A_ADD,
        A_SUB,
        A_XOR,
        A_AND1,
        A_AND2,
        A_OR,
        A_XNOR
      };
      ignore_bins ignored_val = {A_NULL};
    }

     //Cross with enable signal
   /* a_op_enabled_cross: cross a_op_cp, in_trans.a_en {
      bins valid_ops = binsof(in_trans.a_en) intersect {1};
    }*/
    
  endgroup

  covergroup a_op_repi_cg with function sample(alu_seq_item in_trans);
    // 16: Repeated operations
    op_a_repeat: coverpoint in_trans.a_op iff (in_trans.ALU_en &&  in_trans.a_en && !in_trans.b_en) {
      bins a_repeats[] = ([A_ADD:A_XNOR] [* 10]);  // 3 consecutive same operations
    }
  endgroup

  covergroup b_op01_repi_cg with function sample(alu_seq_item in_trans);
    op_b1_repeat: coverpoint in_trans.b_op iff (in_trans.ALU_en && !in_trans.a_en && in_trans.b_en) {
      bins b1_repeats[] = ([B01_NAND:B01_ADD2] [* 10]);
    }
  endgroup

  covergroup b_op11_repi_cg with function sample(alu_seq_item in_trans);        
    op_b2_repeat: coverpoint in_trans.b_op iff (in_trans.ALU_en && in_trans.a_en && in_trans.b_en) {
      bins b2_repeats[] = ([B11_XOR:B11_B_ADD_2] [* 10]);
    }
  endgroup

  covergroup b_operations11_cg with function sample(alu_seq_item in_trans);
    b_op11_cp: coverpoint in_trans.b_op iff (in_trans.a_en & in_trans.b_en) {
      bins b_op11_values[] = {
        B11_XOR,
        B11_XNOR,
        B11_A_SUB_1,
        B11_B_ADD_2
      };
    }

     //Cross with enable signal
    /*b_op11_enabled_cross: cross b_op11_cp, in_trans.b_en, in_trans.a_en {
      bins valid_ops = binsof(in_trans.b_en) && binsof(in_trans.a_en) intersect {1};
    }*/
    
  endgroup

  covergroup b_operations01_cg with function sample(alu_seq_item in_trans);
    b_op01_cp: coverpoint in_trans.b_op iff (~in_trans.a_en && in_trans.b_en) {
      bins b_op01_values[] = {
        B01_NAND,
        B01_ADD1,
        B01_ADD2
      };
      ignore_bins ignored_val = {B01_NULL};                                                                                      
    }

    a_en_cp: coverpoint in_trans.a_en {
      bins a_en_enabled  = {1};
    }

    b_en_cp: coverpoint in_trans.b_en {
      bins b_en_enabled  = {1};
    }
     //Cross with enable signal
    /*b_op01_enabled_cross: cross b_op01_cp, b_en_cp, a_en_cp {
      //bins valid_ops = binsof(in_trans.b_en) && binsof(in_trans.a_en) intersect {1};
    }*/
    
  endgroup


  // Input value coverage
  covergroup input_values_cg with function sample(alu_seq_item in_trans);
    A_cp: coverpoint in_trans.A {
      bins negative = {[-15:-1]};
      bins zero = {0};
      bins positive = {[1:15]};
    }

    B_cp: coverpoint in_trans.B {
      bins negative = {[-15:-1]};
      bins zero = {0};
      bins positive = {[1:15]};
    }

    // Cross coverage of A and B
    //AB_cross: cross A_cp, B_cp;
  endgroup


  // New covergroups from class-based testbench
  // Output values coverage for C
  covergroup output_values_cg with function sample(alu_seq_item out_trans);
    C_values_cp: coverpoint out_trans.C {
      bins C_pos_vals[] = {[0:31]};
      bins C_neg_vals[] = {[-31:-1]};
      ignore_bins C_illegal = {-32};
    }

    C_sign_transitions: coverpoint out_trans.C {
      bins pos_to_neg = ([0:31]   => [-31:-1]);
      bins neg_to_pos = ([-31:-1] => [0:31]);
    }
  endgroup

  // Added from class-based testbench
  covergroup data_ranges_cg with function sample(alu_seq_item in_trans, alu_seq_item out_trans);
C_OP_dev_cp: coverpoint out_trans.C iff ((out_trans.OP_B11_e == B11_A_SUB_1)
 && (out_trans.OP_MODE_e == MODE_B11) && (out_trans.ALU_EN_STATE_e == ALU_ON)){
  bins C1 = {[-16:14]};
  ignore_bins ignored_vals = {-17};
}


C_OP_inc_cp: coverpoint out_trans.C iff ((out_trans.OP_B11_e == B11_B_ADD_2) 
&& (out_trans.OP_MODE_e == MODE_B11) && (out_trans.ALU_EN_STATE_e == ALU_ON)){
  bins C1 = {[-13:17]};
  ignore_bins ignored_vals = {-14};
}

  endgroup
  

  // Added from class-based testbench
  covergroup stability_cg with function sample(alu_seq_item in_trans, alu_seq_item out_trans);
    C_stability: coverpoint out_trans.C iff(!in_trans.ALU_en) {
      bins stable = ([-30:30][*2:3]);
    }

  endgroup

  // Added from class-based testbench
  covergroup special_cases_cg with function sample(alu_seq_item in_trans);
    // Coverpoints for corner cases
    a_op_cp: coverpoint in_trans.a_op iff ((in_trans.OP_MODE_e == MODE_A) && (in_trans.ALU_EN_STATE_e == ALU_ON ) ) {
      bins add_op = {A_ADD};
      bins sub_op = {A_SUB};
      bins xor_op = {A_XOR};
      bins and1_op = {A_AND1};
      bins and2_op = {A_AND2};
      bins or_op = {A_OR};
      bins xnor_op = {A_XNOR};
    }

    A_val_cp: coverpoint in_trans.A {
      bins min = {-15};
      bins max = {15};
      bins zero = {0};
      bins pos_vals[] = {[1:14]};
      bins neg_vals[] = {[-14:-1]};
    }

    B_val_cp: coverpoint in_trans.B {
      bins min = {-15};
      bins max = {15};
      bins zero = {0};
      bins pos_vals[] = {[1:14]};
      bins neg_vals[] = {[-14:-1]};
    }
    
    // Corner cases cross coverage - extreme values with operations
    /*corner_cases: cross a_op_cp, A_val_cp, B_val_cp {
      bins extremes = binsof(A_val_cp.min) || binsof(A_val_cp.max) ||
                     binsof(B_val_cp.min) || binsof(B_val_cp.max);
    }*/
    
    
    // Coverpoints for same input values
    input_A_cp: coverpoint in_trans.A {
      bins values[] = {[-15:15]};
    }
    input_B_cp: coverpoint in_trans.B {
      bins values[] = {[-15:15]};
    }
    
    /* Cross coverage for same input values
    same_inputs: cross input_A_cp, input_B_cp {
      bins same_vals = binsof(input_A_cp.values) && binsof(input_B_cp.values) with (input_A_cp == input_B_cp);
    }
    */
    
    // Coverpoints for sign bits
    A_sign: coverpoint in_trans.A[4] {
      bins pos = {0};  // Positive numbers (MSB = 0)
      bins neg = {1};  // Negative numbers (MSB = 1)
    }
    
    B_sign: coverpoint in_trans.B[4] {
      bins pos = {0};  // Positive numbers (MSB = 0)
      bins neg = {1};  // Negative numbers (MSB = 1)
    }
    
    /* Cross coverage for opposite signs with operation context
    opposite_signs: cross A_sign, B_sign, a_op_cp {
      bins add_opp_signs = binsof(a_op_cp.add_op) && 
                          ((binsof(A_sign.pos) && binsof(B_sign.neg)) ||
                           (binsof(A_sign.neg) && binsof(B_sign.pos)));
                           
      bins sub_opp_signs = binsof(a_op_cp.sub_op) && 
                          ((binsof(A_sign.pos) && binsof(B_sign.neg)) ||
                           (binsof(A_sign.neg) && binsof(B_sign.pos)));
                           
      ignore_bins same_signs = binsof(A_sign.pos) && binsof(B_sign.pos) ||
                              binsof(A_sign.neg) && binsof(B_sign.neg);
    }
    */

    /* Special arithmetic cases
    arith_cases: cross A_val_cp, B_val_cp, a_op_cp {
      // Addition and subtraction with zero
      bins add_zero = binsof(a_op_cp.add_op) && binsof(A_val_cp.zero);
      bins sub_zero = binsof(a_op_cp.sub_op) && binsof(B_val_cp.zero);
      
      // Operations with same numbers
      bins same_nums = binsof(A_val_cp) && binsof(B_val_cp) with (A_val_cp == B_val_cp);
      
      // Operations with opposite numbers
      bins opposite_nums = binsof(A_val_cp) && binsof(B_val_cp) with (A_val_cp == -B_val_cp);
    }
    */

    /* Operation with extremes - corrected to cross with values
    op_extremes: cross a_op_cp, A_val_cp {
      bins op_with_max = binsof(a_op_cp) intersect {[A_ADD:A_OR]} &&
                        binsof(A_val_cp.max);
      bins op_with_min = binsof(a_op_cp) intersect {[A_ADD:A_OR]} &&
                        binsof(A_val_cp.min);
      ignore_bins null_ops = binsof(a_op_cp.null_op);
    }
    */
  endgroup
  
  covergroup error_cg with function sample(alu_seq_item in_trans, out_trans);
    A_val: coverpoint in_trans.A iff (out_trans.ALU_EN_STATE_e == ALU_ON ) {
      bins A_error = {-16}; 
    } 
    B_val: coverpoint in_trans.B iff (out_trans.ALU_EN_STATE_e == ALU_ON ) {
      bins B_error = {-16}; 
    } 
    a_op_null: coverpoint in_trans.OP_A_e iff ((out_trans.OP_MODE_e == MODE_A) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
      bins A_error = {A_NULL}; 
      bins C_error = {0};
    }
    b_op_null: coverpoint in_trans.OP_B01_e iff ((out_trans.OP_MODE_e == MODE_B01) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
      bins B_error = {B01_NULL}; 
      bins C_error = {0};
    }
    C_val_A_SUB: coverpoint out_trans.C iff ((out_trans.OP_A_e == A_SUB) && (out_trans.OP_MODE_e == MODE_A) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
      bins C_error = {-31}; 
    } 
    C_val_A_ADD: coverpoint out_trans.C iff ((out_trans.OP_A_e == A_ADD)  && (out_trans.OP_MODE_e == MODE_A) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
      bins C_error = {-32}; 
    } 
    C_val_A_XNOR: coverpoint out_trans.C iff ((out_trans.OP_A_e == A_XNOR) && (out_trans.OP_MODE_e == MODE_A) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
      bins C_error = {-32}; 
    } 
    C_val_B1_NAND: coverpoint out_trans.C iff ((out_trans.OP_B01_e == B01_NAND)  && (out_trans.OP_MODE_e == MODE_B01) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
      bins C_error = {-32}; 
    } 
    C_val_B1_ADD1: coverpoint out_trans.C iff ((out_trans.OP_B01_e == B01_ADD1) && (out_trans.OP_MODE_e == MODE_B01) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
      bins C_error = {-32}; 
    } 
    C_val_B1_ADD2: coverpoint out_trans.C iff ((out_trans.OP_B01_e == B01_ADD2) && (out_trans.OP_MODE_e == MODE_B01) && (out_trans.ALU_EN_STATE_e == ALU_ON )){
      bins C_error = {-32}; 
    } 
  C_val_B2_XNOR: coverpoint out_trans.C iff ((out_trans.OP_B11_e == B11_XNOR) && (out_trans.OP_MODE_e == MODE_B11) && (out_trans.ALU_EN_STATE_e == ALU_ON )) {
    bins C_error = {-32};
    } 
     C_val_B2_B_ADD_2: coverpoint out_trans.C iff ((out_trans.OP_B11_e == B11_B_ADD_2) && (out_trans.OP_MODE_e == MODE_B11)
                                                   && (out_trans.ALU_EN_STATE_e == ALU_ON )){
       bins  C_error = {-14};
    }
    C_val_B2_A_SUB_1: coverpoint out_trans.C iff ((out_trans.OP_B11_e == B11_A_SUB_1) && (out_trans.OP_MODE_e == MODE_B11) && (out_trans.ALU_EN_STATE_e == ALU_ON )){
      
      bins  C_error = {-17};
    }
  endgroup

  // Register with factory
  `uvm_component_utils_begin(subscriber)
  `uvm_field_int(count_trans, UVM_DEFAULT)
  `uvm_component_utils_end

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);

    // Initialize counters
    count_trans = 0;

    if(!(uvm_config_db#(string)::get(this,"","test_name",test_name)))
      `uvm_fatal(get_full_name, "Couldn't get TEST_NAME")
      
      `uvm_info(get_full_name(),$sformatf("TEST_NAME %s",test_name),UVM_LOW)
    // Create coverage groups
    case(test_name)
      "random_test": begin 
        control_cg = new();
        input_values_cg = new();
        a_operations_cg = new();
        b_operations01_cg = new();
        b_operations11_cg = new();
        data_ranges_cg = new();
        stability_cg = new();
        special_cases_cg = new();
        output_values_cg = new();
      end

      "repitition_test": begin 
        a_op_repi_cg = new();
        b_op01_repi_cg = new();
        b_op11_repi_cg = new(); 
      end

      "error_test": begin
        error_cg = new();
      end
    endcase
   
  endfunction : new

  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    output_cov_copied = alu_seq_item::type_id::create("output_cov_copied");
    output_item = alu_seq_item::type_id::create("output_item");
    // Create analysis exports
    reset_collected_export = new ("reset_collected_export",this);  
    analysis_export_inputs = new("analysis_export_inputs", this);
    analysis_export_outputs = new("analysis_export_outputs", this);

    // Create TLM FIFOs
    reset_fifo = new("reset_fifo", this);
    inputs_fifo = new("inputs_fifo", this);
    outputs_fifo = new("outputs_fifo", this);
    
  endfunction: build_phase

  //---------------------------------------
  // Connect phase
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect exports to FIFOs
    reset_collected_export.connect(reset_fifo.analysis_export);
    analysis_export_inputs.connect(inputs_fifo.analysis_export);
    analysis_export_outputs.connect(outputs_fifo.analysis_export);
  endfunction: connect_phase

  //---------------------------------------
  // Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);
    forever begin
      fork
        reset_fifo.get(reset_seq_h);
        get_and_sample();
      join_any
            disable fork;
    end
  endtask : run_phase

  //---------------------------------------
  // tasks definations
  //---------------------------------------

  task get_and_sample();

    forever begin
      fork
        inputs_fifo.get(input_item);
        outputs_fifo.get(output_item);
      join
   
      //instance based coverage sampling
//       output_cov_copied.copy(output_item);
//       foreach(output_dec_dt_cg[i]) begin
//         output_dec_dt_cg[i].sample();
//       end

      // Increment transaction counter
      count_trans++;
      
      case(test_name)
        "random_test": begin 
          control_cg.sample(input_item);
          a_operations_cg.sample(input_item);
          b_operations01_cg.sample(input_item);
          b_operations11_cg.sample(input_item);
          input_values_cg.sample(input_item);
          output_values_cg.sample(output_item);
          data_ranges_cg.sample(input_item, output_item);
          stability_cg.sample(input_item, output_item);
          special_cases_cg.sample(input_item);  
        end

        "repitition_test": begin
          a_op_repi_cg.sample(input_item);
          b_op01_repi_cg.sample(input_item);
          b_op11_repi_cg.sample(input_item);
        end

        "error_test": begin
          error_cg.sample(input_item, output_item);

        end
      endcase
      

      // You could add output value checking here if needed

      coverage_target();
    end
  endtask

  task coverage_target();
//     if(a_operations_cg.get_coverage()==100)  alu_seq_item::a_op_cov_trgt = 1;
//     if(b_operations01_cg.get_coverage()==100)  alu_seq_item::b_op01_cov_trgt = 1;
//     if(b_operations11_cg.get_coverage()==100)  alu_seq_item::b_op11_cov_trgt = 1;

    case(test_name)
      "random_test": begin 
        if(control_cg.get_coverage()==100 && a_operations_cg.get_coverage()==100
           && b_operations01_cg.get_coverage()==100 && b_operations11_cg.get_coverage()==100 
           && input_values_cg.get_coverage() == 100 && output_values_cg.get_coverage() == 100
           && data_ranges_cg.get_coverage() == 100 && stability_cg.get_coverage() == 100
           && special_cases_cg.get_coverage() == 100) 
          alu_seq_item::cov_target = 1;
      end

      "repitition_test": begin
        if(a_op_repi_cg.get_coverage()==100)  alu_seq_item::a_op_cov_repi_trgt = 1;
        if(b_op01_repi_cg.get_coverage()==100)  alu_seq_item::b_op01_cov_repi_trgt = 1;
        if(b_op11_repi_cg.get_coverage()==100)  alu_seq_item::b_op11_cov_repi_trgt = 1; 
        if(a_op_repi_cg.get_coverage()==100 && b_op01_repi_cg.get_coverage()==100
           && b_op11_repi_cg.get_coverage()==100) 
          alu_seq_item::cov_target = 1;      
      end

      "error_test": begin
        if(error_cg.get_coverage()==100)
          alu_seq_item::cov_target = 1;  
      end
    endcase
  endtask
  
  //---------------------------------------
  // Report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Received transactions: %0d", count_trans), UVM_LOW)

    `uvm_info(get_type_name(), "\nCoverage Report:", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("TEST_NAME = %s", test_name), UVM_LOW)
    
    
    case(test_name)
      "random_test": begin 
        `uvm_info(get_type_name(), $sformatf("Control        Coverage: %.2f%%", control_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Input Values   Coverage: %.2f%%", input_values_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("A Operations   Coverage: %.2f%%", a_operations_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("B Operations01 Coverage: %.2f%%", b_operations01_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("B Operations11 Coverage: %.2f%%", b_operations11_cg.get_coverage()), UVM_LOW)    
        `uvm_info(get_type_name(), $sformatf("Output Values  Coverage: %.2f%%", output_values_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Data Ranges    Coverage: %.2f%%", data_ranges_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Stability      Coverage: %.2f%%", stability_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Special Cases  Coverage: %.2f%%", special_cases_cg.get_coverage()), UVM_LOW)
      end

      "repitition_test": begin 
        `uvm_info(get_type_name(), $sformatf("repitition cg for op_A Coverage: %.2f%%", a_op_repi_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("repitition cg for op_B1 Coverage: %.2f%%", b_op01_repi_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("repitition cg for op_B2 Coverage: %.2f%%", b_op11_repi_cg.get_coverage()), UVM_LOW)   
      end

      "error_test": begin
        `uvm_info(get_type_name(), $sformatf("Error Cases Coverage: %.2f%%", error_cg.get_coverage()), UVM_LOW)
      end
    endcase
    `uvm_info(get_type_name(), $sformatf("Total Coverage: %.2f%%", $get_coverage()), UVM_LOW)  
    


  endfunction : report_phase

endclass : subscriber