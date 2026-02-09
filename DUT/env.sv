//`include "agent.sv"
class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  axi_agent agent;
  axi_slave_agent  s_agent;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    agent = axi_agent::type_id::create("agent", this);
    s_agent = axi_slave_agent ::type_id::create("s_agent",this);
  endfunction
endclass
