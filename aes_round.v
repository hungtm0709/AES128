module aes_round (
    input  wire [127:0] state_in,     
    input  wire [127:0] round_key,    
    input  wire         is_last_round, 
    output wire [127:0] state_out    
);

    wire [127:0] sub_out;

    aes_sbox_v2 s15 (.sbox_in(state_in[127:120]), .sbox_out(sub_out[127:120]));
    aes_sbox_v2 s14 (.sbox_in(state_in[119:112]), .sbox_out(sub_out[119:112]));
    aes_sbox_v2 s13 (.sbox_in(state_in[111:104]), .sbox_out(sub_out[111:104]));
    aes_sbox_v2 s12 (.sbox_in(state_in[103: 96]), .sbox_out(sub_out[103: 96]));
    
    aes_sbox_v2 s11 (.sbox_in(state_in[ 95: 88]), .sbox_out(sub_out[ 95: 88]));
    aes_sbox_v2 s10 (.sbox_in(state_in[ 87: 80]), .sbox_out(sub_out[ 87: 80]));
    aes_sbox_v2 s09 (.sbox_in(state_in[ 79: 72]), .sbox_out(sub_out[ 79: 72]));
    aes_sbox_v2 s08 (.sbox_in(state_in[ 71: 64]), .sbox_out(sub_out[ 71: 64]));

    aes_sbox_v2 s07 (.sbox_in(state_in[ 63: 56]), .sbox_out(sub_out[ 63: 56]));
    aes_sbox_v2 s06 (.sbox_in(state_in[ 55: 48]), .sbox_out(sub_out[ 55: 48]));
    aes_sbox_v2 s05 (.sbox_in(state_in[ 47: 40]), .sbox_out(sub_out[ 47: 40]));
    aes_sbox_v2 s04 (.sbox_in(state_in[ 39: 32]), .sbox_out(sub_out[ 39: 32]));

    aes_sbox_v2 s03 (.sbox_in(state_in[ 31: 24]), .sbox_out(sub_out[ 31: 24]));
    aes_sbox_v2 s02 (.sbox_in(state_in[ 23: 16]), .sbox_out(sub_out[ 23: 16]));
    aes_sbox_v2 s01 (.sbox_in(state_in[ 15:  8]), .sbox_out(sub_out[ 15:  8]));
    aes_sbox_v2 s00 (.sbox_in(state_in[  7:  0]), .sbox_out(sub_out[  7:  0]));

    wire [127:0] shift_out;
    aes_shift_rows u_shift_rows (
        .shift_row_in (sub_out),
        .shift_row_out(shift_out)
    );

    wire [31:0] col0_out, col1_out, col2_out, col3_out;
    wire [127:0] mix_out;

    aes_mix_columns mc0 (.mix_col_in(shift_out[127:96]), .mix_col_out(col0_out));
    aes_mix_columns mc1 (.mix_col_in(shift_out[ 95:64]), .mix_col_out(col1_out));
    aes_mix_columns mc2 (.mix_col_in(shift_out[ 63:32]), .mix_col_out(col2_out));
    aes_mix_columns mc3 (.mix_col_in(shift_out[ 31: 0]), .mix_col_out(col3_out));

    assign mix_out = {col0_out, col1_out, col2_out, col3_out};

    wire [127:0] pre_add_key;
    
    assign pre_add_key = (is_last_round) ? shift_out : mix_out;

    assign state_out = pre_add_key ^ round_key;

endmodule