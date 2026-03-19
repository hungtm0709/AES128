module aes_mul2 (
    input  wire [7:0] a,
    output wire [7:0] y
);

    assign y[7] = a[6];
    assign y[6] = a[5];
    assign y[5] = a[4];
    assign y[4] = a[3] ^ a[7]; 
    assign y[3] = a[2] ^ a[7]; 
    assign y[2] = a[1];
    assign y[1] = a[0] ^ a[7]; 
    assign y[0] = a[7];        

endmodule