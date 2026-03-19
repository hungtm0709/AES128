`timescale 1ns / 1ps

module tb_aes_mix_columns;

    // --- 1. Signal Declarations ---
    reg  [31:0] tb_in_data;
    wire [31:0] tb_out_data;

    // --- 2. Device Under Test (DUT) Instantiation ---
    aes_mix_columns uut (
        .mix_col_in  (tb_in_data),
        .mix_col_out (tb_out_data)
    );

    // --- 3. Self-Checking Task ---
    task run_test_vector;
        input [31:0] test_input;
        input [31:0] expected_output;
        begin
            tb_in_data = test_input;  
            #10;                     
            
            // Compare actual vs expected
            if (tb_out_data === expected_output) begin
                $display("[PASS] In: %h | Out: %h", test_input, tb_out_data);
            end else begin
                $display("[FAIL] In: %h | EXPECTED: %h | ACTUAL: %h", 
                         test_input, expected_output, tb_out_data);
            end
        end
    endtask

    // --- 4. Test Scenario ---
    initial begin
        $display("========================================");
        $display("   STARTING 32-BIT MIX COLUMNS TEST");
        $display("========================================");
        
        // Col 1: d4 bf 5d 30 -> 04 66 81 e5
        run_test_vector(32'hd4bf5d30, 32'h046681e5);
        
        // Col 2: e0 b4 52 ae -> e0 cb 19 9a
        run_test_vector(32'he0b452ae, 32'he0cb199a);
        
        // Col 3: b8 41 11 f1 -> 48 f8 d3 7a
        run_test_vector(32'hb84111f1, 32'h48f8d37a);
        
        // Col 4: 1e 27 98 e5 -> 28 06 26 4c
        run_test_vector(32'h1e2798e5, 32'h2806264c);

        $display("========================================");
        $display("   TEST COMPLETED!");
        $display("========================================");
        
        #20 $stop; // Pause simulation
    end

endmodule