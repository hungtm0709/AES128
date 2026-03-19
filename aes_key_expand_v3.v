module aes_key_expand_v3 (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         k_ld,       // Load Key 
    input  wire         phase,  
    input  wire [127:0] key_in,     // Input Key
    
    output wire [127:0] key_out     // Output current loop key
);

    reg [127:0] key_reg;
    reg [31:0]  g_result;
    reg [7:0]   rcon;

    // Wires
    wire [31:0] w3, rot_w3, sub_w3, g_func;
    wire [31:0] w0, w1, w2;
    wire [31:0] new_w0, new_w1, new_w2, new_w3;
    wire [127:0] next_key_comb;

    // Calculate base Word
    assign w3 = key_reg[31:0];
    assign rot_w3 = {w3[23:0], w3[31:24]};

    aes_sbox_v2 ksb0 (.sbox_in(rot_w3[31:24]), .sbox_out(sub_w3[31:24]));
    aes_sbox_v2 ksb1 (.sbox_in(rot_w3[23:16]), .sbox_out(sub_w3[23:16]));
    aes_sbox_v2 ksb2 (.sbox_in(rot_w3[ 15:8]),  .sbox_out(sub_w3[15:8]));
    aes_sbox_v2 ksb3 (.sbox_in(rot_w3[  7:0]),   .sbox_out(sub_w3[7:0]));

    assign g_func = sub_w3 ^ {rcon, 24'h00};

    // Calculate every word left
    assign w0 = key_reg[127:96];
    assign w1 = key_reg[95:64];
    assign w2 = key_reg[63:32];

    assign new_w0 = w0 ^ g_result; 
    assign new_w1 = w1 ^ new_w0;
    assign new_w2 = w2 ^ new_w1;
    assign new_w3 = w3 ^ new_w2;   

    assign next_key_comb = {new_w0, new_w1, new_w2, new_w3};

    // OUTPUT LOGIC
    assign key_out = (phase == 1'b1) ? next_key_comb : key_reg;

    // --- SEQUENTIAL LOGIC ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_reg  <= 128'd0;
            g_result <= 32'd0;
            rcon     <= 8'h01;
        end else begin
            if (k_ld) begin
                key_reg <= key_in;
                rcon    <= 8'h01;
            end 
            else begin
                if (phase == 0) begin
					 //phase = 0
                    g_result <= g_func;
                end 
                else begin
					 //phase = 1
                    key_reg <= next_key_comb;
					 //calculate current loop rcon
                    if (rcon[7]) 
                        rcon <= (rcon << 1) ^ 8'h1b;
                    else 
                        rcon <= (rcon << 1);
                end
            end
        end
    end

endmodule