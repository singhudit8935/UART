# UART PROTOCOL
# UART Communication System

This project implements a **Universal Asynchronous Receiver-Transmitter (UART)** system using Verilog HDL. The system is composed of three major modules:

1. **Baud Rate Generator**
2. **UART Transmitter**
3. **UART Receiver**

## Overview of UART System

UART is a widely used serial communication protocol that enables data transmission between devices. Key features include:
- Asynchronous communication (no clock signal required)
- Data format includes start bit, data bits, optional parity bit, and stop bit
- Common baud rates include 9600, 19200, and 115200 bps

### Project Structure
```
├── baud_rate_generator.v      # Baud rate generator for UART timing control
├── tb_baud.v                  # Testbench for Baud rate generator
├── uart_tx.v                  # UART Transmitter module
├── uart_rx.v                  # UART Receiver module
├── rx_tb.v                    # Testbench for UART Receiver
├── tx_tb.v                    # Testbench for UART Transmitter
├── README.md                  # Project documentation
```

## Modules Description

### 1. **Baud Rate Generator**
- Generates precise timing pulses (`tick`) for UART communication.
- Designed to provide correct baud rate timing (e.g., 19200 baud).
- Ensures stable data transmission by correctly sampling data at mid-bit intervals.

### 2. **UART Transmitter**
- Transmits 8-bit data frames with start, stop, and data bits.
- Uses a state machine with four states:
  - `idle` - Waits for data to transmit.
  - `start` - Sends start bit (LOW).
  - `trans` - Transmits 8 data bits.
  - `stop` - Sends stop bit (HIGH) to end transmission.

### 3. **UART Receiver**
- Receives 8-bit data frames with proper start and stop bit detection.
- Uses a state machine to ensure synchronization and error-free data reception.
- Incorporates logic to handle sampling in the middle of each bit for improved accuracy.

## How to Run the Project
1. Clone this repository:
   ```sh
   git clone https://github.com/singhudit8935/UART.git
   cd UART
   ```

2. Compile the Verilog files using a simulator like **Icarus Verilog**:
   ```sh
   iverilog -o uart_tb tb_baud.v baud_rate_generator.v uart_tx.v uart_rx.v
   vvp uart_tb
   ```

3. View waveforms using **GTKWave**:
   ```sh
   gtkwave baud_wave.vcd
   ```

## Key Features
- Fully functional UART communication system.
- Implements robust FSM logic for stable data transmission.
- Optimized for 19200 baud rate with accurate timing control.
- Includes comprehensive testbenches for easy verification.

## Future Enhancements
- Adding parity bit support for error checking.
- Implementing a FIFO buffer for efficient data handling.
- Enhancing receiver logic to detect framing errors.

## License
This project is open-source and available under the MIT License.

For questions or contributions, feel free to reach out!


 
