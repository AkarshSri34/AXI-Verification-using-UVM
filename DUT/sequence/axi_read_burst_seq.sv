class axi_read_burst_seq extends uvm_sequence #(axi_read_txn);
  `uvm_object_utils(axi_read_burst_seq)

  function new(string name="axi_read_burst_seq");
    super.new(name);
  endfunction

  task body();
    axi_read_txn tx;

    repeat (3) begin
      tx = axi_read_txn::type_id::create("tx");

      start_item(tx);
      if (!tx.randomize()) begin
        `uvm_error("READ_SEQ", "Randomization failed")
      end
      finish_item(tx);
    end
  endtask

endclass
