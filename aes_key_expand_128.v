module aes_key_expand_128 (
    input  wire [127:0] old_key, 
    input  wire [7:0]   rcon,    
    output wire [127:0] new_key  
);

    wire [31:0] w0, w1, w2, w3;
    
    assign w0 = old_key[127:96];
    assign w1 = old_key[95:64];
    assign w2 = old_key[63:32];
    assign w3 = old_key[31:0];

    wire [31:0] rot_w3;
    assign rot_w3 = {w3[23:0], w3[31:24]};

    wire [31:0] sub_w3;
    
    aes_sbox_v2 sbox_k0 (.sbox_in(rot_w3[31:24]), .sbox_out(sub_w3[31:24]));
    aes_sbox_v2 sbox_k1 (.sbox_in(rot_w3[23:16]), .sbox_out(sub_w3[23:16]));
    aes_sbox_v2 sbox_k2 (.sbox_in(rot_w3[15:8]),  .sbox_out(sub_w3[15:8]));
    aes_sbox_v2 sbox_k3 (.sbox_in(rot_w3[7:0]),   .sbox_out(sub_w3[7:0]));


    wire [31:0] g_out;
    assign g_out = sub_w3 ^ {rcon, 24'h000000}; 

    wire [31:0] new_w0, new_w1, new_w2, new_w3;

    assign new_w0 = w0 ^ g_out;    // w'[0] = w[0] ^ g(w[3])
    assign new_w1 = w1 ^ new_w0;   // w'[1] = w[1] ^ w'[0]
    assign new_w2 = w2 ^ new_w1;   // w'[2] = w[2] ^ w'[1]
    assign new_w3 = w3 ^ new_w2;   // w'[3] = w[3] ^ w'[2]

    assign new_key = {new_w0, new_w1, new_w2, new_w3};

endmodule