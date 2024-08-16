module Deserializer #(
    parameter width = 8  // Parameter defining the width of P_DATA
)(
    input clk,
    input rst,
    input sampled_bit,
    input deser_en,
    output wire [width-1:0] P_DATA  // Output parallel data
    
);

    reg [width-1:0] Data_reg;  // Register to hold deserialized data
    reg [3:0] counter;  // Counter to track the number of bits received

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            Data_reg <= 0;  // Reset data register on reset
            counter <= 0;   // Reset counter on reset
        end else begin
            if (deser_en) begin
                Data_reg[counter] <= sampled_bit;  // Store sampled bit in Data_reg
                counter <= counter + 1;  // Increment counter
            end
            if (counter == 8) begin
                counter <= 0;
               // P_DATA<=Data_reg;  // Reset counter after receiving 8 bits
            end
        end
    end
assign P_DATA=(counter ==8)? Data_reg:P_DATA;
endmodule
