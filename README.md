This repo includes 2 top level verilog file
+ aes_128.v: a single cycle datapath aes 128
+ aes_top_v3.v: a 2 stage pipeline datapath aes 128

There are 2 versions of sbox
+ v1 is a LUT base design using case - endcase but make the design faster plus 50Mhz while consuming 4 times more resource than sboxv2
+ v2 is an combination logic base design, use less resource but make the critical path longer result in worse Fmax
