class axi_slave_driver extends uvm_driver #(axi_slave_txn);
  `uvm_component_utils(axi_slave_driver)

  virtual axi_if vif;

  typedef enum {IDLE, DATA, RESP} state_t;
  state_t state;

  function new(string n, uvm_component p);
    super.new(n,p);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_db#(virtual axi_if)::get(this,"","vif",vif);
  endfunction

  task run_phase(uvm_phase phase);
    state = IDLE;

    // RESET VALUES
    vif.AWREADY <= 0;
    vif.WREADY  <= 0;
    vif.BVALID  <= 0;
    vif.BRESP   <= 2'b00;
   // vif.WLAST   <= 0;

    wait(vif.ARESETn);

    forever begin
      @(posedge vif.ACLK);
      case (state)

        // ---------------- IDLE ----------------
        IDLE: begin
          vif.AWREADY <= 1;
          vif.WREADY  <= 0;
          vif.BVALID  <= 0;
		  vif.WLAST   <= 0;
          if (vif.AWVALID && vif.AWREADY) begin
            vif.AWREADY <= 0;
            state <= DATA;
          end
        end

        // ---------------- DATA ----------------
        DATA: begin
          vif.WREADY <= 1;

          if (vif.WVALID && vif.WREADY && vif.WLAST) begin
            vif.WREADY <= 0;
            state <= RESP;
          end
        end

        // ---------------- RESP ----------------
        RESP: begin
          vif.BVALID <= 1;

          if (vif.BVALID && vif.BREADY) begin
            vif.BVALID <= 0;
            state <= IDLE;
          end
        end

      endcase
    end
  endtask
endclass
