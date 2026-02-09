class axi_driver extends uvm_driver #(axi_write_txn);
  `uvm_component_utils(axi_driver)

  virtual axi_if vif;

  function new(string n, uvm_component p);
    super.new(n,p);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_db#(virtual axi_if)::get(this,"","vif",vif);
  endfunction

  task run_phase(uvm_phase phase);
    axi_write_txn tx;
    vif.AWVALID <= 0;
    vif.WVALID  <= 0;
    vif.WLAST   <= 0;
    vif.BREADY  <= 0;
    vif.WSTRB   <= '0;
    vif.WDATA   <= '0;
    wait (vif.ARESETn);   // wait for reset release
  @(posedge vif.ACLK);  // align to clock
    
    forever begin
      seq_item_port.get_next_item(tx);
      drive_aw(tx);
      drive_w(tx);
      drive_b(tx);
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

  task drive_b(axi_write_txn tx);
    @(posedge vif.ACLK);
    vif.BREADY <= 1;
    do @(posedge vif.ACLK); while (!vif.BVALID);
    tx.bresp = vif.BRESP;
    vif.BREADY <= 0;
  endtask
endclass
