`define idle  3'b000
`define start 3'b001
`define trans 3'b010
`define stop  3'b011

module uart_rx(clk, reset, rxd, rx_done, data_out, tick);
    input clk, reset, rxd;
    output reg rx_done;
    output wire [7:0] data_out;
    output wire tick;  // Added tick as output declaration

    reg [2:0] ps, ns;
    reg [7:0] sbuf_reg, sbuf_next;
    reg [2:0] count_next, count_reg;

    reg [12:0] q;
    wire [12:0] q_next;

    // Memory block of state machine
    always @(posedge clk) begin
        if (reset) begin
            sbuf_reg <= 0;
            ps <= `idle;
            count_reg <= 0;
            rx_done <= 0;
        end else begin
            ps <= ns;
            count_reg <= count_next;
            sbuf_reg <= sbuf_next;
        end
    end

    // Next state logic and output block
    always @(*) begin
        ns = ps;
        sbuf_next = sbuf_reg;
        count_next = count_reg;

        case (ps)
            `idle: begin
                rx_done = 0;
                if (rxd == 0) ns = `start; // Detect start bit
            end

            `start: begin
                if (tick && rxd == 0) begin
                    ns = `trans;
                    count_next = 0;
                end
            end

            `trans: begin
                if (tick) begin
                    sbuf_next = {rxd, sbuf_next[7:1]};
                    if (count_reg == 7) ns = `stop;
                    else count_next = count_reg + 1;
                end
            end

            `stop: begin
                if (tick && rxd == 1) begin
                    ns = `idle;
                    rx_done = 1;
                end
            end

            default: ns = `idle;
        endcase
    end

    assign data_out = sbuf_reg;

    // Baud rate generator logic (adjusted for stable tick generation)
    always @(posedge clk or posedge reset) begin
        if (reset) q <= 0;
        else q <= q_next;
    end

    assign q_next = (q == 2604) ? 0 : q + 1; // Correct baud timing for 19200 baud rate
    assign tick = (q == 1302);                // Mid-bit sample tick signal
endmodule





//----------------------version 2-----------

// // `include "baud_rate_generator.v"

// `define idle 3'b000
// `define start 3'b001
// `define trans 3'b010
// `define stop 3'b011

// module uart_rx(clk, reset, rxd, rx_done, data_out);
//     input clk, reset, rxd;
//     output reg rx_done;
//     output wire [7:0] data_out;

//     reg [2:0] ps, ns;
//     reg [7:0] sbuf_reg, sbuf_next;
//     reg [2:0] count_next, count_reg;

//     reg [11:0] q;
//     wire [11:0] q_next;
//     wire tick;

//     // Declaring state machine

//     // Memory block of state machine
//     always @(posedge clk) begin
//         if (reset) begin
//             sbuf_reg <= 0;   // Resetting shift buffer
//             ps <= `idle;     // Initializing state to idle
//             count_reg <= 0;  // Resetting count
//             rx_done <= 0;    // Ensuring rx_done is cleared on reset
//         end else begin
//             ps <= ns;
//             count_reg <= count_next;
//             sbuf_reg <= sbuf_next;
//         end
//     end

//     // Next state block as well as output block of FSM
//     always @(*) begin
//         ns = ps;
//         sbuf_next = sbuf_reg;
//         count_next = count_reg;

//         // Declaring all the states now
//         case (ps)
//             `idle: begin
//                 $display($time, "----------IDLE STATE-----------");
//                 rx_done = 0; // Reset rx_done in idle state
//                 if (rxd == 0) begin
//                     ns = `start;
//                     $display($time, ">>>>>>>>>>>>>>IDLE STATE TO START STATE>>>>>>>>>>>>>>>>>>");
//                 end
//             end

//             `start: begin
//                 $display($time, "----------START STATE-----------");
//                 if (tick) begin
//                     ns = `trans;
//                     $display($time, ">>>>>>>>>>>>>> START STATE TO TRANS STATE >>>>>>>>>>>>>>>>>>");
//                     count_next = 0;
//                 end
//             end

//             `trans: begin
//                 $display($time, "---------- TRANS STATE-----------");
//                 if (tick) begin
//                     sbuf_next = {rxd, sbuf_next[7:1]}; // Stable shift with correct positioning
//                     if (count_reg == 7) begin
//                         ns = `stop;
//                         $display($time, ">>>>>>>>>>>>>> TRANS STATE to STOP STATE >>>>>>>>>>>>>>>>>>");
//                     end else begin
//                         count_next = count_reg + 1;
//                     end
//                 end
//             end

//             `stop: begin
//                 $display($time, "---------- STOP STATE-----------");
//                 if (tick) begin
//                     ns = `idle;
//                     $display($time, ">>>>>>>>>>>>>> STOP STATE to IDLE state >>>>>>>>>>>>>>>>>>");
//                     rx_done = 1;
//                 end
//             end

//             default: ns = `idle;
//         endcase
//     end

//     assign data_out = sbuf_reg; 

//     // Baud rate generator logic --------------------------
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             q <= 0;
//         end else begin
//             q <= q_next;
//         end
//     end

//     assign q_next = (q == 2604) ? 0 : q + 1;
//     assign tick = (q == 2604) ? 1 : 0; // Tick signal generation for baud rate timing

// endmodule



//--------------------- version 1 OG version----------------

// `define idle 3'b000
// `define start 3'b001
// `define trans 3'b010
// `define stop 3'b011

// module uart_rx(clk, reset, rxd,rx_done, data_out);
//     input clk, reset, rxd;
//     output reg rx_done;
//     output reg [7:0]data_out;

//     reg [2:0]ps, ns;
//     reg [7:0]sbuf_reg,sbuf_next;
//     reg [2:0] count_next, count_reg;

//     wire tick;

//     //declaring state machine

//     // memory block of state machine
//     always @(posedge clk) begin
//         if(reset) begin
//             sbuf_reg=0;
//             ps=`idle;
//             count_reg=0;
//         end
//         else begin
//             ps=ns;
//             count_reg=count_next;
//             sbuf_reg=sbuf_next;

//         end
//     end

//     // next state block as well as output block of FSM

//     always @(*) begin
//         ns=ps;
//         sbuf_next=sbuf_reg;
//         count_next=count_reg;

//         //declaring all the states now

//         case(ps)
//         `idle: begin
//             $display($time, "----------IDLE STATE-----------");
//             if(rxd==0) begin
//                 ns=`start;
//                 $display($time, ">>>>>>>>>>>>>>>>IDLE STATE TO START STATE>>>>>>>>>>>>>>>>>>");
//             end 
//         end

//         `start : begin
//            $display($time, "----------STARRT STATE-----------"); 
//            if(tick) begin
//             ns= `trans;
//             $display($time, ">>>>>>>>>>>>>>>> START STATE TO TRANS STATE >>>>>>>>>>>>>>>>>>");
//             count_next=0;

//            end
//         end

//         `trans: begin
//             $display($time, "---------- TRANS STATE-----------"); // here shifting takes place
//             if(tick) begin
//                 sbuf_next= {sbuf_next[7:1],rxd};// here we are concatening  this is shiftting
//                 if(count_reg==7) begin
//                     ns= `stop;
//                      $display($time, ">>>>>>>>>>>>>>>> TRANS STATE to STOP STATE >>>>>>>>>>>>>>>>>>");
//                 end
//                 else begin
//                     count_next= count_reg+1;
//                 end

//             end

            
//         end

//         `stop: begin
//             $display($time, "---------- STO PSTATE-----------"); 
//             if (tick) begin
//                 ns= `idle;
//                 $display($time, ">>>>>>>>>>>>>>>> STOP STATE to IDLE state >>>>>>>>>>>>>>>>>>");
//                 rx_done= 1;


                

//             end
//         end
//         default: ns=`idle;

//         endcase


        
//     end

//     assign data_out= sbuf_reg;




// endmodule