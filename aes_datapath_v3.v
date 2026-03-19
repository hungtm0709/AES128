module aes_datapath_v3 (
    input  wire         clk,
    input  wire         rst_n,
    
    // Control Inputs
    input  wire         phase,          
    input  wire [3:0]   round_ctr,
    input  wire         is_first_round, 
    
    // Data Inputs
    input  wire [127:0] plaintext,
    input  wire [127:0] round_key,    
    
    // Output
    output reg  [127:0] ciphertext
);

    // thanh ghi trung gian
    reg  [127:0] state_reg; 
    reg  [127:0] pipe_reg;  
    
    wire [127:0] sbox_out;
    wire [127:0] shift_rows_out;
    
    // MixColumns in/out cho tung word
    wire [31:0] mc0_in, mc1_in, mc2_in, mc3_in;
    wire [31:0] mc0_out, mc1_out, mc2_out, mc3_out;
    wire [127:0] mix_columns_out;

    wire [127:0] next_state_logic;
    
    // SubBytes 
    aes_sbox_v2 sb00 (.sbox_in(state_reg[7:0]),     .sbox_out(sbox_out[7:0]));
    aes_sbox_v2 sb01 (.sbox_in(state_reg[15:8]),    .sbox_out(sbox_out[15:8]));
    aes_sbox_v2 sb02 (.sbox_in(state_reg[23:16]),   .sbox_out(sbox_out[23:16]));
    aes_sbox_v2 sb03 (.sbox_in(state_reg[31:24]),   .sbox_out(sbox_out[31:24]));
    
    aes_sbox_v2 sb04 (.sbox_in(state_reg[39:32]),   .sbox_out(sbox_out[39:32]));
    aes_sbox_v2 sb05 (.sbox_in(state_reg[47:40]),   .sbox_out(sbox_out[47:40]));
    aes_sbox_v2 sb06 (.sbox_in(state_reg[55:48]),   .sbox_out(sbox_out[55:48]));
    aes_sbox_v2 sb07 (.sbox_in(state_reg[63:56]),   .sbox_out(sbox_out[63:56]));
    
    aes_sbox_v2 sb08 (.sbox_in(state_reg[71:64]),   .sbox_out(sbox_out[71:64]));
    aes_sbox_v2 sb09 (.sbox_in(state_reg[79:72]),   .sbox_out(sbox_out[79:72]));
    aes_sbox_v2 sb10 (.sbox_in(state_reg[87:80]),   .sbox_out(sbox_out[87:80]));
    aes_sbox_v2 sb11 (.sbox_in(state_reg[95:88]),   .sbox_out(sbox_out[95:88]));
    
    aes_sbox_v2 sb12 (.sbox_in(state_reg[103:96]),  .sbox_out(sbox_out[103:96]));
    aes_sbox_v2 sb13 (.sbox_in(state_reg[111:104]), .sbox_out(sbox_out[111:104]));
    aes_sbox_v2 sb14 (.sbox_in(state_reg[119:112]), .sbox_out(sbox_out[119:112]));
    aes_sbox_v2 sb15 (.sbox_in(state_reg[127:120]), .sbox_out(sbox_out[127:120]));

    //ShiftRows
    aes_shift_rows u_shift (
        .shift_row_in  (sbox_out),
        .shift_row_out (shift_rows_out)
    );

    // MixColumns 
    assign mc0_in = pipe_reg[31:0];
    assign mc1_in = pipe_reg[63:32];
    assign mc2_in = pipe_reg[95:64];
    assign mc3_in = pipe_reg[127:96];

    aes_mix_columns mc0 (.mix_col_in(mc0_in), .mix_col_out(mc0_out));
    aes_mix_columns mc1 (.mix_col_in(mc1_in), .mix_col_out(mc1_out));
    aes_mix_columns mc2 (.mix_col_in(mc2_in), .mix_col_out(mc2_out));
    aes_mix_columns mc3 (.mix_col_in(mc3_in), .mix_col_out(mc3_out));

    assign mix_columns_out = {mc3_out, mc2_out, mc1_out, mc0_out};

    // Next_stage_reg logic
    assign next_state_logic = (round_ctr == 11) ? (pipe_reg ^ round_key) : 
                                                  (mix_columns_out ^ round_key);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg  <= 128'd0;
            pipe_reg   <= 128'd0;
            ciphertext <= 128'd0;
        end else begin
            if (is_first_round) begin
                state_reg <= plaintext ^ round_key; 
            end 
            else begin
                if (phase == 1) begin
                    pipe_reg <= shift_rows_out;
                end 
                else begin
                    state_reg <= next_state_logic;
                    
                    if (round_ctr == 11) begin
                        ciphertext <= next_state_logic;
                    end
                end
            end
        end
    end

endmodule