class axi_slave_driver extends uvm_driver #(axi_slave_txn);
  `uvm_component_utils(axi_slave_driver)

  virtual axi_if vif;
  
  bit [3:0] saved_awid;
  bit [3:0] saved_arid;
  

  bit [31:0] mem [0:1023];
  
  int wcount;
  logic [31:0] waddr_base;

  // WRITE FSM
  typedef enum {W_IDLE, W_DATA, W_RESP} w_state_t;
  w_state_t wstate;

  // READ FSM
  typedef enum {R_IDLE, R_DATA} r_state_t;
  r_state_t rstate;

  int rcount;
  
  function new(string n, uvm_component p);
    super.new(n,p);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif))
      `uvm_fatal("SLV_DRV", "Virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);

    // ---------------- RESET VALUES ----------------
    wstate = W_IDLE;
    rstate = R_IDLE;
    rcount = 0;
    
    wcount      = 0;
    waddr_base  = 0;

    vif.AWREADY <= 0;
    vif.WREADY  <= 0;
    vif.BVALID  <= 0;
    vif.BRESP   <= 2'b00;

    vif.ARREADY <= 0;
    vif.RVALID  <= 0;
    vif.RLAST   <= 0;
    vif.RDATA   <= '0;
    vif.RRESP   <= 2'b00;

    wait (vif.ARESETn);

    // ---------------- MAIN SLAVE LOOP ----------------
    forever begin
      @(posedge vif.ACLK);

      // ==================================================
      // WRITE CHANNEL FSM
      // ==================================================
      case (wstate)

        // -------- WRITE IDLE --------
        W_IDLE: begin
          vif.AWREADY <= 1;
          vif.WREADY  <= 0;
          vif.BVALID  <= 0;

          if (vif.AWVALID && vif.AWREADY) begin
            saved_awid <= vif.AWID;
            vif.AWREADY <= 0;
            waddr_base  <= vif.AWADDR;   // <<< SAVE ADDRESS
            wcount      <= 0;
            wstate <= W_DATA;
          end
        end

        // -------- WRITE DATA --------
        W_DATA: begin
          vif.WREADY <= 1;

          if (vif.WVALID && vif.WREADY && vif.WLAST) begin
            vif.WREADY <= 0;
            wstate <= W_RESP;
          end
        end

        // -------- WRITE RESPONSE --------
        W_RESP: begin
          vif.BVALID <= 1;

          if (vif.BVALID && vif.BREADY) begin
            vif.BVALID <= 0;
            vif.BID    <= saved_awid;
            wstate <= W_IDLE;
          end
        end

      endcase

      // ==================================================
      // READ CHANNEL FSM
      // ==================================================
      case (rstate)

        // -------- READ IDLE --------
        R_IDLE: begin
          vif.ARREADY <= 1;
          vif.RVALID  <= 0;
          vif.RLAST   <= 0;
          rcount      <= 0;

          if (vif.ARVALID && vif.ARREADY) begin
            saved_arid <= vif.ARID;
            vif.ARREADY <= 0;
            vif.RVALID  <= 1;
            rstate <= R_DATA;
          end
        end

        // -------- READ DATA --------
        R_DATA: begin
          if (vif.RVALID && vif.RREADY) begin
            vif.RDATA <= $random;
            vif.RID   <= saved_arid;
            rcount++;

            if (rcount == vif.ARLEN) begin
              vif.RLAST  <= 1;
              vif.RVALID <= 0;
              vif.RLAST  <= 0;
              vif.ARREADY <= 1;
              rstate <= R_IDLE;
            end
          end
        end

      endcase

    end
  endtask

endclass
