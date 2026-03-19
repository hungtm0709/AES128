`timescale 1ns / 1ps

module tb_aes_datapath_v3;

    // --- 1. Signal Declarations ---
    reg          clk;
    reg          rst_n;
    reg          phase;
    reg  [3:0]   round_ctr;
    reg          is_first_round;
    reg  [127:0] plaintext;
    reg  [127:0] round_key;
    wire [127:0] ciphertext;

    // --- 2. DUT Instantiation ---
    aes_datapath_v3 uut (
        .clk            (clk),
        .rst_n          (rst_n),
        .phase          (phase),
        .round_ctr      (round_ctr),
        .is_first_round (is_first_round),
        .plaintext      (plaintext),
        .round_key      (round_key),
        .ciphertext     (ciphertext)
    );

    // --- 3. Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // --- 4. Test Vectors ---
    reg [127:0] keys [0:10];
    reg [127:0] expected_ciphertext;
    integer i;

    // --- 5. Test Scenario ---
    initial begin
        // Load the 11 Keys (From your verified Key Expansion test)
        keys[0]  = 128'h5468617473206D79204B756E67204675;
        keys[1]  = 128'hE232FCF191129188B159E4E6D679A293;
        keys[2]  = 128'h56082007C71AB18F76435569A03AF7FA;
        keys[3]  = 128'hD2600DE7157ABC686339E901C3031EFB;
        keys[4]  = 128'hA11202C9B468BEA1D75157A01452495B;
        keys[5]  = 128'hB1293B3305418592D210D232C6429B69;
        keys[6]  = 128'hBD3DC287B87C47156A6C9527AC2E0E4E; // Corrected Key 6
        keys[7]  = 128'hCC96ED1674EAAA031E863F24B2A8316A;
        keys[8]  = 128'h8E51EF21FABB4522E43D7A0656954B6C;
        keys[9]  = 128'hBFE2BF904559FAB2A16480B4F7F1CBD8;
        keys[10] = 128'h28FDDEF86DA4244ACCC0A4FE3B316F26;

        // Plaintext and Expected Final Ciphertext (Your "round 11")
        plaintext           = 128'h54776F204F6E65204E696E652054776F;
        expected_ciphertext = 128'h29C3505F571420F6402299B31A02D73A;

        $display("========================================");
        $display("   STARTING AES DATAPATH TEST");
        $display("========================================");

        // --- STEP 1: INITIALIZATION ---
        rst_n          = 0;
        phase          = 0;
        round_ctr      = 0;
        is_first_round = 0;
        plaintext      = 128'd0;
        round_key      = 128'd0;
        #15 rst_n      = 1;

        // --- STEP 2: ROUND 0 (Initial AddRoundKey) ---
        @(negedge clk);
        is_first_round = 1;
        plaintext      = 128'h54776F204F6E65204E696E652054776F;
        round_key      = keys[0];
        
        @(negedge clk);
        is_first_round = 0; // Turn off initial flag. State_reg now holds Plaintext ^ Key0

        // --- STEP 3: MAIN AES ROUNDS (1 to 10) ---
        for (i = 1; i <= 10; i = i + 1) begin
            round_ctr = i;

            // Phase 0: Calculate SubBytes + ShiftRows -> store to pipe_reg
            phase = 0;
            @(negedge clk);

            // Phase 1: Calculate MixColumns + AddRoundKey -> store to state_reg
            phase = 1;
            round_key = keys[i]; // Provide the new round key!
            @(negedge clk);
            
            // Optional: Print intermediate state here if you want to trace it
            // $display("Round %0d Done.", i);
        end

        // --- STEP 4: VERIFY FINAL CIPHERTEXT ---
        // After round 10, phase 1 completes, ciphertext reg is updated on the clock edge.
        // Wait one more negedge to safely read the registered output.
        @(negedge clk);
        
        $display("========================================");
        if (ciphertext === expected_ciphertext) begin
            $display("   [SUCCESS] CIPHERTEXT MATCHED!");
            $display("   Result: %h", ciphertext);
        end else begin
            $display("   [FAILED] CIPHERTEXT MISMATCH!");
            $display("   Expected: %h", expected_ciphertext);
            $display("   Actual  : %h", ciphertext);
        end
        $display("========================================");

        #20 $stop;
    end

endmodule
