class axi_slave_agent extends uvm_agent;
  `uvm_component_utils(axi_slave_agent)

  axi_slave_sequencer seqr;
  axi_slave_driver    drv;

  function new(string n, uvm_component p);
    super.new(n,p);
  endfunction

  function void build_phase(uvm_phase phase);
    seqr = axi_slave_sequencer::type_id::create("seqr",this);
    drv  = axi_slave_driver   ::type_id::create("drv",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
