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

endinterface
