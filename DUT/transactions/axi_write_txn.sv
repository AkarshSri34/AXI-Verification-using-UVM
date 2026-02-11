class axi_write_txn extends axi_base_txn;
  `uvm_object_utils(axi_write_txn)
  
  rand bit [31:0] awaddr;
  rand bit [7:0]  awlen;     // burst length - 1
  rand bit [2:0]  awsize;    // bytes per beat
  rand bit [1:0]  awburst;   // FIXED/INCR/WRAP
  rand bit [3:0]  awid;

  rand bit [31:0] wdata[];
  rand bit [3:0]  wstrb[];

  bit [1:0] bresp;
  bit  [3:0]      bid;

  constraint burst_c {
    awburst == 2'b01;        // INCR
    awlen inside {[0:15]};   // up to 16 beats
    awsize == 3'b010;        // 4 bytes
    wdata.size() == awlen+1;
    wstrb.size() == awlen+1;
  }

  function new(string name="axi_write_txn");
    super.new(name);
  endfunction

endclass

