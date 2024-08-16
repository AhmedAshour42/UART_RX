module STOP_Check (
    input clk,            // Clock input signal
    input rst,            // Asynchronous reset input (active low)
    input stp_chk_en,     // Enable signal for stop bit check
    input sampled_bit,    // Input bit to be checked (sampled bit)
    output reg stp_err    // Output signal indicating stop bit error
);

    // Always block triggered on the rising edge of the clock or the falling edge of the reset
    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin
            // Reset condition: if reset is active (low), clear the stop error signal
            stp_err <= 0;
        end else begin
            // When reset is not active, check if stop check enable signal is high
            if (stp_chk_en) begin
                stp_err <= (sampled_bit == 0) ? 1 : 0;
            end
        end
    end
endmodule
