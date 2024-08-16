module Top (
    input clk,             // Clock signal
    input rst,             // Reset signal
    input wire RX_IN,      // Received input signal
    input wire [5:0] Prescale,  // Prescale value for timing control
    input wire PAR_EN,     // Parity enable signal
    input wire PAR_TYP,    // Parity type signal (odd/even)
    output wire data_valid,    // Data valid signal
    output wire [7:0] P_DATA   // Parallel data output
);

// Internal signals
wire dat_samp_en, par_chk_en, strt_chk_en, stp_chk_en, deser_en;
wire Par_err, strt_glitch, stp_err, sampled_bit, enable;
wire [5:0] bit_cnt;
wire [5:0] edge_cnt;

// Instantiate FSM
FSM FSM_RX (
    .clk(clk),              // Clock input
    .rst(rst),              // Reset input
    .RX_IN(RX_IN),          // Received input
    .dat_samp_en(dat_samp_en),   // Data sampling enable output
    .par_chk_en(par_chk_en),     // Parity check enable output
    .Par_err(Par_err),           // Parity error input
    .strt_chk_en(strt_chk_en),   // Start check enable output
    .strt_glitch(strt_glitch),   // Start glitch input
    .stp_chk_en(stp_chk_en),     // Stop check enable output
    .stp_err(stp_err),           // Stop error input
    .deser_en(deser_en),         // Deserializer enable output
    .bit_cnt(bit_cnt),           // Bit count input
    .enable(enable),             // Enable output
    .PAR_EN(PAR_EN),             // Parity enable input
    .data_valid(data_valid),     // Data valid output
    .edge_cnt(edge_cnt),         // Edge count input
    .Prescale(Prescale)          // Prescale input
);

/* --------------------- // Instantiate edge_bit_counter -------------------- */
Edge_bit_cnt EDGE_BIT_COUNTER (
    .clk(clk),              // Clock input
    .rst(rst),              // Reset input
    .bit_cnt(bit_cnt),      // Bit count output
    .enable(enable),        // Enable input
    .edge_cnt(edge_cnt),    // Edge count output
    .Prescale(Prescale)     // Prescale input
);

/* ---------------------- // Instantiate data_sampling ---------------------- */
Data_sample DATA_SAMPLING_RX (
    .clk(clk),              // Clock input
    .rst(rst),              // Reset input
    .dat_samp_en(dat_samp_en),   // Data sampling enable input
    .RX_IN(RX_IN),          // Received input
    .sampled_bit(sampled_bit),   // Sampled bit output
    .Prescale(Prescale),    // Prescale input
    .edge_cnt(edge_cnt)     // Edge count input
);

/* ----------------------- // Instantiate parity_check ---------------------- */
Parity_check PARITY_CHECK_RX (
    .clk(clk),              // Clock input
    .rst(rst),              // Reset input
    .par_chk_en(par_chk_en),    // Parity check enable input
    .sampled_bit(sampled_bit),  // Sampled bit input
    .Par_err(Par_err),          // Parity error output
    .PAR_TYP(PAR_TYP),          // Parity type input
    .P_DATA(P_DATA)             // Parallel data output
);

/* ----------------------- // Instantiate start_check ----------------------- */
Strt_chck START_CHECK_Rx (
    .clk(clk),              // Clock input
    .rst(rst),              // Reset input
    .strt_chk_en(strt_chk_en),  // Start check enable input
    .sampled_bit(sampled_bit),  // Sampled bit input
    .strt_glitch(strt_glitch)   // Start glitch output
);

/* ------------------------ // Instantiate stop_check ----------------------- */
STOP_Check STOP_CHECK_RX (
    .clk(clk),              // Clock input
    .rst(rst),              // Reset input
    .stp_chk_en(stp_chk_en),    // Stop check enable input
    .sampled_bit(sampled_bit),  // Sampled bit input
    .stp_err(stp_err)           // Stop error output
);

/* ----------------------- // Instantiate deserializer ---------------------- */
Deserializer DESERIALIZER_RX (
    .clk(clk),              // Clock input
    .rst(rst),              // Reset input
    .deser_en(deser_en),        // Deserializer enable input
    .sampled_bit(sampled_bit),  // Sampled bit input
    .P_DATA(P_DATA)             // Parallel data output
);

endmodule
