
class axi_read_txn extends axi_base_txn;
  `uvm_object_utils(axi_read_txn)

  rand bit [31:0] araddr;
  rand bit [7:0]  arlen;     // burst length - 1
  rand bit [2:0]  arsize;    // bytes per beat
  rand bit [1:0]  arburst;   // FIXED/INCR/WRAP
  rand bit [3:0]  arid;

  bit [31:0] rdata[];
  bit [1:0]  rresp[];
  bit [3:0]  rid[]; 

  constraint read_c {
    arburst == 2'b01;        // INCR
    arlen inside {[0:15]};   // max 16 beats
    arsize == 3'b010;        // 4 bytes
  }

  function new(string name="axi_read_txn");
    super.new(name);
  endfunction

endclass
