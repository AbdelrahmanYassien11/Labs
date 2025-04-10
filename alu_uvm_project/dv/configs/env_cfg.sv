class env_config extends uvm_object;
  // Virtual interface to the DUT
  virtual alu_if env_config_my_vif;
  virtual rst_if env_config_my_r_vif;
  
  // Agent configurations
  uvm_active_passive_enum alu_is_active, rst_is_active;
  
  // Register with factory
  `uvm_object_utils_begin(env_config)
    `uvm_field_enum(uvm_active_passive_enum, alu_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, rst_is_active, UVM_DEFAULT)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "env_config");
    super.new(name);
  endfunction : new
  
  // Initialization method
  function void initialize(virtual alu_if env_config_my_vif, 
                           virtual rst_if env_config_my_r_vif, 
                           uvm_active_passive_enum alu_is_active, 
                           uvm_active_passive_enum rst_is_active);
    this.env_config_my_vif = env_config_my_vif;
    this.env_config_my_r_vif = env_config_my_r_vif;
    this.rst_is_active = rst_is_active;
    this.alu_is_active = alu_is_active;
  endfunction : initialize
  
  // Function to get the active/passive state of the agent
  function uvm_active_passive_enum alu_get_is_active();
    return alu_is_active;
  endfunction : alu_get_is_active  
  
  function uvm_active_passive_enum rst_get_is_active();
    return rst_is_active;
  endfunction : rst_get_is_active  
endclass : env_config