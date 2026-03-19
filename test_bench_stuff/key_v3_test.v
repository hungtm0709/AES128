`timescale 1ns / 1ps

module tb_aes_key_expand_v3;

    // --- 1. Signal Declarations ---
    reg          clk;
    reg          rst_n;
    reg          k_ld;
    reg          phase;
    reg  [127:0] key_in;
    wire [127:0] key_out;

    // --- 2. DUT Instantiation ---
    aes_key_expand_v3 uut (
        .clk     (clk),
        .rst_n   (rst_n),
        .k_ld    (k_ld),
        .phase   (phase),
        .key_in  (key_in),
        .key_out (key_out)
    );

    // --- 3. Test Vectors Setup ---
    reg [127:0] expected_keys [0:10]; // M?ng ch?a 11 Key (0 là g?c, 1-10 là m? r?ng)
    integer i;
    integer error_count;

    // --- 4. C? máy t?o xung Clock (Heartbeat) ---
    // Ch?y song song v?nh vi?n: C? 5ns ??o tr?ng thái 1 l?n -> Chu k? 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // --- 5. K?ch b?n mô ph?ng chính ---
    initial begin
        // N?p "Phao thi" th?ng vào m?ng (Hardcode cho ti?n, vì ch? có 11 s?)
        expected_keys[0]  = 128'h5468617473206D79204B756E67204675; // Initial Key
        expected_keys[1]  = 128'hE232FCF191129188B159E4E6D679A293; // Round 1
        expected_keys[2]  = 128'h56082007C71AB18F76435569A03AF7FA; // Round 2
        expected_keys[3]  = 128'hD2600DE7157ABC686339E901C3031EFB; // Round 3
        expected_keys[4]  = 128'hA11202C9B468BEA1D75157A01452495B; // Round 4
        expected_keys[5]  = 128'hB1293B3305418592D210D232C6429B69; // Round 5
        expected_keys[6]  = 128'hBD3DC287B87C47156A6C9527AC2E0E4E; // Round 6
        expected_keys[7]  = 128'hCC96ED1674EAAA031E863F24B2A8316A; // Round 7
        expected_keys[8]  = 128'h8E51EF21FABB4522E43D7A0656954B6C; // Round 8
        expected_keys[9]  = 128'hBFE2BF904559FAB2A16480B4F7F1CBD8; // Round 9
        expected_keys[10] = 128'h28FDDEF86DA4244ACCC0A4FE3B316F26; // Round 10

        error_count = 0;

        // B??C 1: RESET H? TH?NG
        $display("=== STARTING KEY EXPANSION TEST ===");
        rst_n = 0;
        k_ld = 0;
        phase = 0;
        key_in = 128'd0;
        #15;          // ??i m?t chút cho Reset ng?m
        rst_n = 1;    // Nh? Reset

        // B??C 2: LOAD KEY G?C VÀO
        @(negedge clk); // C?n ?úng s??n âm ?? b?m tín hi?u
        k_ld = 1;
        key_in = expected_keys[0];
        
        @(negedge clk); // ??i qua 1 nh?p clock ?? Key n?p vào thanh ghi
        k_ld = 0;
        
        // Ki?m tra xem Key g?c có phi ra th?ng output ch?a
        if (key_out !== expected_keys[0]) begin
            $display("[FAIL] Initial Key Load Failed! Expected: %h, Got: %h", expected_keys[0], key_out);
            error_count = error_count + 1;
        end else begin
            $display("[OK] Initial Key Loaded Successfully.");
        end

        // B??C 3: KI?M TRA 10 VÒNG M? R?NG (Dùng Phase 0 và Phase 1)
        for (i = 1; i <= 10; i = i + 1) begin
            
            // --- C?p Phase 0 ---
            @(negedge clk);
            phase = 0; 
            // Khi s??n d??ng ti?p theo ??p, DUT s? tính g() và l?u vào g_result

            // --- C?p Phase 1 ---
            @(negedge clk);
            phase = 1;
            // Ngay khi phase = 1, l?nh assign next_key_comb nh?y s? ngay l?p t?c!
            // Chúng ta có th? ??c k?t qu? key_out ngay t?i ?ây (ch? ??i #1 cho dòng ?i?n lan truy?n)
            #1; 
            
            if (key_out !== expected_keys[i]) begin
                $display("[FAIL] Round %0d Key Error!", i);
                $display("       Expected: %h", expected_keys[i]);
                $display("       Actual  : %h", key_out);
                error_count = error_count + 1;
            end else begin
                $display("[OK] Round %0d Key MATCHED!", i);
            end

            // S??n d??ng ti?p theo ??p, DUT s? l?u next_key_comb vào key_reg chính th?c.
            // S?n sàng cho vòng l?p ti?p theo.
        end

        // --- Báo cáo k?t qu? ---
        $display("========================================");
        if (error_count == 0)
            $display("   [SUCCESS] ALL 11 KEYS MATCHED!");
        else
            $display("   [FAILED] %0d ERRORS FOUND!", error_count);
        $display("========================================");
        
        #20 $stop;
    end

endmodule
