`timescale 1ns/1ps 
`define idle  3'b000
`define start 3'b001
`define trans 3'b010
`define stop  3'b011

module uart_tx(clk, reset, tx_start, data_in, txd, tx_done);
    input clk, reset, tx_start;
    input [7:0] data_in;
    output txd;
    output reg tx_done;

    // Baud rate generator signal declaration
    wire tick;
    reg [11:0] q;  // here q is my counter counts that will give me tick pulse
    wire [11:0] q_next;

    // Register Declarations
    reg [2:0] ps, ns; // Present state and next state
    reg [7:0] sbuf_reg, sbuf_next; // Data buffer
    reg [3:0] count_reg, count_next; // Bit counter (4 bits needed for counting 8 bits)
    reg tx_reg, tx_next; // Transmission register

    // Memory block for FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ps <= `idle;
            sbuf_reg <= 0;
            count_reg <= 0; // Initializing count register
            tx_reg <= 1;    // Default high as TX line idle is HIGH
            tx_done <= 0;
        end 
        else begin
            ps <= ns;
            sbuf_reg <= sbuf_next;
            count_reg <= count_next;
            tx_reg <= tx_next;
            if (ps == `stop) 
                tx_done <= 1; // Ensures tx_done is asserted only in the stop state
            else 
                tx_done <= 0;
        end
    end

    // Next state and output logic combined
    always @(*) begin
        ns = ps;
        sbuf_next = sbuf_reg;
        count_next = count_reg;
        tx_next = tx_reg;

        case (ps)
            `idle: begin
                $display($time, " -----  idle state--------");
                tx_next = 1; // TX line idle state is HIGH
                if (tx_start) begin
                    ns = `start; // Transition to start state on tx_start signal
                    $display($time, " >>>>>>>>>>>>>>>>>>>>idle to start state>>>>>>>>>>>>>>>");
                end
            end

            `start: begin
                tx_next = 0; // Start bit (LOW)
                $display($time, " ----- start state---------");
                if (tick) begin // Data transfer initiates with tick signal
                    sbuf_next = data_in; // Load data into buffer
                    count_next = 0; // Initialize bit counter
                    ns = `trans; // Transition to transmission state
                    $display($time, ">>>>>>>>>>>>>>>>>>start to trans>>>>>>>>>>>>>>");
                end
            end

            `trans: begin
                tx_next = sbuf_reg[0]; // Transmit LSB first
                $display($time, " ----------trans state----------");
                if (tick) begin
                    sbuf_next = sbuf_reg >> 1; // Right shift buffer data
                    if (count_reg == 7) begin // Check if all bits sent
                        ns = `stop; // Move to stop state
                        $display($time, " >>>>>>>>>>>>>>>>trans to stop>>>>>>>>>>>>>");
                    end
                    else count_next = count_reg + 1; // Increment bit counter
                end
            end

            `stop: begin
                tx_next = 1; // Stop bit (HIGH)
                $display($time, " -----------stop state-----------");
                if (tick) begin
                    ns = `idle; // Return to idle state
                end
            end

            default: begin
                ns = `idle; // Default state is idle
            end
        endcase
    end

    assign txd = tx_reg;

    // ----------------------------------------------------
    // Baud rate generator logic --------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 0;
        end
        else begin
            q <= q_next;
        end
    end

    assign q_next = (q == 2604) ? 0 : q + 1;
    assign tick = (q == 2604) ? 1 : 0; // Tick signal generation for baud rate timing

endmodule


//-------------------------------------

// `define idle  3'b000
// `define start 3'b001
// `define trans 3'b010
// `define stop  3'b011

// module uart_tx(clk, reset, tx_start, data_in, txd, tx_done);
//     input clk, reset, tx_start;
//     input [7:0] data_in;
//     output txd;
//     output reg tx_done;

//     // Baud rate generator signal declaration
//     wire tick;
//     reg [11:0] q;  // here q is my counter counts that will give me tick pulse
//     wire [11:0] q_next;

//     // Register Declarations
//     reg [2:0] ps, ns; // Present state and next state
//     reg [7:0] sbuf_reg, sbuf_next; // Data buffer
//     reg [3:0] count_reg, count_next; // Bit counter (4 bits needed for counting 8 bits)
//     reg tx_reg, tx_next; // Transmission register

//     // Memory block for FSM
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             ps <= `idle;
//             sbuf_reg <= 0;
//             count_reg <= 0; // Initializing count register
//             tx_reg <= 1;    // Default high as TX line idle is HIGH
//             tx_done <= 0;
//         end 
//         else begin
//             ps <= ns;
//             sbuf_reg <= sbuf_next;
//             count_reg <= count_next;
//             tx_reg <= tx_next;
//             if (ps == `stop) 
//                 tx_done <= 1; // Ensures tx_done is asserted only in the stop state
//             else 
//                 tx_done <= 0;
//         end
//     end

//     // Next state and output logic combined
//     always @(*) begin
//         ns = ps;
//         sbuf_next = sbuf_reg;
//         count_next = count_reg;
//         tx_next = tx_reg;

//         case (ps)
//             `idle: begin
//                 $display($time, " -----  idle state--------");
//                 tx_next = 1; // TX line idle state is HIGH
//                 if (tx_start) begin
//                     ns = `start; // Transition to start state on tx_start signal
//                     $display($time, " >>>>>>>>>>>>>>>>>>>>idle to start state>>>>>>>>>>>>>>>");
//                 end
//             end

//             `start: begin
//                 tx_next = 0; // Start bit (LOW)
//                 $display($time, " ----- start state---------");
//                 if (tick) begin // Data transfer initiates with tick signal
//                     sbuf_next = data_in; // Load data into buffer
//                     count_next = 0; // Initialize bit counter
//                     ns = `trans; // Transition to transmission state
//                     $display($time, ">>>>>>>>>>>>>>>>>>start to trans>>>>>>>>>>>>>>");
//                 end
//             end

//             `trans: begin
//                 tx_next = sbuf_reg[0]; // Transmit LSB first
//                 $display($time, " ----------trans state----------");
//                 if (tick) begin
//                     sbuf_next = sbuf_reg >> 1; // Right shift buffer data
//                     if (count_reg == 7) begin // Check if all bits sent
//                         ns = `stop; // Move to stop state
//                         $display($time, " >>>>>>>>>>>>>>>>trans to stop>>>>>>>>>>>>>");
//                     end
//                     else count_next = count_reg + 1; // Increment bit counter
//                 end
//             end

//             `stop: begin
//                 tx_next = 1; // Stop bit (HIGH)
//                 $display($time, " -----------stop state-----------");
//                 if (tick) begin
//                     ns = `idle; // Return to idle state
//                 end
//             end

//             default: begin
//                 ns = `idle; // Default state is idle
//             end
//         endcase
//     end

//     assign txd = tx_reg;

//     // ----------------------------------------------------
//     // Baud rate generator logic --------------------------
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             q <= 0;
//         end
//         else begin
//             q <= q_next;
//         end
//     end

//     assign q_next = (q == 2604) ? 0 : q + 1;
//     assign tick = (q == 2604) ? 1 : 0; // Tick signal generation for baud rate timing

// endmodule


//----------------------------------

// `define idle  3'b000
// `define start 3'b001
// `define trans 3'b010
// `define stop  3'b011

// module uart_tx(clk, reset, tx_start, data_in, txd, tx_done);
//     input clk, reset, tx_start;
//     input [7:0] data_in;
//     output txd;
//     output reg tx_done;

//     // Baud rate generator signal declaration
//     wire tick;
//     reg [11:0] q;  // here q is my counter counts that will give me tick pulse
//     wire [11:0] q_next;

//     // Register Declarations
//     reg [2:0] ps, ns; // Present state and next state
//     reg [7:0] sbuf_reg, sbuf_next; // Data buffer
//     reg [3:0] count_reg, count_next; // Bit counter (4 bits needed for counting 8 bits)
//     reg tx_reg, tx_next; // Transmission register

//     // Memory block for FSM
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             ps <= `idle;
//             sbuf_reg <= 0;
//             count_reg <= 0; // Initializing count register
//             tx_reg <= 0; // Initializing txd_done signal
//         end 
//         else begin
//             ps <= ns;
//             sbuf_reg <= sbuf_next;
//             count_reg <= count_next;
//             tx_reg <= tx_next;
//         end
//     end

//     // Next state and output logic combined
//     always @(*) begin
//         ns = ps;
//         sbuf_next = sbuf_reg;
//         count_next = count_reg;
//         tx_next = tx_reg;

//         case (ps)
//             `idle: begin
//                 $display($time, " -----  idle state--------");
//                 tx_next = 1; // TX line idle state is HIGH
//                 tx_done = 0; // Ensures done signal is low in idle
//                 if (tx_start) begin
//                     ns = `start; // Transition to start state on tx_start signal
//                     $display($time, " >>>>>>>>>>>>>>>>>>>>idle to start state>>>>>>>>>>>>>>>");
//                 end
//             end

//             `start: begin
//                 tx_next = 0; // Start bit (LOW)
//                 $display($time, " ----- start state---------");
//                 if (tick) begin // Data transfer initiates with tick signal
//                     sbuf_next = data_in; // Load data into buffer
//                     count_next = 0; // Initialize bit counter
//                     ns = `trans; // Transition to transmission state
//                     $display($time, ">>>>>>>>>>>>>>>>>>start to trans>>>>>>>>>>>>>>");
//                 end
//             end

//             `trans: begin
//                 tx_next = sbuf_reg[0]; // Transmit LSB first
//                 $display($time, " ----------trans state----------");
//                 if (tick) begin
//                     sbuf_next = sbuf_reg >> 1; // Right shift buffer data
//                     if (count_reg == 7) begin // Check if all bits sent
//                         ns = `stop; // Move to stop state
//                         $display($time, " >>>>>>>>>>>>>>>>trans to stop>>>>>>>>>>>>>");
//                     end
//                     else count_next = count_reg + 1; // Increment bit counter
//                 end
//             end

//             `stop: begin
//                 tx_next = 1; // Stop bit (HIGH)
//                 $display($time, " -----------stop state-----------");
//                 if (tick) begin
//                     tx_done = 1; // Transmission complete
//                     ns = `idle; // Return to idle state
//                 end
//             end

//             default: begin
//                 ns = `idle; // Default state is idle
//                 tx_done = 0;
//             end
//         endcase
//     end

//     assign txd = tx_reg;

//     // ----------------------------------------------------
//     // Baud rate generator logic --------------------------
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             q <= 0;
//         end
//         else begin
//             q <= q_next;
//         end
//     end

//     assign q_next = (q == 2604) ? 0 : q + 1;
//     assign tick = (q == 2604) ? 1 : 0; // Tick signal generation for baud rate timing

// endmodule


//.....................................older versions.......................

// // `include "baud_rate_generator.v"

// `define idle  3'b000
// `define start 3'b001
// `define trans 3'b010
// `define stop  3'b011

// module uart_tx(clk, reset, tx_start, data_in, txd, tx_done);
//     input clk, reset, tx_start;
//     input [7:0] data_in;
//     output txd;
//     output reg tx_done;

//     // this tick is declared as baud rate generator will be added here on top of this module
//     wire tick;
//     reg [11:0] q;
//     wire [11:0] q_next;

//     // for any state machine we have 3 blocks
//     // input block , output block and a memory block
//     // first of all we are implementing the state machine for transmitter which is mentioned in the documentation

//     // Register Declarations
//     reg [2:0] ps, ns; // Present state and next state
//     reg [7:0] sbuf_reg, sbuf_next; // Data buffer
//     reg [3:0] count_reg, count_next; // Bit counter (4 bits needed for counting 8 bits)
//     reg tx_reg, tx_next; // Transmission register

//     //memory block for fsm
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             ps <= `idle;
//             sbuf_reg <= 0;
//             count_reg <= 0; // count reg is the present value of count stored in this
//             tx_reg <= 0; // this is initialization for txd_done signal. i just have renamed here
//         end 
//         else begin
//             ps <= ns;
//             sbuf_reg <= sbuf_next;
//             count_reg <= count_next;
//             tx_reg <= tx_next;
//         end
//     end

//     //next state block and output block are combined here
//     always @(*) begin
//         ns = ps;
//         sbuf_next = sbuf_reg;
//         count_next = count_reg;
//         tx_next = tx_reg;

//         case (ps)
//             `idle: begin
//                 $display($time, " -----  idle state--------");
//                 tx_next = 1;
//                 tx_done = 0; // initialised the value of output there
//                 if (tx_start) begin
//                     ns = `start; // move to next state when start bit is there
//                     $display($time, " >>>>>>>>>>>>>>>>>>>>idle to start state>>>>>>>>>>>>>>>");
//                 end
//             end

//             `start: begin
//                 tx_next = 0; // start bit should be 0
//                 $display($time, " ----- start state---------");
//                 if (tick) begin // data transfer will happen only if tick is there
//                     sbuf_next = data_in; // data should be assigned to sbuf reg
//                     count_next = 0; // count should be initialized
//                     ns = `trans; // it will go to trans state without any input
//                     $display($time, ">>>>>>>>>>>>>>>start to trans>>>>>>>>>>>>>>");
//                 end
//             end

//             `trans: begin
//                 tx_next = sbuf_reg[0]; // setting the value of tx_next
//                 $display($time, " ----------trans state----------");
//                 if (tick) begin
//                     sbuf_next = sbuf_reg >> 1; // shifting operation is done.. here we have done right shift
//                     if (count_reg == 7) begin
//                         ns = `stop;
//                         $display($time, " >>>>>>>>>>>>>>>>trans to stop>>>>>>>>>>>>>");
//                     end
//                     else count_next = count_reg + 1; // update the count
//                 end
//             end

//             `stop: begin
//                 tx_next = 1; // giving the value of start bit
//                 $display($time, " -----------stop state-----------");
//                 if (tick) begin
//                     tx_done = 1; // this means all the operation is done
//                     ns = `idle;
//                 end
//             end

//             default: begin
//                 ns = `idle;
//                 tx_done = 0;
//             end
//         endcase
//     end

//     assign txd = tx_reg;

//     //----------------------------------------------------
//     // baud rate generator program------------------------

//     always @(posedge clk or posedge reset) begin
//     if (reset) begin
//         q <= 0;
//     end
//     else begin
//         q <= q_next;
//     end
//     end

//     assign q_next = (q == 2604) ? 0 : q + 1;
//     assign tick = (q == 2604) ? 1 : 0;


// endmodule



//////////////////////////////////////////////////my code//////

// //defining the states here
// `include "baud_rate_generator.v"

// `define idle 3'b000
// `define start 3'b001
// `define trans 3'b010
// `define stop 3'b011

// module uart_tx(clk, reset, tx_start, data_in, txd, tx_done);
//     input clk, reset, tx_start;
//     input [7:0] data_in;
//     output txd, tx_done;
    
//     // this tick is declared as baud rate generator will be added here on top of this module

//     wire tick ;
//     reg [11:0] q;
//     wire [11:0] q_next;

//     // for any state machine we have 3 blocks
//     // input block , output block and a memory block
//     // first of all we are implementing the state machine for transmitter which is mentioned in the documentation
    
//     //memory block for fsm
//     always @(posedge clk) begin
//       if(reset) begin
//         ps = `idle;
//         sbuf_reg=0;
//         count_reg=0; // count reg is the present value of count stored in thi
//         tx_reg=0; // this is initialization for txd_done signal . ijust have remaed here
//       end
//       else begin
//         ps = ns;
//         sbuf_reg=sbuf_next;
//         count_reg= count_next;
//         tx_reg= tx_next ;
//       end

//     end

//     //next state block and output block are combined here

//     always @(*) begin
//         ns = ps;
//         sbuf_next=sbuf_reg;
//         count_next= count_reg;
//         tx_next= tx_reg ;

//         // declaring the state machine

//         case (ps)
//             `idle: begin
//                 $display ($time , " ----->> this is idle state");
//                 tx_next=1;
//                 tx_done=0; // initialised the value of output there

//                 if(tx_start==1) begin
//                     ns= `start;  // move to next state when start bit tis there
//                     $display($time, "----idle to start state----")
//                 end
//             end
// // declaring when my ps is start and i am here giving the value of outputs and also explaining how it will move to trans state
//             `start : begin
//                 tx_next=0; // start bit should be 0
//                 $display ($time , " ----->> this is start state");

//                 if (tick) begin // data transfaer will happen only if tick is there
//                     //data should be asigned to sbuf reg
//                     sbuf_reg = data_in;
//                     count_next = 0; // count should be intiales

//                     ns= `trans; /// as it will go to rans state without any input
//                     $display ($time , " ----->> start to trans--------");
//                 end


                
//             end

//             `trans: begin
//                 tx_next = sbuf_reg[0]; // setting the value of tx_next
                
//                 $display ($time , " ----->> this is trans state");
//                 if(tick) begin
//                     sbuf_next= sbuf_reg>>1; //shifting operation is done.. here we have done right shift

//                     if(count_reg==7) begin
//                         ns= `stop;
//                         $display ($time , " ----->> trans to stop------");
//                     end
//                     else begin
//                         count_next= count_reg=1; //update the count
//                     end
                    
//                     // count_next= count_reg+1; // updating the count value

//                 end

//             end

//             `stop : begin
//                 tx_next =1; // giving the value os start bit
//                 $display ($time , " ----->> this is stop state");

//                 if(tick) begin
//                     tx_done =1; // ths means all the operation is done
//                     ns= `idle;
//                 end
                
//             end
//             default: ns=`idle;


//         endcase
      
//     end
//     assign txd= tx_reg;
//     //----------------------------------------------------
//     // baud rate generator program------------------------

//     always@(posedgeclk)begin
//         if(reset) begin
//             q=0;
//         end
//         else
//         q= q_next;
//     end
//     assign q_next= (q==2604)? 0:q+1;
//     assign tick = (q==2604) ? 1 : 0;


// endmodule
