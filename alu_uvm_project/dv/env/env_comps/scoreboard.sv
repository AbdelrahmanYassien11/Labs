//--------------------------------------------------------------------------------------------------------------------------------------------
// Scoreboard - inestantiates predictor and comparator and connects them, also keeps track of the incorrect and correct comparisons of items
//-------------------------------------------------------------------------------------------------------------------------------------------- 
class scoreboard extends uvm_scoreboard;

  // Reference model and comparator instances
  predictor predictor_h;
  comparator comparator_h;

  //---------------------------------------
  // Declare TLM component for reset
  //---------------------------------------
  uvm_analysis_export #(rst_seq_item) reset_collected_export;

  // Analysis exports
  uvm_analysis_export #(alu_seq_item) analysis_export_inputs;
  uvm_analysis_export #(alu_seq_item) analysis_export_actual_outputs;

  // Register with factory
  `uvm_component_utils(scoreboard)

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create reference model and comparator
    predictor_h = predictor::type_id::create("predictor_h", this);
    comparator_h = comparator::type_id::create("comparator_h", this);

    // Create analysis exports
    reset_collected_export = new("reset_collected_export",this);
    analysis_export_inputs = new("analysis_export_inputs", this);
    analysis_export_actual_outputs = new("analysis_export_actual_outputs", this);
  endfunction: build_phase

  //---------------------------------------
  // Connect phase
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect reset to reference model and comparator 
    reset_collected_export.connect(predictor_h.reset_collected_export); // reference model
    reset_collected_export.connect(comparator_h.reset_collected_export); // comparator

    // Connect inputs to reference model
    analysis_export_inputs.connect(predictor_h.analysis_export);

    // Connect actual outputs to comparator
    analysis_export_actual_outputs.connect(comparator_h.analysis_export_actual_outputs);

    // Connect reference model to comparator
    predictor_h.analysis_port_expected_outputs.connect(comparator_h.analysis_export_expected_outputs);
  endfunction : connect_phase

  
//   ---------------------------------------
//   phase_ready_to_end phase
//   ---------------------------------------
  function void phase_ready_to_end(uvm_phase phase);
    if (phase.get_name() != "run") return;
    if (~alu_seq_item::cov_target || ~rst_seq_item::resets_done) begin
      phase.raise_objection(.obj(this)); 
      fork 
        begin 
          delay_phase(phase);
        end
      join_none
    end
  endfunction

  //---------------------------------------
  // delay phase
  //---------------------------------------
  task delay_phase(uvm_phase phase);
    wait(alu_seq_item::cov_target && rst_seq_item::resets_done);
    phase.drop_objection(.obj(this));
  endtask

  //---------------------------------------
  // final phase
  //---------------------------------------
  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("SCOREBOARD", "Scoreboard is stopping.", UVM_LOW)
  endfunction

  //---------------------------------------
  // Report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), 
              $sformatf("\nScoreboard Report:\n\tTotal Transactions: %0d\n\tTotal Correct Items: %0d\n\tTotal Incorrect Items: %0d", 
                        comparator_h.transaction_counter, comparator_h.correct_counter, comparator_h.incorrect_counter), 
              UVM_LOW)
    `uvm_info(get_type_name(), "Scoreboard Report Phase Complete", UVM_LOW)
  endfunction : report_phase


endclass : scoreboard