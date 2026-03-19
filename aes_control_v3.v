module aes_control_v3 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    
    output reg  [3:0] round_ctr,   // counter 
    output reg        phase,  
    output reg        is_first_round, // tin hieu start datapath
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
            done           <= 0;
            is_first_round <= 0;

            case (state)
                IDLE: begin
                    round_ctr <= 1;
                    phase     <= 0;
                    if (start) begin
                        is_first_round <= 1; ///load Plaintext XOR Key0
                        state <= RUN;
                    end
                end

                RUN: begin
                    if (phase == 0) begin
						  //key tinh xong first half va luu vao thanh ghi
						  //datapath tinh xong second half va luu vao thanh ghi
                        phase <= 1;
                    end 
                    else begin
						  //key tinh xong 2nd half va luu vao thanh ghi
						  //datapath tinh xong first half va luu vao thanh ghi
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