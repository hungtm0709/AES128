module aes_sbox_v2 (
    input  wire [7:0] sbox_in,
    output wire [7:0] sbox_out
);

    //-----------------------------------------------------
    // 1. HELPER FUNCTIONS (GF Logic)
    //-----------------------------------------------------

    // Function: Multiply in GF(2^2)
    function [1:0] mul_gf22;
        input [1:0] a;
        input [1:0] b;
        begin
            mul_gf22[1] = (a[1] & b[1]) ^ (a[0] & b[1]) ^ (a[1] & b[0]);
            mul_gf22[0] = (a[1] & b[1]) ^ (a[0] & b[0]);
        end
    endfunction

    // Function: Multiply in GF(2^4) using GF(2^2)
    function [3:0] mul_gf24;
        input [3:0] op0;
        input [3:0] op1;
        reg [1:0] a_h, a_l, b_h, b_l;
        reg [1:0] a_xor, b_xor;
        reg [1:0] m_h, m_m, m_l; // High, Mid, Low parts
        reg [1:0] x_phi;
        begin
            a_h = op0[3:2]; a_l = op0[1:0];
            b_h = op1[3:2]; b_l = op1[1:0];
            
            a_xor = a_h ^ a_l;
            b_xor = b_h ^ b_l;
            
            // 3 Multiplications in GF(2^2)
            m_h = mul_gf22(a_h, b_h);
            m_m = mul_gf22(a_xor, b_xor);
            m_l = mul_gf22(a_l, b_l);
            
            // Multiply by Constant Phi (binary 10 in GF2^2)
            x_phi[1] = m_h[1] ^ m_h[0];
            x_phi[0] = m_h[1];
            
            // Recombine
            mul_gf24[3:2] = m_m ^ m_l;
            mul_gf24[1:0] = x_phi ^ m_l;
        end
    endfunction

    //-----------------------------------------------------
    // 2. INTERNAL SIGNALS
    //-----------------------------------------------------
    reg [7:0] iso_map;      // After Isomorphic Mapping
    reg [3:0] delta, gamma; // MSB and LSB of mapped value
    reg [3:0] delta_sq;     // Square of MSB
    reg [3:0] delta_lam;    // Multiplied by Lambda
    reg [3:0] sum_gam_del;  // Gamma + Delta
    reg [3:0] prod_sum;     // Product (Gam+Del)*Gam
    reg [3:0] inv_denom;    // Denominator to be inverted
    reg [3:0] inv_result;   // Inverted value in GF(2^4)
    reg [3:0] final_h;      // Final High nibble
    reg [3:0] final_l;      // Final Low nibble
    reg [7:0] inv_iso_map;  // After Inverse Isomorphic Mapping
    reg [7:0] affine_out;   // After Affine Transform

    //-----------------------------------------------------
    // 3. LOGIC IMPLEMENTATION
    //-----------------------------------------------------
    
    always @(*) begin
        // --- STEP 1: ISOMORPHIC MAPPING (Standard -> Composite) ---
        // Mapping matrix from standard GF(2^8) to GF((2^4)^2)
        iso_map[7] = sbox_in[7] ^ sbox_in[5];
        iso_map[6] = sbox_in[7] ^ sbox_in[6] ^ sbox_in[4] ^ sbox_in[3] ^ sbox_in[2] ^ sbox_in[1];
        iso_map[5] = sbox_in[7] ^ sbox_in[5] ^ sbox_in[3] ^ sbox_in[2];
        iso_map[4] = sbox_in[7] ^ sbox_in[5] ^ sbox_in[3] ^ sbox_in[2] ^ sbox_in[1];
        iso_map[3] = sbox_in[7] ^ sbox_in[6] ^ sbox_in[2] ^ sbox_in[1];
        iso_map[2] = sbox_in[7] ^ sbox_in[4] ^ sbox_in[3] ^ sbox_in[2] ^ sbox_in[1];
        iso_map[1] = sbox_in[6] ^ sbox_in[4] ^ sbox_in[1];
        iso_map[0] = sbox_in[6] ^ sbox_in[1] ^ sbox_in[0];

        delta = iso_map[7:4]; // MSB
        gamma = iso_map[3:0]; // LSB

        // --- STEP 2: INVERSION IN GF(2^4) ---
        // Formula: (gamma*delta + delta^2*lambda + gamma^2)^-1 ... complex logic simplified below:
        
        // Square of Delta in GF(2^4)
        delta_sq[3] = delta[3];
        delta_sq[2] = delta[3] ^ delta[2];
        delta_sq[1] = delta[2] ^ delta[1];
        delta_sq[0] = delta[3] ^ delta[1] ^ delta[0];

        // Multiply by Lambda (Constant)
        delta_lam[3] = delta_sq[2] ^ delta_sq[0];
        delta_lam[2] = delta_sq[3] ^ delta_sq[2] ^ delta_sq[1] ^ delta_sq[0];
        delta_lam[1] = delta_sq[3];
        delta_lam[0] = delta_sq[2];

        // Optimization from SV code:
        // lsb_xor_msb (gamma + delta) * gamma = gamma^2 + gamma*delta
        // Then add delta*lambda -> Total = gamma^2 + gamma*delta + delta^2*lambda
        sum_gam_del = delta ^ gamma;
        prod_sum    = mul_gf24(sum_gam_del, gamma);
        inv_denom   = delta_lam ^ prod_sum;

        // Invert the denominator (Lookup Table for GF(2^4) Inverse)
        case (inv_denom)
            4'h0: inv_result = 4'h0; 4'h1: inv_result = 4'h1;
            4'h2: inv_result = 4'h3; 4'h3: inv_result = 4'h2;
            4'h4: inv_result = 4'hF; 4'h5: inv_result = 4'hC;
            4'h6: inv_result = 4'h9; 4'h7: inv_result = 4'hB;
            4'h8: inv_result = 4'hA; 4'h9: inv_result = 4'h6;
            4'hA: inv_result = 4'h8; 4'hB: inv_result = 4'h7;
            4'hC: inv_result = 4'h5; 4'hD: inv_result = 4'hE;
            4'hE: inv_result = 4'hD; 4'hF: inv_result = 4'h4;
            default: inv_result = 4'h0;
        endcase

        // Final Multiplication to get result High/Low parts
        final_h = mul_gf24(delta, inv_result);
        final_l = mul_gf24(sum_gam_del, inv_result);


        // --- STEP 3: INVERSE ISOMORPHIC MAPPING (Composite -> Standard) ---
        inv_iso_map[7] = final_h[3] ^ final_h[2] ^ final_h[1] ^ final_l[1];
        inv_iso_map[6] = final_h[2] ^ final_l[2];
        inv_iso_map[5] = final_h[2] ^ final_h[1] ^ final_l[1];
        inv_iso_map[4] = final_h[2] ^ final_h[1] ^ final_h[0] ^ final_l[2] ^ final_l[1];
        inv_iso_map[3] = final_h[1] ^ final_h[0] ^ final_l[3] ^ final_l[2] ^ final_l[1];
        inv_iso_map[2] = final_h[3] ^ final_h[0] ^ final_l[3] ^ final_l[2] ^ final_l[1];
        inv_iso_map[1] = final_h[1] ^ final_h[0];
        inv_iso_map[0] = final_h[2] ^ final_h[1] ^ final_h[0] ^ final_l[2] ^ final_l[0];


        // --- STEP 4: AFFINE TRANSFORMATION (For Encryption) ---
        // Formula: Ax + b (b = 0x63)
        affine_out[0] = inv_iso_map[0] ^ inv_iso_map[4] ^ inv_iso_map[5] ^ inv_iso_map[6] ^ inv_iso_map[7] ^ 1'b1;
        affine_out[1] = inv_iso_map[0] ^ inv_iso_map[1] ^ inv_iso_map[5] ^ inv_iso_map[6] ^ inv_iso_map[7] ^ 1'b1;
        affine_out[2] = inv_iso_map[0] ^ inv_iso_map[1] ^ inv_iso_map[2] ^ inv_iso_map[6] ^ inv_iso_map[7];
        affine_out[3] = inv_iso_map[0] ^ inv_iso_map[1] ^ inv_iso_map[2] ^ inv_iso_map[3] ^ inv_iso_map[7];
        affine_out[4] = inv_iso_map[0] ^ inv_iso_map[1] ^ inv_iso_map[2] ^ inv_iso_map[3] ^ inv_iso_map[4];
        affine_out[5] = inv_iso_map[1] ^ inv_iso_map[2] ^ inv_iso_map[3] ^ inv_iso_map[4] ^ inv_iso_map[5] ^ 1'b1;
        affine_out[6] = inv_iso_map[2] ^ inv_iso_map[3] ^ inv_iso_map[4] ^ inv_iso_map[5] ^ inv_iso_map[6] ^ 1'b1;
        affine_out[7] = inv_iso_map[3] ^ inv_iso_map[4] ^ inv_iso_map[5] ^ inv_iso_map[6] ^ inv_iso_map[7];
    end

    // Output assignment
    assign sbox_out = affine_out;

endmodule