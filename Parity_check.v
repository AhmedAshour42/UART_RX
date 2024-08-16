module Parity_check (
    input clk,               // Clock signal
    input rst,               // Reset signal (active low)
    input par_chk_en,        // Parity check enable signal
    input sampled_bit,       // Sampled bit for comparison
    input PAR_TYP,           // Parity type (0 for even, 1 for odd)
    input [7:0] P_DATA,      // Parallel data input (8 bits)
    output reg Par_err       // Parity error output
);
    reg Par_bit;             // Internal parity bit register
    
    always @(*) begin
        
                if (PAR_TYP == 0) begin
                    // Odd parity: Par_bit is 0 if P_DATA has odd number of 1s
                    Par_bit = (^P_DATA);
                end else begin
                    // Even parity: Par_bit is 1 if P_DATA has odd number of 1s
                    Par_bit = !(^P_DATA) ;
                end
            end
   
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset state: Initialize Par_err and Par_bit to 0
            Par_err <= 0;
        end else begin
            // On clock edge and not reset
            if (par_chk_en) begin
                Par_err <= Par_bit ^sampled_bit ;
            end
        end
        
    end
endmodule
