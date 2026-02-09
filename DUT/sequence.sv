class axi_write_burst_seq extends uvm_sequence #(axi_write_txn);
  `uvm_object_utils(axi_write_burst_seq)

  function new(string name="axi_write_burst_seq");
    super.new(name);
  endfunction

  task body();
    axi_write_txn tx;

    repeat (10) begin
      tx = axi_write_txn::type_id::create("tx");
      start_item(tx);
      tx.randomize();
      finish_item(tx);
    end
  endtask
endclass
