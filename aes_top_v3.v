module aes_top_v3 (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    
    output wire [127:0] ciphertext,
    output wire         done
);

    //Wires
    wire [3:0]   round_ctr;
    wire         phase;
    wire         is_first_round;
    wire [127:0] round_key;

    //Control
    aes_control_v3 u_control (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start),
        .round_ctr      (round_ctr),
        .phase          (phase),
        .is_first_round (is_first_round),
        .done           (done)
    );

    //Datapath
    aes_datapath_v3 u_datapath (
        .clk            (clk),
        .rst_n          (rst_n),
        .phase          (phase),	//phase nguoc voiws datapath
        .round_ctr      (round_ctr),
        .is_first_round (is_first_round),
        .plaintext      (plaintext),
        .round_key      (round_key),
        .ciphertext     (ciphertext)
    );
    
    //Key Expand V3
    aes_key_expand_v3 u_key_expand (
        .clk     (clk),
        .rst_n   (rst_n),
        .k_ld    (start), // chay truoc Datapath 1 chu ki
        .phase   (phase), // phase nguoc voi Datapath
        .key_in  (key),
        .key_out (round_key)
    );

endmodule