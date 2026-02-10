class axi_driver extends uvm_driver #(axi_base_txn);
  `uvm_component_utils(axi_driver)

  virtual axi_if vif;

  function new(string n, uvm_component p);
    super.new(n,p);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_db#(virtual axi_if)::get(this,"","vif",vif);
  endfunction

  task run_phase(uvm_phase phase);
    
    axi_write_txn wtx;
    axi_read_txn  rtx;
    axi_base_txn  btx;


  // Init signals
  vif.AWVALID <= 0;
  vif.WVALID  <= 0;
  vif.WLAST   <= 0;
  vif.BREADY  <= 0;
  vif.ARVALID <= 0;
  vif.RREADY  <= 0;

  wait(vif.ARESETn);
  @(posedge vif.ACLK);

  forever begin
    seq_item_port.get_next_item(btx);

    // WRITE transaction
    if ($cast(wtx, btx)) begin
      drive_aw(wtx);
      drive_w(wtx);
      drive_b(wtx);
    end

    // READ transaction
    else if ($cast(rtx, btx)) begin
      drive_ar(rtx);
      drive_r(rtx);
    end

    else begin
      `uvm_fatal("DRV", "Unknown AXI transaction type")
    end

    seq_item_port.item_done();
  end
endtask


  task drive_aw(axi_write_txn tx);
    @(posedge vif.ACLK);
    vif.AWVALID <= 1;
    vif.AWADDR  <= tx.awaddr;
    vif.AWLEN   <= tx.awlen;
    vif.AWSIZE  <= tx.awsize;
    vif.AWBURST <= tx.awburst;
    vif.AWID    <= tx.awid;

    do @(posedge vif.ACLK); while (!vif.AWREADY);
    vif.AWVALID <= 0;
  endtask

  task drive_w(axi_write_txn tx);
    foreach (tx.wdata[i]) begin
      @(posedge vif.ACLK);
      vif.WVALID <= 1;
      vif.WDATA  <= tx.wdata[i];
      vif.WSTRB  <= tx.wstrb[i];
      vif.WLAST  <= (i == tx.awlen);

      do @(posedge vif.ACLK); while (!vif.WREADY);
      vif.WVALID <= 0;
      vif.WLAST  <= 0;
    end
  endtask
  
  task drive_ar(axi_read_txn tx);
  @(posedge vif.ACLK);
  vif.ARVALID <= 1;
  vif.ARID    <= tx.arid; 
  vif.ARADDR  <= tx.araddr;
  vif.ARLEN   <= tx.arlen;
  vif.ARSIZE  <= tx.arsize;
  vif.ARBURST <= tx.arburst;

  do @(posedge vif.ACLK); while (!vif.ARREADY);
  vif.ARVALID <= 0;
endtask
  
  
task drive_r(axi_read_txn tx);
  tx.rdata = new[tx.arlen + 1];
  tx.rresp = new[tx.arlen + 1];

  for (int i = 0; i <= tx.arlen; i++) begin
    @(posedge vif.ACLK);
    vif.RREADY <= 1;

    do @(posedge vif.ACLK); while (!vif.RVALID);

    tx.rdata[i] = vif.RDATA;
    tx.rid[i]   = vif.RID;   
    tx.rresp[i] = vif.RRESP;

    if (vif.RLAST)
      break;
  end

  vif.RREADY <= 0;
endtask


  task drive_b(axi_write_txn tx);
    @(posedge vif.ACLK);
    vif.BREADY <= 1;
    do @(posedge vif.ACLK); while (!vif.BVALID);
    tx.bresp = vif.BRESP;
    tx.bid   = vif.BID;
    vif.BREADY <= 0;
  endtask
endclass


