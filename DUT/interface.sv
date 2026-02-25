interface axi_if;

  // Global Signals
  logic        ACLK;
  logic        ARESETn;

  // Write Address Channel
  logic [31:0] AWADDR;
  logic [7:0]  AWLEN;
  logic [2:0]  AWSIZE;
  logic [1:0]  AWBURST;
  logic        AWVALID;
  logic        AWREADY;

  // Write Data Channel
  logic [31:0] WDATA;
  logic [3:0]  WSTRB;
  logic        WLAST;
  logic        WVALID;
  logic        WREADY;

  // Write Response Channel
  logic [1:0]  BRESP;
  logic        BVALID;
  logic        BREADY;

/////////////////    AXI ASSERTIONS  ////////////////////////
property aw_stable_during_backpressure;
  @(posedge ACLK)
  disable iff (!ARESETn)
  (AWVALID && !AWREADY) |-> ##1 $stable({AWADDR, AWLEN, AWSIZE, AWBURST, AWID});
endproperty

assert property (aw_stable_during_backpressure)
  else `uvm_error("AXI_AW_ASSERT",
                  $sformatf("AW channel changed during backpressure at %0t", $time));


sequence w_hold_seq;
  (WVALID && $stable({WDATA, WSTRB, WLAST})) throughout (!WREADY);
endsequence

property w_stable_during_backpressure;

  @(posedge ACLK)
  disable iff (!ARESETn)
  (WVALID && !WREADY) |->  ##1 w_hold_seq;
endproperty

assert property (w_stable_during_backpressure)
else `uvm_error("AXI_W_ASSERT",$sformatf("W channecl during backpressure at %0t",$time));
  
endinterface
