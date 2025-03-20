class rst_agent_config extends uvm_object;
  // Virtual interface used for connecting the active agent to the Design Under Test (DUT)
  virtual rst_if rst_agent_config_my_r_vif;
  
  // Enumeration indicating whether the agent is active or passive
  protected uvm_active_passive_enum is_active;
  
  // Register with factory
  `uvm_object_utils_begin(rst_agent_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "rst_agent_config");
    super.new(name);
  endfunction : new
  
  // Initialization method
  function void initialize(virtual rst_if rst_agent_config_my_r_vif, uvm_active_passive_enum is_active);
    this.rst_agent_config_my_r_vif = rst_agent_config_my_r_vif;
    this.is_active = is_active;
  endfunction : initialize
  
  // Function to get the active/passive state of the agent
  function uvm_active_passive_enum get_is_active();
    return is_active;
  endfunction : get_is_active
  
endclass : rst_agent_config