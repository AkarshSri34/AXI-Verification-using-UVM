class axi_slave_sequencer extends uvm_sequencer #(axi_slave_txn);
  `uvm_component_utils(axi_slave_sequencer)
  function new(string n, uvm_component p);
    super.new(n,p);
  endfunction
endclass
