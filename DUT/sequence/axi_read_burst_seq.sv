class axi_read_burst_seq extends uvm_sequence #(axi_read_txn);
  `uvm_object_utils(axi_read_burst_seq)

  bit [31:0] start_addr;
  bit [7:0]  start_len;
  bit [2:0]  start_size;
  bit [1:0]  start_burst;

  
  function new(string name="axi_read_burst_seq");
    super.new(name);
  endfunction

  task body();
     axi_read_txn rtx;
    repeat (1) begin
      rtx = axi_read_txn::type_id::create("tx");

      start_item(rtx);
      if (!rtx.randomize() with { araddr == start_addr;
                                  arlen   == start_len;
                                  arsize  == start_size;
                                  arburst == start_burst;})
        begin
        `uvm_error("READ_SEQ", "Randomization failed")
      end
      finish_item(rtx);
    end
  endtask

endclass
