class axi_write_burst_seq extends uvm_sequence #(axi_write_txn);
  `uvm_object_utils(axi_write_burst_seq)
  
  bit [31:0] last_awaddr;
  bit [7:0]  last_awlen;     // burst length - 1
  bit [2:0]  last_awsize;    // bytes per beat
  bit [1:0]  last_awburst; 

  function new(string name="axi_write_burst_seq");
    super.new(name);
  endfunction

  task body();
  
    axi_write_txn tx;
    
    repeat (1) begin
      tx = axi_write_txn::type_id::create("tx");
      start_item(tx);
      tx.randomize(); 
      last_awaddr  = tx.awaddr;
      last_awlen   = tx.awlen;
      last_awsize  = tx.awsize;
      last_awburst = tx.awburst;
      finish_item(tx);
      
    end
  endtask
endclass
