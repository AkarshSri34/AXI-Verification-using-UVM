class axi_read_burst_seq extends uvm_sequence #(axi_read_txn);
  `uvm_object_utils(axi_read_burst_seq)

  // Receive write transactions from test
  axi_write_txn write_queue[$];

  function new(string name="axi_read_burst_seq");
    super.new(name);
  endfunction

  task body();
    axi_read_txn rtx;

    foreach (write_queue[i]) begin

      rtx = axi_read_txn::type_id::create($sformatf("rtx_%0d", i));

      start_item(rtx);

      if (!rtx.randomize() with {
            araddr  == write_queue[i].awaddr;
            arlen   == write_queue[i].awlen;
            arsize  == write_queue[i].awsize;
            arburst == write_queue[i].awburst;
          })
      begin
        `uvm_error("READ_SEQ", "Randomization failed")
      end

      finish_item(rtx);

    end
  endtask
endclass

