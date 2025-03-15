`timescale 1ns/1ps
`include "baud_rate_generator.v"  

module tb_baud;
    reg clk, reset;
    wire [11:0] q;
    wire tick;

    baud_gen DUT(clk, reset, q , tick);  // instantiation

    initial begin 
        clk=0; reset=1;
        #11 reset=0;

        #1000000 $finish;  // if we reduce this runtime then we will not be able to see this pick pulse
    end

    always #10 clk = ~clk;  //t=20ns, f=50 mhz

    initial begin
        $dumpfile("baud_wave.vcd");
        $dumpvars(1, tb_baud);
    end

endmodule

// module tb_baud;
//     // Testbench signals
//     reg clk, reset;
//     wire [11:0] q;
//     wire tick;

//     // Instantiation of the Design Under Test (DUT)
//     baud_gen DUT (clk, reset, q, tick);

//     // Clock generation logic
//     always begin
//         #10 clk = ~clk;    // Generate a 20ns period clock (50 MHz)
//     end

//     // Initial block for simulation control
//     initial begin
//         clk = 0;
//         reset = 1;         // Initialize with reset active
//         #10 reset = 0;     // De-assert reset after 10ns

//         // Improved termination logic
//         fork
//             // Timeout condition for safety
//             #200000 begin
//                 $display("Timeout: Simulation exceeded expected runtime.");
//                 $display("Final q value: %d | Final tick value: %b", q, tick);
//                 $finish;
//             end

//             // Stop the simulation when tick is asserted
//             wait (tick);  
//             $display("Tick signal asserted at time %0t.", $time);
//             $display("Final q value: %d | Final tick value: %b", q, tick);
//             $finish;
//         join
//     end

//     // Waveform generation for debugging
//     initial begin
//         $dumpfile("baud_wave.vcd");
//         $dumpvars(2, tb_baud);
//     end
// endmodule
