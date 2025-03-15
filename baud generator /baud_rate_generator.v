`timescale 1ns/1ps
module baud_gen(clk, reset, q, tick);
   input wire clk, reset;
   output reg [11:0] q;   // 12-bit counter for counting up to 2604
   output reg tick;       // Tick should be a reg for controlled assertion
   parameter MAX_CNT = 2604;

   always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 0;       // Reset counter
            tick <= 0;    // Ensure tick is also reset
        end
        else if (q == MAX_CNT) begin
            q <= 0;       // Reset counter after reaching maximum count
            tick <= 1;    // Assert tick for one clock cycle
        end
        else begin
            q <= q + 1;   // Increment counter
            tick <= 0;    // Ensure tick de-asserts immediately afterward
        end
   end
endmodule
