module Edge_bit_cnt (
    input clk,               // Clock signal
    input rst,               // Reset signal (active low)
    input enable,            // Enable signal for counting
    input [5:0] Prescale,    // Prescale value for timing control
    output reg [5:0] edge_cnt,  // Edge count output
    output reg [5:0] bit_cnt    // Bit count output
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // If reset is active (low), initialize edge and bit counters to 0
            edge_cnt <= 0;
            bit_cnt <= 0;
        end
        else begin
            if (enable) begin
                // If enabled, increment edge counter
                edge_cnt <= edge_cnt + 1;
                
                // If edge counter reaches the Prescale value, reset edge counter and increment bit counter
                if (edge_cnt == Prescale-1) begin
                    bit_cnt <= bit_cnt + 1;
                    edge_cnt <= 0;
                end
            end
            else begin
                // If not enabled, reset both edge and bit counters to 0
                edge_cnt <= 0;
                bit_cnt <= 0;
            end
        end
    end

endmodule
