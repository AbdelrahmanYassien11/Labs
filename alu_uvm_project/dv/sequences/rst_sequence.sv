class reset_sequence extends uvm_sequence #(rst_seq_item);
  bit ok;
  // Register with factory
  `uvm_object_utils(reset_sequence)

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "reset_sequence");
    super.new(name);
  endfunction

  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
      req = rst_seq_item::type_id::create("req");
    forever begin
      start_item(req);
      ok = req.randomize();
      if(!ok)
        `uvm_error(get_type_name(), "Randomization @rst_seq_item failed")
      finish_item(req);
      if(rst_seq_item::resets_done)begin
        $display("atyab? ma fe atyab mn hek");
        break;
      end
    end
  endtask

endclass: reset_sequence

