module aes_128 (
    input  wire         clk,
    input  wire         rst_n,     
    input  wire         start,      
    
    output wire [127:0] cipher_text,
    output reg          done
);

    wire [127:0] plain_text;
    wire [127:0] key_in;

    reg  [3:0]   round_cnt;      
    reg  [127:0] state_reg;     
    reg  [127:0] key_reg;        
    reg          running;      

    wire [127:0] next_key;      
    wire [127:0] round_out;      
    wire [7:0]   rcon_val;     
    wire         is_last_round;
    
    wire [3:0]   rcon_idx;

    assign rcon_idx = round_cnt + 4'd1;
	
	 // rcon instance
    aes_rcon u_rcon_lut (
        .round_in(rcon_idx), 
        .rcon_out(rcon_val)
    );

    // key_expand instance
    aes_key_expand_128 u_key_expand (
        .old_key(key_reg),
        .rcon   (rcon_val),
        .new_key(next_key)
    );

    
    assign is_last_round = (round_cnt == 4'd9);

    aes_round u_aes_round (
        .state_in     (state_reg),
        .round_key    (next_key),     
        .is_last_round(is_last_round),
        .state_out    (round_out)
    );

    // FSM
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= 128'd0;
            key_reg   <= 128'd0;
            round_cnt <= 4'd0;
            running   <= 1'b0;
            done      <= 1'b0;
        end 
        else begin
            if (start) begin
                state_reg <= plain_text ^ key_in; 
                key_reg   <= key_in;             
                round_cnt <= 4'd0;             
                running   <= 1'b1;                
                done      <= 1'b0;             
            end
            else if (running) begin
                state_reg <= round_out;
                key_reg   <= next_key;
                round_cnt <= round_cnt + 1'b1;
                if (round_cnt == 4'd9) begin
                    running <= 1'b0; 
                    done    <= 1'b1;
                end
            end
        end
    end

    // OUTPUT
    assign cipher_text = state_reg;

endmodule