`timescale 1us / 1ns
module Top_Tb;

    // Testbench signals
    reg clk;               // Clock signal
    reg rst;               // Reset signal
    reg RX_IN;             // Input signal for received data
    reg [5:0] Prescale;    // Prescale value for timing control
    reg PAR_EN;            // Parity enable signal
    reg PAR_TYP;           // Parity type signal (0 for even, 1 for odd)
    wire data_valid;       // Output signal indicating data validity
    wire [7:0] P_DATA;     // Output signal for processed data
    parameter  CLK_PERIOD = (1000000 / 230400*1); // Period of clock in ns (1/frequency) (1000000 / 230400)/1
    // Instantiate the Top module
    Top uut (
        .clk(clk),
        .rst(rst),
        .RX_IN(RX_IN),
        .Prescale(Prescale),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .data_valid(data_valid),
        .P_DATA(P_DATA)
    );

    // Additional signals for checking
    reg [7:0] Data_chk;               // Register to hold checked data
    integer i;                        // Loop variable
    integer counter = 0;              // Counter for data bits
    integer correct = 0;              // Counter for correct tests
    integer uncorrect = 0;            // Counter for incorrect tests
    wire [7:0] Data_expected;         // Expected data value
    wire strt_glitch_tst;             // Signal to check start glitch
    wire stp_err_tst;                 // Signal to check stop error
    wire Par_err_tst;                 // Signal to check parity error

    // Assignments to connect testbench signals to module internals
    assign strt_glitch_tst = uut.START_CHECK_Rx.strt_glitch;
    assign stp_err_tst = uut.STOP_CHECK_RX.stp_err;
    assign Par_err_tst = uut.PARITY_CHECK_RX.Par_err;
    assign Data_expected = uut.DESERIALIZER_RX.P_DATA;
   
//assign CLK_PERIOD=clk
    // Clock generation
    initial begin
       
        clk = 0;
        forever begin
           #(CLK_PERIOD) clk = ~clk; 
        end
    end

    // Testbench procedure
    initial begin
        /* -------------------------------------------------------------------------- */
        /*                            Case 1: Parity and Idle                         */
        /* -------------------------------------------------------------------------- */
        initialize();       // Initialize testbench signals
        check_rst();        // Check reset condition
        
        /* --------------------------- Start State --------------------------- */
        RX_IN = 0;          // Set RX_IN to 0 to simulate start bit
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_start_data(strt_glitch_tst);  // Check for start glitch
        
        /* --------------------------- Data State --------------------------- */
        repeat(8) begin     // Loop for 8 data bits
            RX_IN = $random; // Generate random data bit
            Data_chk[counter] = RX_IN; // Store data bit in Data_chk
            #((Prescale * 2)*CLK_PERIOD);  // Wait for two prescale periods
            counter = counter + 1;  // Increment counter
        end
        counter = 0;        // Reset counter
        check_data(Data_chk);  // Check received data
        
        /* --------------------------- Parity State --------------------------- */
        PAR_EN = 1;         // Enable parity
        PAR_TYP = 0;        // Set parity type to even
        RX_IN = calculate_parity(Data_chk, PAR_TYP); // Calculate parity bit
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_parity_data(Par_err_tst);  // Check parity error
        
        /* --------------------------- Stop State --------------------------- */
        RX_IN = 1;          // Set RX_IN to 1 to simulate stop bit
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_stp(stp_err_tst); // Check stop error
        check_data_valid(); // Check data validity
        
        /* --------------------------- Idle State --------------------------- */
        RX_IN = 1;          // Set RX_IN to 1 for idle state
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_idle();       // Check idle condition
        
        /* -------------------------------------------------------------------------- */
        /*                             Case 2: Odd Parity                             */
        /* -------------------------------------------------------------------------- */
        initialize();       // Initialize testbench signals
        check_rst();        // Check reset condition
        
        /* --------------------------- Start State --------------------------- */
        RX_IN = 0;          // Set RX_IN to 0 to simulate start bit
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_start_data(strt_glitch_tst);  // Check for start glitch
        
        /* --------------------------- Data State --------------------------- */
        repeat(8) begin     // Loop for 8 data bits
            RX_IN = $random; // Generate random data bit
            Data_chk[counter] = RX_IN; // Store data bit in Data_chk
            #((Prescale * 2)*CLK_PERIOD);  // Wait for two prescale periods
            counter = counter + 1;  // Increment counter
        end
        counter = 0;        // Reset counter
        check_data(Data_chk);  // Check received data
        
        /* --------------------------- Parity State --------------------------- */
        PAR_EN = 1;         // Enable parity
        PAR_TYP = 1;        // Set parity type to odd
        RX_IN = calculate_parity(Data_chk, PAR_TYP); // Calculate parity bit
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_parity_data(Par_err_tst);  // Check parity error
        
        /* --------------------------- Stop State --------------------------- */
        RX_IN = 1;          // Set RX_IN to 1 to simulate stop bit
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_stp(stp_err_tst); // Check stop error
        check_data_valid(); // Check data validity
        
        /* --------------------------- Idle State --------------------------- */
        RX_IN = 1;          // Set RX_IN to 1 for idle state
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_idle();       // Check idle condition
        
        /* -------------------------------------------------------------------------- */
        /*                      Case 3: Parity Disabled (Odd Parity)                  */
        /* -------------------------------------------------------------------------- */
        initialize();       // Initialize testbench signals
        check_rst();        // Check reset condition
        
        /* --------------------------- Start State --------------------------- */
        RX_IN = 0;          // Set RX_IN to 0 to simulate start bit
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_start_data(strt_glitch_tst);  // Check for start glitch
        
        /* --------------------------- Data State --------------------------- */
        repeat(8) begin     // Loop for 8 data bits
            RX_IN = $random; // Generate random data bit
            Data_chk[counter] = RX_IN; // Store data bit in Data_chk
            #((Prescale * 2)*CLK_PERIOD);  // Wait for two prescale periods
            counter = counter + 1;  // Increment counter
        end
        counter = 0;        // Reset counter
        check_data(Data_chk);  // Check received data
        
        /* --------------------------- Parity or Stop State --------------------------- */
        PAR_EN = 0;         // Disable parity
        PAR_TYP = 1;        // Set parity type to odd
        if (PAR_EN) begin
            RX_IN = calculate_parity(Data_chk, PAR_TYP); // Calculate parity bit
            #((Prescale * 2)*CLK_PERIOD);  // Wait for two prescale periods
            check_parity_data(Par_err_tst);  // Check parity error
        end else begin
            RX_IN = 1;      // Set RX_IN to 1 to simulate stop bit
            #((Prescale * 2)*CLK_PERIOD);  // Wait for two prescale periods
            check_stp(stp_err_tst); // Check stop error
            check_data_valid(); // Check data validity
        end
        
        /* --------------------------- Idle State --------------------------- */
        RX_IN = 1;          // Set RX_IN to 1 for idle state
        #((Prescale * 2)*CLK_PERIOD);    // Wait for two prescale periods
        check_idle();       // Check idle condition
        
        /* -------------------------------------------------------------------------- */
        /*                  Random Case: Various Combinations of States               */
        /* -------------------------------------------------------------------------- */
        initialize();       // Initialize testbench signals
        check_rst();        // Check reset condition
        
        repeat(2000) begin
            RX_IN = $random; // Generate random RX_IN value
            if (RX_IN == 1) begin
                #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                check_idle();    // Check idle condition
                RX_IN = 0;       // Set RX_IN to 0 to simulate start bit
                #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                check_start_data(strt_glitch_tst); // Check for start glitch

                repeat(8) begin // Loop for 8 data bits
                    RX_IN = $random; // Generate random data bit
                    Data_chk[counter] = RX_IN; // Store data bit in Data_chk
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    counter = counter + 1; // Increment counter
                end
                counter = 0; // Reset counter
                check_data(Data_chk); // Check received data

                PAR_EN = $random; // Randomly enable or disable parity
                PAR_TYP = $random; // Randomly set parity type
                if (PAR_EN) begin
                    RX_IN = calculate_parity(Data_chk, PAR_TYP); // Calculate parity bit
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    check_parity_data(Par_err_tst); // Check parity error
                    RX_IN = 1; // Set RX_IN to 1 to simulate stop bit
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    check_stp(stp_err_tst); // Check stop error
                    check_data_valid(); // Check data validity
                end else begin
                    RX_IN = 1; // Set RX_IN to 1 to simulate stop bit
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    check_stp(stp_err_tst); // Check stop error
                    check_data_valid(); // Check data validity
                end
            end else begin
                #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                check_start_data(strt_glitch_tst); // Check for start glitch

                repeat(8) begin // Loop for 8 data bits
                    RX_IN = $random; // Generate random data bit
                    Data_chk[counter] = RX_IN; // Store data bit in Data_chk
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    counter = counter + 1; // Increment counter
                end
                counter = 0; // Reset counter
                check_data(Data_chk); // Check received data

                PAR_EN = $random; // Randomly enable or disable parity
                PAR_TYP = $random; // Randomly set parity type
                if (PAR_EN) begin
                    RX_IN = calculate_parity(Data_chk, PAR_TYP); // Calculate parity bit
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    check_parity_data(Par_err_tst); // Check parity error
                    RX_IN = 1; // Set RX_IN to 1 to simulate stop bit
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    check_stp(stp_err_tst); // Check stop error
                    check_data_valid(); // Check data validity
                end else begin
                    RX_IN = 1; // Set RX_IN to 1 to simulate stop bit
                    #((Prescale * 2)*CLK_PERIOD); // Wait for two prescale periods
                    check_stp(stp_err_tst); // Check stop error
                    check_data_valid(); // Check data validity
                end
            end
        end

        // Display the total number of correct and incorrect tests
        $display("Total correct tests: %d", correct);
        $display("Total incorrect tests: %d", uncorrect);

        $stop; // Stop simulation
    end

    // Task to initialize testbench signals
    task initialize;
        begin
            rst = 0;           // Deassert reset
            RX_IN = 1;         // Set RX_IN to 1 (idle state)
            Prescale = 16;     // Set prescale value
            PAR_EN = 1;        // Enable parity
            PAR_TYP = 0;       // Set parity type to even
            #((Prescale * 2)*CLK_PERIOD);   // Wait for two prescale periods
        end
    endtask

    // Task to check reset condition
    task check_rst;
        begin
            if (data_valid !== 0) begin
                $display("ERROR: data_valid or P_DATA is not 0 at reset");
                uncorrect = uncorrect + 1; // Increment incorrect counter
            end else begin
                correct = correct + 1; // Increment correct counter
            end
            rst = 1; // Assert reset
        end
    endtask

    // Task to check start data condition
    task check_start_data(input strt_glitch_tst);
        begin
            if (strt_glitch_tst !== 0) begin
                $display("ERROR: strt_glitch is not 0");
                uncorrect = uncorrect + 1; // Increment incorrect counter
            end else begin
                correct = correct + 1; // Increment correct counter
            end
        end
    endtask

    // Task to check data reception
    task check_data(input [7:0] Data_chk);
        begin
            #(2*CLK_PERIOD); // Wait for 2 time units
            if (Data_expected !== Data_chk) begin
                $display("ERROR: Data_expected (0x%b) is not equal to Data_chk (0x%b)", Data_expected, Data_chk);
                uncorrect = uncorrect + 1; // Increment incorrect counter
            end else begin
                correct = correct + 1; // Increment correct counter
            end
        end
    endtask

    // Task to check parity condition
    task check_parity_data(input parity_tst);
        begin
            if (parity_tst !== 0) begin
                $display("ERROR: parity_tst is not 0");
                uncorrect = uncorrect + 1; // Increment incorrect counter
            end else begin
                correct = correct + 1; // Increment correct counter
            end
        end
    endtask

    // Task to check stop condition
    task check_stp(input stp_err_tst);
        begin
            if (stp_err_tst !== 0) begin
                $display("ERROR: stp_err_tst is not 0");
                uncorrect = uncorrect + 1; // Increment incorrect counter
            end else begin
                correct = correct + 1; // Increment correct counter
            end
        end
    endtask

    // Task to check data validity
    task check_data_valid;
        begin
            if (data_valid !== 1) begin
                $display("ERROR: data_valid or P_DATA is not 1 at the end of the test");
                uncorrect = uncorrect + 1; // Increment incorrect counter
            end else begin
                correct = correct + 1; // Increment correct counter
            end
        end
    endtask

    // Task to check idle condition
    task check_idle;
        begin
            if (uut.FSM_RX.dat_samp_en !== 0 ||
                uut.FSM_RX.enable !== 0 ||
                uut.FSM_RX.par_chk_en !== 0 ||
                uut.FSM_RX.strt_chk_en !== 0 ||
                uut.FSM_RX.stp_chk_en !== 0 ||
                uut.FSM_RX.deser_en !== 0 ||
                uut.FSM_RX.data_valid !== 0) 
            begin
                $display("ERROR: One or more signals are not idle");
                uncorrect = uncorrect + 1; // Increment incorrect counter
            end else begin
                correct = correct + 1; // Increment correct counter
            end
        end
    endtask

    // Function to calculate parity bit
    function integer calculate_parity;
        input [7:0] data;      // Input data
        input parity_type;     // Parity type (0 for even, 1 for odd)
        integer parity;
        begin
            // Calculate even parity using reduction XOR
            parity = ^data;
            // If odd parity is required, invert the result
            if (parity_type) begin
                parity = ~parity;
            end
            calculate_parity = parity; // Return calculated parity
        end
    endfunction

endmodule
