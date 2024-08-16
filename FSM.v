module FSM (
    input clk,                // Clock signal
    input rst,                // Reset signal
    input RX_IN,              // Received input signal
    input PAR_EN,             // Parity enable signal
    input [5:0] bit_cnt,      // Bit count
    input [5:0] edge_cnt,     // Edge count
    input Par_err,            // Parity error flag
    input strt_glitch,        // Start glitch flag
    input stp_err,            // Stop error flag
    output reg dat_samp_en,   // Data sampling enable signal
    output reg enable,        // Enable signal
    output reg par_chk_en,    // Parity check enable signal
    output reg strt_chk_en,   // Start check enable signal
    output reg stp_chk_en,    // Stop check enable signal
    output reg deser_en,      // Deserializer enable signal
    output reg data_valid,    // Data valid signal
    input [5:0] Prescale      // Prescale value for timing control
);

    // State encoding
    localparam IDLE = 3'b000,  // Idle state
               STR  = 3'b001,  // Start bit state
               DATA = 3'b010,  // Data bits state
               PAR  = 3'b011,  // Parity bit state
               STP  = 3'b100;  // Stop bit state

    // Registers for state transition
    reg [2:0] current_state, next_state;

    // Current state logic
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            current_state <= IDLE;  // Reset to IDLE state
        end else begin
            current_state <= next_state;  // Update current state based on next state
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (RX_IN) begin
                    next_state = IDLE;  // Stay in IDLE if RX_IN is high (idle line)
                end else begin
                    next_state = STR;   // Move to STR (start bit) state if RX_IN is low
                end
            end

            STR: begin
                if (bit_cnt != 1) begin
                    next_state = STR;  // Stay in STR state until one bit is sampled
                end else begin
                    if (strt_glitch) begin
                        next_state = IDLE;  // Go back to IDLE if there is a start glitch
                    end else begin
                        next_state = DATA;  // Move to DATA state if no start glitch
                    end
                end
            end

            DATA: begin
                if (bit_cnt != 9) begin
                    next_state = DATA;  // Stay in DATA state until all data bits are sampled
                end else begin
                    if (PAR_EN) begin
                        next_state = PAR;  // Move to PAR state if parity is enabled
                    end else begin
                        next_state = STP;  // Move to STP state if no parity
                    end
                end
            end

            PAR: begin
                if (bit_cnt != 10) begin
                    next_state = PAR;  // Stay in PAR state until the parity bit is sampled
                end else begin
                    if (Par_err) begin
                        next_state = IDLE;  // Go back to IDLE if there is a parity error
                    end else begin
                        next_state = STP;  // Move to STP state after parity bit
                    end
                end
            end

            STP: begin
                if (PAR_EN) begin
                    if (bit_cnt != 11) begin
                        next_state = STP;  // Stay in STP state until the stop bit is sampled (if parity is enabled)
                    end else begin
                        if (stp_err) begin
                            next_state = IDLE;  // Go back to IDLE if there is a stop error
                        end else begin
                            if (RX_IN) begin
                                next_state = IDLE;  // Go back to IDLE if RX_IN is high (idle line)
                            end else begin
                                next_state = STR;   // Move to STR (start bit) state if RX_IN is low
                            end
                        end
                    end
                end else begin
                    if (bit_cnt != 10) begin
                        next_state = STP;  // Stay in STP state until the stop bit is sampled (if no parity)
                    end else begin
                        if (stp_err) begin
                            next_state = IDLE;  // Go back to IDLE if there is a stop error
                        end else begin
                            if (RX_IN) begin
                                next_state = IDLE;  // Go back to IDLE if RX_IN is high (idle line)
                            end else begin
                                next_state = STR;   // Move to STR (start bit) state if RX_IN is low
                            end
                        end
                    end
                end
            end

            default: begin
                next_state = IDLE;  // Default state is IDLE
            end
        endcase
    end

    // Output logic
    always @(*) begin
        // Default outputs
        dat_samp_en = 0;
        enable = 0;
        par_chk_en = 0;
        strt_chk_en = 0;
        stp_chk_en = 0;
        deser_en = 0;
        data_valid = 0;

        // Enable data sampling when edge count is near the middle of prescale period
        if (edge_cnt >= ((Prescale >> 1) - 1) && edge_cnt <= ((Prescale >> 1) + 1)) begin
            dat_samp_en = 1;
        end

        case (current_state)
            IDLE: begin
                // All outputs are 0 in IDLE state
            end

            STR: begin
                if (edge_cnt == (Prescale-1)) begin
                    strt_chk_en = 1;  // Enable start check at the end of the prescale period
                end
                enable = 1;  // Enable FSM operation
            end

            DATA: begin
                if (edge_cnt == (Prescale-1)) begin
                    deser_en = 1;  // Enable deserializer at the end of the prescale period
                end
                enable = 1;  // Enable FSM operation
            end

            PAR: begin
                if (edge_cnt == (Prescale-1)) begin
                    par_chk_en = 1;  // Enable parity check at the end of the prescale period
                end
                enable = 1;  // Enable FSM operation
            end

            STP: begin
                enable = 1;  // Enable FSM operation
                if (edge_cnt == (Prescale-1)) begin
                    stp_chk_en = 1;  // Enable stop check at the end of the prescale period
                end
                if (edge_cnt == 0) begin
                    enable = 0;  // Disable FSM operation at the beginning of the prescale period
                    if (PAR_EN) begin
                        if (!Par_err && !stp_err) begin
                            data_valid = 1;  // Set data valid if no parity and stop errors
                        end
                    end else begin
                        if (!stp_err) begin
                            data_valid = 1;  // Set data valid if no stop error
                        end
                    end
                end
            end
        endcase
    end
endmodule
