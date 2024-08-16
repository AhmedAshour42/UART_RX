module Data_sample(
    input clk,
    input rst,
    input RX_IN,
    input dat_samp_en,
    input [5:0] edge_cnt,
    input [5:0] Prescale,
    output reg sampled_bit
);

    reg [1:0] sum_sample;  // Register to accumulate sampled bits

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sampled_bit <= 1'b0;   // Reset sampled_bit to 0 on reset
            sum_sample <= 2'b00;   // Reset sum_sample to 00 on reset
        end else begin
            if (dat_samp_en) begin
                // Accumulate RX_IN into sum_sample when data sampling is enabled
                sum_sample <= sum_sample + RX_IN;
            end
            
            // Check if edge_cnt reaches Prescale-2 (second to last count)
            if (edge_cnt == (Prescale-2)) begin
                // Determine sampled_bit based on sum_sample
                sampled_bit <= (sum_sample == 2'b10 || sum_sample == 2'b11) ? 1'b1 : 1'b0;
                // Reset sum_sample after sampling
                sum_sample <= 2'b00;
            end
        end
    end

endmodule
