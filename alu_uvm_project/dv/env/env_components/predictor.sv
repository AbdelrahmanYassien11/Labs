//------------------------------------------------------------------------------
// 	Predictor - Predicts the expected result with the given input stimulus             
//------------------------------------------------------------------------------ 
class predictor extends uvm_subscriber #(alu_seq_item);

  uvm_analysis_export #(rst_seq_item) reset_collected_export;
  uvm_tlm_analysis_fifo #(rst_seq_item) reset_fifo;
  bit write_fn_assertion;

  // Analysis port to send expected outputs
  uvm_analysis_port #(alu_seq_item) analysis_port_expected_outputs;

  // Data member
  bit signed [5:0] prev_C;  // Store previous C value

  // Register with factory
  `uvm_component_utils(predictor)

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    prev_C = 0;
  endfunction : new

  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset_collected_export = new("reset_collected_export",this);
    reset_fifo = new("reset_fifo",this);
    analysis_port_expected_outputs = new("analysis_port_expected_outputs", this);
  endfunction: build_phase

  //---------------------------------------
  // Connect phase
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect exports to FIFOs
    reset_collected_export.connect(reset_fifo.analysis_export);
  endfunction: connect_phase

  //---------------------------------------
  // Write method - Called when a transaction is received
  //---------------------------------------
  virtual function void write(alu_seq_item t);
    alu_seq_item cloned_item;
    bit signed [5:0] expected_result;

    // Create a copy of the input transaction
    cloned_item = alu_seq_item::type_id::create("cloned_item");
    cloned_item.copy(t);

    // Compute expected output
    expected_result = compute_result(t);

    // Set the expected output in the cloned transaction
    cloned_item.C = expected_result;

    // Send the expected output to the comparator
    analysis_port_expected_outputs.write(cloned_item);
    write_fn_assertion = 1;
    `uvm_info(get_type_name(),
              $sformatf("expected_seq_item written %s",cloned_item.sprint()),UVM_HIGH)
  endfunction : write
  

  //---------------------------------------
  // Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);
    rst_seq_item reset_seq_h;
    forever begin
    fork
      begin
        reset_fifo.get(reset_seq_h);
        `uvm_info(get_type_name(),
                  $sformatf("predictor supposedly enters here"),UVM_HIGH)
        prev_C = 0;
      end
      wait(write_fn_assertion);
    join_any
      write_fn_assertion = 0;
    disable fork;
    end
  endtask : run_phase

  //---------------------------------------
  // Main compute function
  //---------------------------------------
  function bit signed [5:0] compute_result(alu_seq_item trans);
    bit signed [5:0] result;

    // Case: ALU disabled or invalid mode
    if (!trans.ALU_en || (!trans.a_en && !trans.b_en)) begin
      return prev_C;
    end

    // Compute based on operation set
    if (write_fn_assertion)
      result = 0;
    else if (trans.a_en && !trans.b_en)         
      result = compute_set_a(trans);       // Set A
    else if (!trans.a_en && trans.b_en)    
      result = compute_set_b1(trans);      // Set B1
    else if (trans.a_en && trans.b_en)     
      result = compute_set_b2(trans);      // Set B2
    else                                   
      result = prev_C;

    prev_C = result;
    return result;
  endfunction : compute_result

  //---------------------------------------
  // Set A Operations
  //---------------------------------------
  protected function bit signed [5:0] compute_set_a(alu_seq_item trans);
    case (trans.a_op)
      // Arithmetic operations - use sign extension
      A_ADD:  return {trans.A[4], trans.A} + {trans.B[4], trans.B};
      A_SUB:  return {trans.A[4], trans.A} - {trans.B[4], trans.B};

      // Logical operations - use zero extension first
      A_XOR:  return {1'b0, trans.A} ^ {1'b0, trans.B};
      A_AND1: return {1'b0, trans.A} & {1'b0, trans.B};
      A_AND2: return {1'b0, trans.A} & {1'b0, trans.B};
      A_OR:   return {1'b0, trans.A} | {1'b0, trans.B};
      A_XNOR: return ~({1'b0, trans.A} ^ {1'b0, trans.B});
      A_NULL: return prev_C;
      default: return prev_C;
    endcase
  endfunction : compute_set_a

  //---------------------------------------
  // Set B1 Operations
  //---------------------------------------
  protected function bit signed [5:0] compute_set_b1(alu_seq_item trans);
    case (trans.b_op)
      2'b00: return ~({1'b0, trans.A} & {1'b0, trans.B});          // NAND - zero extend first
      2'b01: return {trans.A[4], trans.A} + {trans.B[4], trans.B};  // ADD1 - arithmetic
      2'b10: return {trans.A[4], trans.A} + {trans.B[4], trans.B};  // ADD2 - arithmetic
      2'b11: return prev_C;                                          // NULL operation
      default: return prev_C;
    endcase
  endfunction : compute_set_b1

  //---------------------------------------
  // Set B2 Operations
  //---------------------------------------
  protected function bit signed [5:0] compute_set_b2(alu_seq_item trans);
    case (trans.b_op)
      2'b00: return {1'b0, trans.A} ^ {1'b0, trans.B};             // XOR - zero extend first
      2'b01: return ~({1'b0, trans.A} ^ {1'b0, trans.B});          // XNOR - zero extend first
      2'b10: return {trans.A[4], trans.A} - 6'd1;                  // A_SUB_1 - arithmetic
      2'b11: return {trans.B[4], trans.B} + 6'd2;                  // B_ADD_2 - arithmetic
      default: return prev_C;
    endcase
  endfunction : compute_set_b2

endclass : predictor