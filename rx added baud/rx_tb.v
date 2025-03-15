`include "rx.v"
`timescale 1ns/1ps

module test_rx;

    reg clk, reset, rxd;
    wire rx_done;
    wire [7:0] data_out;
    wire tick; // Corrected tick declaration as a wire

    uart_rx UUT(clk, reset, rxd, rx_done, data_out, tick); // Correct instantiation

    // 50 MHz clock
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rxd = 1; // UART idle state
        reset = 1; 
        #20 reset = 0; // Releasing reset

        #40 rxd = 0; // Start bit
        send_byte(8'hA5); // Send data 0xA5
        send_byte(8'h5A); // Send data 0x5A

        // Stop bit
        rxd = 1;  
        #26040; // Wait for completion
        $finish;
    end

    // Improved Data Task
    task send_byte(input [7:0] data);
    integer i;
    begin
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge tick);  // Correct synchronization
            rxd = data[i];
        end
        @(posedge tick);  
        rxd = 1; // Stop bit
    end
    endtask

    initial begin
        $monitor("Time = %0t | RX_Done = %b | Data Out = %h", $time, rx_done, data_out);
        $dumpfile("receive.vcd");  
        $dumpvars(2, test_rx);
    end
endmodule








// `include "rx.v"
// `timescale 1ns/1ps

// module test_rx;

//     reg clk, reset, rxd;
//     wire rx_done;
//     wire [7:0] data_out;
//     wire tick;

//     uart_rx UUT(clk, reset, rxd, rx_done, data_out, tick); // insantiation of the moduel

//     always #10 clk= ~clk; // 50 mhz clock

//     initial begin
//         clk= 0;
//         reset=1; // here if will be exceuted
//         #11 reset =0; // here executing else .. we have taken #11 as it is bigger thatn 1/2 of time periond
//         #20 rxd=0; // marking the start b

//         $display($time, " ----start process-----");
        
//         rdata(1);
//         $display($time, " ----rdata 1-----");
//         rdata(0);
//         $display($time, " ----rdata 2-----");

//         rdata(1);
//         $display($time, " ----rdata 3-----");
//         rdata(0);
//         $display($time, " ----rdata 4-----");

//         rdata(1);
//         $display($time, " ----rdata 5-----");
//         rdata(0);
//         $display($time, " ----rdata 6-----");

//         rdata(1);
//         $display($time, " ----rdata 7-----");
//         rdata(0);
//         $display($time, " ----rdata 8-----"); 

//         // we need to supply stop bit after 8th bit
//         rdata(1);
//         $display($time, " ----stop bit-----"); 

//     end

//     task 
//        rdata: 
//         input inp;
//         begin
//             if (posedge tick) begin
//                 rxd= inp;
//                 $display($time, " ----supply data -----");
//             end

//         end
       
//     endtask

//     intial begin
//         $dumpfile("receiver.vcd");
//         $dumpvars(2, test_rx);
//     end


// endmodule

// module uart_rx_tb;

//     // Testbench signals
//     reg clk, reset, rxd;
//     wire rx_done;
//     wire [7:0] data_out;

//     // Instantiate the UART receiver
//     uart_rx uut (
//         .clk(clk),
//         .reset(reset),
//         .rxd(rxd),
//         .rx_done(rx_done),
//         .data_out(data_out)
//     );

//     // Clock generation (50 MHz)
//     always #10 clk = ~clk;  // 20ns period => 50 MHz

//     // Testbench tasks
//     task send_byte(input [7:0] data);
//         integer i;
//         begin
//             // Start bit
//             rxd = 0;
//             #8680; // One bit time (115200 baud rate)

//             // Data bits
//             for (i = 0; i < 8; i = i + 1) begin
//                 rxd = data[i];
//                 #8680;
//             end

//             // Stop bit
//             rxd = 1;
//             #8680;
//         end
//     endtask

//     // Test scenarios
//     initial begin
//         // VCD file for waveform analysis
//         $dumpfile("receive.vcd");
//         $dumpvars(0, uart_rx_tb);

//         // Initialize signals
//         clk = 0;
//         reset = 1;
//         rxd = 1; // Idle state for UART is high
//         #100;

//         // De-assert reset and begin testing
//         reset = 0;

//         // Send data bytes
//         send_byte(8'b10101010); // Alternating pattern
//         #100000; // Wait for some time

//         send_byte(8'b11001100); // Another data pattern
//         #100000; 

//         send_byte(8'b11110000); // Back-to-back data
//         #100000;

//         $display("Test Completed");
//         $finish;
//     end

//     // Monitor received data
//     always @(posedge rx_done) begin
//         $display("Received Data: %b", data_out);
//     end

// endmodule
 
 //------------------- version 1 OG module
// module test_rx;

//     reg clk, reset, rxd;
//     wire rx_done;
//     wire [7:0] data_out;
//     wire tick;

//     uart_rx UUT(clk, reset, rxd, rx_done, data_out, tick); // insantiation of the moduel

//     always #10 clk= ~clk; // 50 mhz clock

//     initial begin
//         clk= 0;
//         reset=1; // here if will be exceuted
//         #11 reset =0; // here executing else .. we have taken #11 as it is bigger thatn 1/2 of time periond
//         #20 rxd=0; // marking the start b

//         $display($time, " ----start process-----");
        
//         rdata(1);
//         $display($time, " ----rdata 1-----");
//         rdata(0);
//         $display($time, " ----rdata 2-----");

//         rdata(1);
//         $display($time, " ----rdata 3-----");
//         rdata(0);
//         $display($time, " ----rdata 4-----");

//         rdata(1);
//         $display($time, " ----rdata 5-----");
//         rdata(0);
//         $display($time, " ----rdata 6-----");

//         rdata(1);
//         $display($time, " ----rdata 7-----");
//         rdata(0);
//         $display($time, " ----rdata 8-----"); 

//         // we need to supply stop bit after 8th bit
//         rdata(1);
//         $display($time, " ----stop bit-----"); 

//     end

//     task 
//        rdata: 
//         input inp;
//         begin
//             if (posedge tick) begin
//                 rxd= inp;
//                 $display($time, " ----supply data -----");
//             end

//         end
       
//     endtask

//     intial begin
//         $dumpfile("receiver.vcd");
//         $dumpvars(2, test_rx);
//     end


// endmodule