module aes_control_v3 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    
    output reg  [3:0] round_ctr,   // ??m vòng (1-10)
    output reg        phase,       // 0: Tính Sbox/g() | 1: Tính Mix/XOR
    output reg        is_first_round, // Báo hi?u load Input
    output reg        done
);

    // FSM States
    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam FIN  = 2'b10;

    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= IDLE;
            round_ctr      <= 0;
            phase          <= 0;
            done           <= 0;
            is_first_round <= 0;
        end else begin
            // Default assignments
            done           <= 0;
            is_first_round <= 0;

            case (state)
                IDLE: begin
                    round_ctr <= 1;
                    phase     <= 0;
                    if (start) begin
                        is_first_round <= 1; // Load Plaintext XOR Key0
                        state <= RUN;
                    end
                end

                RUN: begin
                    if (phase == 0) begin
                        // --- PHASE 0 ---
                        // Datapath: Sbox -> Shift
                        // KeyGen: Tính hàm g() l?u vào thanh ghi t?m
                        phase <= 1;
                    end 
                    else begin
                        // --- PHASE 1 ---
                        // Datapath: Mix -> AddKey -> Update State
                        // KeyGen: XOR Chain -> Update Key
                        
                        if (round_ctr == 11) begin
                            state <= FIN;
                        end else begin
                            round_ctr <= round_ctr + 1;
                            phase     <= 0;
                        end
                    end
                end

                FIN: begin
                    done  <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
