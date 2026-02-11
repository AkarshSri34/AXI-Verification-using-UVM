//`include "env.sv"
class axi_write_test extends uvm_test;
  `uvm_component_utils(axi_write_test)

  axi_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = axi_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);

  axi_write_burst_seq seq;
  axi_read_burst_seq  rseq;

  phase.raise_objection(this);

  // Create sequences
  seq  = axi_write_burst_seq::type_id::create("seq");
  rseq = axi_read_burst_seq ::type_id::create("rseq");

  // Start WRITE sequence
  seq.start(env.agent.sequencer);

  // Pass full write transaction queue to READ sequence
  rseq.write_queue = seq.tx_queue;

  // Start READ sequence (it will loop internally)
  rseq.start(env.agent.sequencer);

  phase.drop_objection(this);

endtask

endclass

