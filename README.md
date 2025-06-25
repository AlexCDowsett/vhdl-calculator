# Low-Level UART Calculator

This project implements a low-level calculator using VHDL, featuring UART (Universal Asynchronous Receiver/Transmitter) communication. The design is suitable for FPGA development and demonstrates digital design principles, modularity, and serial communication.

## Features
- **UART Communication:** Send and receive data over a serial interface.
- **Arithmetic Operations:** Supports basic calculator functions (add, subtract, multiply, divide).
- **Modular Design:** Includes separate VHDL modules for UART, calculator logic, debouncing, and character encoding/decoding.
- **Test Benches:** Comprehensive test benches for all major components.

## File Structure
- `*.vhd` — VHDL source files for all modules and test benches
- `lab_design_top.xdc` — Xilinx constraints file for pin assignments
- `constrs/` — Directory containing constraints (if present)
- `Test_*.vhd` — Test benches for simulation

## Getting Started
1. Open the project in your preferred FPGA development environment (Vivado recommended).
2. Synthesize and implement the design.
3. Use the provided test benches to simulate and verify functionality.
4. Program your FPGA board and connect via UART to interact with the calculator.

## Author
Alex Dowsett

---
Feel free to contribute or raise issues via [GitHub](https://github.com/AlexCDowsett/vhdl-calculator). 