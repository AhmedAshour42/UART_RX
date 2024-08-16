module Strt_chck (
    input clk,             // Clock input signal
    input rst,             // Asynchronous reset input (active low)
    input strt_chk_en,     // Enable signal for start bit glitch check
    input sampled_bit,     // Input bit to be checked (sampled bit during start period)
    output reg strt_glitch // Output signal indicating a start bit glitch
);

    // Always block triggered on the rising edge of the clock or the falling edge of the reset
    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin
       
            strt_glitch <= 0;
        end else begin
            if (strt_chk_en) begin
                strt_glitch <= (sampled_bit == 1) ? 1 : 0;
            end
        end
    end
endmodule
