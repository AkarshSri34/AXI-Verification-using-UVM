class axi_slave_driver extends uvm_driver #(axi_slave_txn);
  `uvm_component_utils(axi_slave_driver)

  virtual axi_if vif;
  
  bit [3:0] saved_awid;
  bit [3:0] saved_arid;
  bit [7:0] saved_arlen;
  

  bit [31:0] mem [0:1023];    // MEMORY //
  
  int rcount;
  int wcount;
  logic [31:0] waddr_base;
  logic [31:0] raddr_base;

  // WRITE FSM
  typedef enum {W_IDLE, W_DATA, W_RESP} w_state_t;
  w_state_t wstate;

  // READ FSM
  typedef enum {R_IDLE, R_DATA} r_state_t;
  r_state_t rstate;

  
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

          if (vif.WVALID && vif.WREADY ) begin
             mem[((waddr_base >> 2) + wcount) % 1024] <= vif.WDATA; // WRITE EVERY BEAT
            wcount++;
            
            $display("WRITE: addr=%h index=%0d data=%h",waddr_base,(waddr_base >> 2) + wcount,vif.WDATA);
            
            if (vif.WLAST) begin
              vif.WREADY <= 0;
              wstate <= W_RESP;
            end
          end
        end

        // -------- WRITE RESPONSE --------
        W_RESP: begin
          vif.BVALID <= 1;
          vif.BID    <= saved_awid;

          if (vif.BREADY) begin
            vif.BVALID <= 0;
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
            saved_arid   <= vif.ARID;
            saved_arlen  <= vif.ARLEN;     // <<< SAVE ARLEN
            raddr_base   <= vif.ARADDR;    // <<< FIX ADDRESS ALSO
            vif.ARREADY  <= 0;
            vif.RVALID   <= 1;
            rcount       <= 0;
            rstate       <= R_DATA;
          end
        end

        // ------------------------------ READ DATA -----------------------------------
        R_DATA: begin
          vif.RVALID <= 1;
          vif.RID    <= saved_arid;
          vif.RRESP  <= 2'b00;
          
          vif.RDATA <= mem[((raddr_base >> 2) + rcount) % 1024];
          
          $display("READ: addr=%h index=%0d data=%h",raddr_base,(raddr_base >> 2) + rcount,mem[(raddr_base >> 2) + rcount]);


          if (vif.RVALID && vif.RREADY) begin
           // vif.RDATA <= mem[(raddr_base >> 2) + rcount];
            //vif.RDATA   <= vif.WDATA;
            if (rcount == saved_arlen) begin
              vif.RLAST   <= 1;
              rstate      <= R_IDLE;
              vif.ARREADY <=1;
              rcount      <=0;
            end
            else begin
              vif.RLAST <= 0;
              rcount++;
            end

//             else begin
//               rcount++;
//       		  vif.RLAST <= 0;
//             end
          end
        end
      endcase

    end
  endtask

endclass

