`timescale 1ns / 1ps

module tb_aes_sbox_v2;

    // --- 1. Signal Declarations ---
    reg  [7:0] tb_in_data;
    wire [7:0] tb_out_data;

    // --- 2. DUT (Device Under Test) Instantiation ---
    aes_sbox_v2 uut (
        .sbox_in  (tb_in_data),
        .sbox_out (tb_out_data)
    );

    // --- 3. Memory Array and Variables ---
    reg [7:0] sbox_expected [0:255]; // Array to hold 256 expected 8-bit values
    integer i;                       // Loop iterator
    integer error_count;             // Error counter

    // --- 4. Test Scenario ---
    initial begin
        $display("========================================");
        $display("   STARTING EXHAUSTIVE S-BOX TEST");
        $display("========================================");
        
        // Load expected data from text file into memory array
        // Note: sbox_ref.txt must be in the simulation directory
        $readmemh("sbox.txt", sbox_expected);
        
        error_count = 0; // Initialize error count

        // Exhaustive loop: sweep input from 0 to 255
        for (i = 0; i < 256; i = i + 1) begin
            tb_in_data = i; // Apply stimulus
            #10;            // Wait for combinational logic delay
            
            // Self-checking logic
            if (tb_out_data !== sbox_expected[i]) begin
                $display("[FAIL] In: %02x | Expected: %02x | Actual: %02x", 
                         tb_in_data, sbox_expected[i], tb_out_data);
                error_count = error_count + 1;
            end
        end

        // Final Report
        $display("========================================");
        if (error_count == 0) begin
            $display("   [SUCCESS] ALL 256 CASES PASSED!");
        end else begin
            $display("   [FAILED] FOUND %0d ERRORS!", error_count);
        end
        $display("========================================");
        
        #20 $stop; // Stop simulation
    end

endmodule
