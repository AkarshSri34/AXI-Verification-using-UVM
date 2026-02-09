`include "uvm_macros.svh"
//`include "test.sv"
//`include "transaction.sv"
`include "file_list.svh"
import uvm_pkg::*;
module top;

  axi_if axi_vif();

  // Clock
  initial begin
    axi_vif.ACLK = 0;
    forever #5 axi_vif.ACLK = ~axi_vif.ACLK;
  end

  // Reset
  initial begin
    axi_vif.ARESETn = 0;
    #20 axi_vif.ARESETn = 1;
  end
  
//   initial begin
//   axi_vif.AWREADY = 1;
//   axi_vif.WREADY  = 1;
//   axi_vif.BVALID  = 1;
//   axi_vif.BRESP   = 2'b00;
// end


  initial begin
    uvm_config_db #(virtual axi_if)::set(null, "*", "vif", axi_vif);
    run_test("axi_write_test");
  end
  
  initial begin
  $dumpfile("dump.vcd"); 
  $dumpvars;
  #1000 $finish;
end


endmodule

