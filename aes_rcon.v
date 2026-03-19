module aes_rcon (
    input  wire [3:0] round_in, // Chỉ số vòng (1 đến 10)
    output reg  [7:0] rcon_out
);

    always @(*) begin
        case (round_in)
            4'd1 : rcon_out = 8'h01;
            4'd2 : rcon_out = 8'h02;
            4'd3 : rcon_out = 8'h04;
            4'd4 : rcon_out = 8'h08;
            4'd5 : rcon_out = 8'h10;
            4'd6 : rcon_out = 8'h20;
            4'd7 : rcon_out = 8'h40;
            4'd8 : rcon_out = 8'h80;
            4'd9 : rcon_out = 8'h1B; 
            4'd10: rcon_out = 8'h36;
            default: rcon_out = 8'h00; 
        endcase
    end

endmodule