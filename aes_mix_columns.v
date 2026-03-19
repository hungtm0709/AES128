module aes_mix_columns (
    input  wire [31:0] mix_col_in,  // 1 cột 32-bit (4 bytes)
    output wire [31:0] mix_col_out
);

    // 1. Tách dây tín hiệu cho dễ nhìn (Wires)
    wire [7:0] s0, s1, s2, s3;
    assign s0 = mix_col_in[31:24];
    assign s1 = mix_col_in[23:16];
    assign s2 = mix_col_in[15:8];
    assign s3 = mix_col_in[7:0];

    // 2. Tính biến trung gian Temp (XOR tất cả các byte)
    // Tương ứng logic chia sẻ
    wire [7:0] t_all;
    assign t_all = s0 ^ s1 ^ s2 ^ s3;

    // 3. Chuẩn bị đầu vào cho bộ nhân 2
    // Ta cần tính mul2(s0 ^ s1), mul2(s1 ^ s2)...
    wire [7:0] v0, v1, v2, v3;
    assign v0 = s0 ^ s1;
    assign v1 = s1 ^ s2;
    assign v2 = s2 ^ s3;
    assign v3 = s3 ^ s0;

    // 4. Gọi module aes_mul2 (Structural Modeling)
    // Kết quả sau khi nhân 2 được lưu vào m0, m1...
    wire [7:0] m0, m1, m2, m3;

    aes_mul2 u_mul0 (.a(v0), .y(m0));
    aes_mul2 u_mul1 (.a(v1), .y(m1));
    aes_mul2 u_mul2 (.a(v2), .y(m2));
    aes_mul2 u_mul3 (.a(v3), .y(m3));

    // 5. Tính kết quả cuối cùng (Dataflow logic)
    // Công thức: Out = In ^ t_all ^ m_kết_quả
    assign mix_col_out[31:24] = s0 ^ t_all ^ m0;
    assign mix_col_out[23:16] = s1 ^ t_all ^ m1;
    assign mix_col_out[15:8]  = s2 ^ t_all ^ m2;
    assign mix_col_out[7:0]   = s3 ^ t_all ^ m3;

endmodule