class test_config extends uvm_object;
  uvm_active_passive_enum alu_is_active, rst_is_active;
  virtual alu_if test_cfg_vif;
  virtual rst_if test_cfg_r_vif;
  int no_of_resets, test_timeout;
  
  // Register with factory
  `uvm_object_utils_begin(test_config)
    `uvm_field_enum(uvm_active_passive_enum, alu_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, rst_is_active, UVM_DEFAULT)
    `uvm_field_int(no_of_resets, UVM_DEFAULT)
    `uvm_field_int(test_timeout, UVM_DEFAULT)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "test_config");
    super.new(name);
  endfunction : new
  
  // Configuration method
  function void set_config(uvm_active_passive_enum alu_agent_type, 
                         uvm_active_passive_enum rst_agent_type, 
                         virtual rst_if test_cfg_r_vif, 
                         virtual alu_if test_cfg_vif, 
                         int no_of_resets, 
                         int test_timeout);
    this.alu_is_active  = alu_agent_type;
    this.rst_is_active  = rst_agent_type;
    this.test_cfg_r_vif = test_cfg_r_vif;
    this.test_cfg_vif   = test_cfg_vif;
    this.no_of_resets   = no_of_resets;
    this.test_timeout   = test_timeout;
  endfunction : set_config
  
  // Function to get the active/passive state of the agent
  function uvm_active_passive_enum alu_get_is_active();
    return alu_is_active;
  endfunction : alu_get_is_active  
  
  function uvm_active_passive_enum rst_get_is_active();
    return rst_is_active;
  endfunction : rst_get_is_active  
endclass : test_config