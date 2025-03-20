//------------------------------------------------------------------------------
// 									Comparator               
//------------------------------------------------------------------------------ 
class comparator extends uvm_component;

   // Counters for matches and mismatches
  int correct_counter;
  int incorrect_counter;
  int transaction_counter;
  
  // Register with factory
  `uvm_component_utils_begin(comparator)
  `uvm_field_int(correct_counter, UVM_DEFAULT)
  `uvm_field_int(incorrect_counter, UVM_DEFAULT)
  `uvm_field_int(transaction_counter, UVM_DEFAULT)
  `uvm_component_utils_end

  //---------------------------------------
  // Declare TLM component for reset
  //---------------------------------------
  uvm_analysis_export #(rst_seq_item) reset_collected_export;

  // TLM FIFOs to receive actual and expected outputs
  uvm_tlm_analysis_fifo #(rst_seq_item) reset_fifo;
  uvm_tlm_analysis_fifo #(alu_seq_item) actual_fifo;
  uvm_tlm_analysis_fifo #(alu_seq_item) expected_fifo;

  // Analysis exports
  uvm_analysis_export #(alu_seq_item) analysis_export_expected_outputs;
  uvm_analysis_export #(alu_seq_item) analysis_export_actual_outputs;



  // Sequence_item handles
  alu_seq_item expected_item, actual_item;
  rst_seq_item reset_seq_h;

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    correct_counter = 0;
    incorrect_counter = 0;
    transaction_counter = 0;
  endfunction : new

  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create analysis exports
    reset_collected_export = new ("reset_collected_export",this);  
    analysis_export_expected_outputs = new("analysis_export_expected_outputs", this);
    analysis_export_actual_outputs = new("analysis_export_actual_outputs", this);

    // Create FIFOs
    reset_fifo = new("reset_fifo",this);
    actual_fifo = new("actual_fifo", this);
    expected_fifo = new("expected_fifo", this);
  endfunction: build_phase

  //---------------------------------------
  // Connect phase
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect exports to FIFOs
    analysis_export_expected_outputs.connect(expected_fifo.analysis_export);
    analysis_export_actual_outputs.connect(actual_fifo.analysis_export);
    reset_collected_export.connect(reset_fifo.analysis_export);
  endfunction: connect_phase

  //---------------------------------------
  // Run phase - compare expected vs actual outputs
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      fork
        begin
          reset_fifo.get(reset_seq_h);
          `uvm_info(get_type_name(),
                    $sformatf("reset_Txn during reset: %s",reset_seq_h.sprint()),UVM_HIGH)
        end
        get_and_compare();
      join_any
          disable fork;
    end
  endtask : run_phase

  //---------------------------------------
  // Get & Compare task
  //---------------------------------------
  task get_and_compare();

    forever begin
      // Get expected output
      expected_fifo.get(expected_item);
      alu_seq_item::txn_counter_expected = alu_seq_item::txn_counter_expected + 1;

      // Get actual output
      actual_fifo.get(actual_item);
      alu_seq_item::txn_counter_actual = alu_seq_item::txn_counter_actual + 1;

      // Compare expected vs actual
      if (expected_item.C === actual_item.C) begin
        correct_counter++;
        `uvm_info(get_type_name(), $sformatf("CORRECT %0d: Expected = %0d, Actual = %0d", 
                  correct_counter, expected_item.C, actual_item.C), UVM_MEDIUM)

        `uvm_info(get_type_name(),$sformatf("CORRECT %0d: Expected_TXN_counter = %0d, Actual_TXN_counter = %0d", 
                  correct_counter, alu_seq_item::txn_counter_expected, alu_seq_item::txn_counter_actual), UVM_MEDIUM)
      end 
      else begin
        incorrect_counter++;
        `uvm_error(get_type_name(),  $sformatf("INCORRECT %0d: Expected = %0d, Actual = %0d", 
                   incorrect_counter, expected_item.C, actual_item.C))

		    `uvm_info(get_type_name(), $sformatf("Expected Item: %s",expected_item.sprint()),UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Actual Item: %s",actual_item.sprint()),UVM_LOW)
      end

      transaction_counter++;
    end
  endtask

endclass : comparator