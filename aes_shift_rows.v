module aes_shift_rows(
    input  wire [127:0] shift_row_in,
    output wire [127:0] shift_row_out
);


    assign shift_row_out[127:120] = shift_row_in[127:120]; // s0
    assign shift_row_out[119:112] = shift_row_in[87:80];   // s5
    assign shift_row_out[111:104] = shift_row_in[47:40];   // s10
    assign shift_row_out[103:96]  = shift_row_in[7:0];     // s15
    
    assign shift_row_out[95:88]   = shift_row_in[95:88];   // s4
    assign shift_row_out[87:80]   = shift_row_in[55:48];   // s9
    assign shift_row_out[79:72]   = shift_row_in[15:8];    // s14
    assign shift_row_out[71:64]   = shift_row_in[103:96];  // s3
    
    assign shift_row_out[63:56]   = shift_row_in[63:56];   // s8
    assign shift_row_out[55:48]   = shift_row_in[23:16];   // s13
    assign shift_row_out[47:40]   = shift_row_in[111:104]; // s2
    assign shift_row_out[39:32]   = shift_row_in[71:64];   // s7
    
    assign shift_row_out[31:24]   = shift_row_in[31:24];   // s12
    assign shift_row_out[23:16]   = shift_row_in[119:112]; // s1
    assign shift_row_out[15:8]    = shift_row_in[79:72];   // s6
    assign shift_row_out[7:0]     = shift_row_in[39:32];   // s11

endmodule