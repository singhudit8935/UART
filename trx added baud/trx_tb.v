  `include "trx.v"
  `timescale 1ns/1ps  

module uart_tx_tb;
    // Testbench Signals
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] data_in;
    wire txd;
    wire tx_done;

    // Clock generation (50 MHz clock for UART timing)
    initial clk = 0;
    always #10 clk = ~clk;

    // DUT Instantiation
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .data_in(data_in),
        .txd(txd),
        .tx_done(tx_done)
    );

    // Testbench Logic
    initial begin
        $monitor($time, " | tx_start=%b | data_in=%h | txd=%b | tx_done=%b", tx_start, data_in, txd, tx_done);

        // Initialize Signals
        reset = 1;
        tx_start = 0;
        data_in = 8'b00000000;
        #40; // Reset pulse duration

        reset = 0;
        #20;

        // Test Case 1: Transmitting 0x55 (01010101)
        tx_start = 1;
        data_in = 8'h55;  // Sample data
        #20;
        tx_start = 0;     // Allow enough time for FSM to detect tx_start

        // Wait for transmission completion
        wait(tx_done);
        $display("Transmission complete for data: %h", data_in);

        #40;

        // Test Case 2: Transmitting 0xAA (10101010)
        tx_start = 1;
        data_in = 8'hAA;  // Sample data
        #20;
        tx_start = 0;     // Allow enough time for FSM to detect tx_start

        // Wait for transmission completion
        wait(tx_done);
        $display("Transmission complete for data: %h", data_in);

        #40;

        // Test Case 3: Random data example
        tx_start = 1;
        data_in = 8'hF0;  // Sample data
        #20;
        tx_start = 0;     // Allow enough time for FSM to detect tx_start

        // Wait for transmission completion
        wait(tx_done);
        $display("Transmission complete for data: %h", data_in);

        #50;
        $finish;
    end
endmodule

  
  
  
  //-----------------------------------------------


// `include "trx.v"
// // `timescale 1ns/1ps
// module tx_test;
//     reg clk, reset, tx_start;
//     reg [7:0] data_in;
//     wire txd;
//     wire tx_done;

//     uart_tx UUT(clk, reset, tx_start, data_in, txd, tx_done); // instantiation

//     initial begin
//         clk = 0;
//         reset = 1; // Because reset is 1 then only our values are initialized in idle case of source code
//         tx_start = 0; // Initialized to ensure no false triggers
//         #11 reset = 0; // For else part of the FSM logic

//         #40 tx_start = 1; // Onset of transmission and we also had to assign data input
//         data_in = 8'hAA; // 10101010
        
//         #20 tx_start = 0; // Deactivating tx_start after initiating transmission

//         #500000 $finish; // Increased simulation time to ensure complete UART transmission
//     end

//     always #10 clk = ~clk; // Toggling of clock after every 10 ns; time period = 20 ns, f = 50 MHz

//     initial begin // For waveform generation
//         $dumpfile("transmit.vcd");
//         $dumpvars(2, tx_test); // Dump all signals for better tracking
//         $monitor("Time = %0t | tx_start = %b | txd = %b | tx_done = %b", $time, tx_start, txd, tx_done);
//     end

// endmodule






//---------------------------------


// `include "trx.v"
// `timescale 1ns/1ps

// module tx_test;
//     reg clk, reset, tx_start;
//     reg [7:0] data_in;
//     wire txd;
//     wire tx_done;

//     // Instantiating the UART transmitter module
//     uart_tx UUT(clk, reset, tx_start, data_in, txd, tx_done); 

//     // Initial block to define the input signals
//     initial begin
//         clk = 0;
//         reset = 1; // Ensures FSM starts in `idle` state (necessary for initial conditions)
//         #11 reset = 0; // For triggering the 'else' block in the FSM logic (enables normal operation)
//         #40 tx_start = 1; // Onset of transmission and data input assignment
//         data_in = 8'hAA; // Data value to be transmitted (binary 10101010)
//         #60 tx_start = 0; // Clears `tx_start` after initiating transmission

//         #500000 $finish; // Increased simulation time to ensure full UART transmission
//     end

//     // Clock generation with 50 MHz frequency (time period = 20 ns)
//     always #10 clk = ~clk; // Clock toggling ensures FSM state transitions occur correctly

//     // Waveform generation for debugging and analysis
//     initial begin
//         $dumpfile("transmit.vcd"); // Specifies the waveform file name
//         $dumpvars(0, tx_test); // Dumps all signals in the `tx_test` module for tracking
//     end
// endmodule




// // ----------------------------version 4 code------------------ OG CODE

// `include "trx.v"
// `timescale 1ns/1ps

// module tx_test;
// reg clk, reset, tx_start;
//     reg [7:0] data_in;
//     wire txd;
//     wire tx_done;

//     uart_tx UUT(clk, reset, tx_start, data_in, txd, tx_done); // instantiation

//     initial begin
//         clk=0;
//         reset=1; // if block is running here
//         #11 reset=0;// else blcok of source code is runnign here
//         #40 tx_start=0;
//         #500000 $finish;

//     end

//     always begin
//         $dumpfile("transmit.vcd");
//         $dumpvars(2, tx_test);
//     end




// endmodule


// //////////////////////now version 3 code/////////////////





/////////////////////////////////////------------older versions-------------

// `include "trx.v"
// // `timescale 1ns/1ps
// module tx_test;
//     reg clk, reset, tx_start;
//     reg [7:0] data_in;
//     wire txd;
//     wire tx_done;

//     uart_tx UUT(clk, reset, tx_start, data_in, txd, tx_done);// instantiation

//     initial begin
//         clk = 0;
//         reset = 1; // because reset is 1 then only our values are initialized in idle case of source code
//         tx_start = 0; // initialized to ensure no false triggers
//         #11 reset = 0; // for else part of the FSM logic

//         #40 tx_start = 1; // onset of transmission and we also had to assign data input
//         data_in = 8'hAA; // 10101010

//         #500000 $finish; // Increased simulation time to ensure complete UART transmission
//     end

//     always #10 clk = ~clk; // toggling of clock after every 10 ns and time period is 20 ns and f = 50 MHz

//     initial begin // for waveform generation
//         $dumpfile("transmit.vcd");
//         $dumpvars(0, tx_test); // Dump all signals for better tracking
//     end

// endmodule


//////////////////////////here is the original code////////////////////

// `include "trx.v"
// `timescale 1ns/1ps
// module tx_test;
//     reg clk, reset, tx_start;
//     reg [7:0] data_in;
//     wire txd;
//     wire tx_done;

//     uart_tx UUT(clk, reset, tx_start, data_in, txd, tx_done);// instantiation

//     initial begin
//         clk = 0;
//         reset=1; // beaucse reset is 1 then only our values aer initialed in idle case of source code
//         #11 reset = 0; // for else part of the 

//         #40 tx_start=1; // onset of transmission and we also had to assign data input
//         data_in = 8'hAA ; // 101010101
//         #50000 tx_start=0;

//         #10000000 $finish;

//     end
//     always #10 clk = ~clk; // toggling of clock after evrey 10 ns and timeperiod is 20 ns and f= 50 Mhz

//     initial begin // for wave form generation
//         $dumpfile("transmit.vcd");
//         $dumpvars(0, tx_test);
//     end





// endmodule


/////////////////////////this is chat gpt correctedd version
// `include "trx.v"
// `timescale 1ns/1ps
// module tx_test;
//     reg clk, reset, tx_start;
//     reg [7:0] data_in;
//     wire txd;
//     wire tx_done;

//     uart_tx UUT(clk, reset, tx_start, data_in, txd, tx_done); // instantiation

//     initial begin
//         clk = 0;
//         reset = 1; // Because reset = 1 initializes FSM to idle
//         tx_start = 0; // Initialized to prevent undefined behavior
//         #11 reset = 0; // For FSM reset logic

//         #40 tx_start = 1; // Onset of transmission
//         data_in = 8'hAA; // Corrected hex notation for clarity
//         #50000 tx_start = 0; // Corrected typo

//         #10000000 $finish;
//     end

//     always #10 clk = ~clk; // Clock toggles every 10ns (50 MHz frequency)

//     initial begin // Waveform generation
//         $dumpfile("transmit.vcd");
//         $dumpvars(0, tx_test);
//     end
// endmodule
