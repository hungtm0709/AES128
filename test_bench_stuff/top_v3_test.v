`timescale 1ns / 1ps

module tb_aes_top_v3_debug_pro;

    // --- 1. Signal Declarations ---
    reg          clk;
    reg          rst_n;
    reg          start;
    reg  [127:0] plaintext;
    reg  [127:0] key;
    
    wire [127:0] ciphertext;
    wire         done;

    // --- 2. DUT Instantiation ---
    aes_top_v3 uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .plaintext  (plaintext),
        .key        (key),
        .ciphertext (ciphertext),
        .done       (done)
    );

    // --- 3. Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // --- 4. Expected Data ---
    reg [127:0] expected_ciphertext = 128'h3925841D02DC09FBDC118597196A0B32;
    reg test_running; // Flag to enable/disable printing

    // --- 5. The Ultimate Debug Engine (Probing internal nodes) ---
    // Sample at the NEGATIVE edge so all logic from the POSITIVE edge has settled.
    always @(negedge clk) begin
        if (test_running) begin
            $display("====================================================================================================");
            $display(" TIME: %6t ns | ROUND: %2d | PHASE: %b | FSM_STATE: %b | IS_FIRST_ROUND: %b", 
                     $time, 
                     uut.u_control.round_ctr, 
                     uut.u_control.phase, 
                     uut.u_control.state, 
                     uut.u_control.is_first_round);
            $display("----------------------------------------------------------------------------------------------------");
            
            // --- KEY EXPANSION MODULE PROBES ---
            $display(" [KEY EXPAND]  Key_In_Port    : %h", uut.u_key_expand.key_in);
            // Note: If your key_expand_v3 uses different register names, update them below:
            $display(" [KEY EXPAND]  Key_Reg        : %h", uut.u_key_expand.key_reg); 
            $display(" [KEY EXPAND]  g() func output: %h", uut.u_key_expand.g_result);
            $display(" [KEY EXPAND]  >> ROUND KEY   : %h", uut.u_key_expand.key_out);
            $display("----------------------------------------------------------------------------------------------------");

            // --- DATAPATH MODULE PROBES ---
            // Phase 0 outputs (Combinational)
            $display(" [DATAPATH]    SBox_Out       : %h", uut.u_datapath.sbox_out);
            $display(" [DATAPATH]    ShiftRows_Out  : %h", uut.u_datapath.shift_rows_out);
            
            // Pipeline Register (Latches Phase 0 result)
            $display(" [DATAPATH] => PIPE_REG       : %h", uut.u_datapath.pipe_reg);
            
            // Phase 1 outputs (Combinational)
            $display(" [DATAPATH]    MixColumns_Out : %h", uut.u_datapath.mix_columns_out);
            $display(" [DATAPATH]    Next_State     : %h", uut.u_datapath.next_state_logic);
            
            // State Register (Latches Phase 1 result)
            $display(" [DATAPATH] => STATE_REG      : %h", uut.u_datapath.state_reg);
            $display("====================================================================================================\n");
        end
    end

    // --- 6. Main Test Scenario ---
    initial begin
        // Initialize signals
        test_running = 0;
        rst_n        = 0;
        start        = 0;
        plaintext    = 128'd0;
        key          = 128'd0;

        $display("\n******************************************************************");
        $display("   STARTING DEEP PIPELINE DEBUG FOR AES TOP MODULE (PRO MAX)");
        $display("******************************************************************\n");

        // Apply Reset
        #15 rst_n = 1;
        #10;

        // Load Data and Trigger Start
        @(negedge clk);
        plaintext    = 128'h3243F6A8885A308D313198A2E0370734; 
        key          = 128'h2B7E151628AED2A6ABF7158809CF4F3C; 
        start        = 1;
        
        // Turn on the printing engine
        test_running = 1; 
        
        @(negedge clk);
        start        = 0; // De-assert start (pulse only 1 cycle)

        // Wait for the FSM to signal 'done'
        @(posedge done);
        
        // Wait two more cycles to print the final states cleanly
        @(negedge clk);
        @(negedge clk);
        test_running = 0; // Turn off the printing engine

        // --- Final Verification ---
        $display("\n******************************************************************");
        if (ciphertext === expected_ciphertext) begin
            $display("   [SUCCESS] CIPHERTEXT MATCHED EXACTLY!");
        end else begin
            $display("   [FAILED] CIPHERTEXT MISMATCH DETECTED.");
        end
        $display("   Expected : %h", expected_ciphertext);
        $display("   Actual   : %h", ciphertext);
        $display("******************************************************************\n");

        #20 $stop;
    end

endmodule
