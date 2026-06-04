# project_MIPS

# MIPS Processor Pipeline Implementation
This project implements a pipelined MIPS processor using Verilog HDL and verifies its functionality through Vivado behavioral simulation and FPGA peripheral tests.

## Features
- Pipelined MIPS processor with full harzard handling implementation
- Behavioral simulation testbenches
- GPIO LED peripheral test
- 7-segment display peripheral test
- FPGA constraint files for board-level implementation

## Tools
- Verilog HDL
- Xilinx Vivado
- FPGA board: Artix-7 XC7A75T-1FGG484C

## Directory Structure
- hardware/rtl: RTL source files
- hardware/testbench: simulation testbenches
- hardware/impl: XDC constraint files
- hex: test programs for LED and 7-segment output

## Results
- Verified CPU behavior through simulation
- Verified GPIO LED and 7-segment peripheral operation

<img width="957" height="561" alt="testbench_TCL_result" src="https://github.com/user-attachments/assets/d2872116-6eba-4987-bc04-3b95f8061067" />
<img width="1918" height="1020" alt="result" src="https://github.com/user-attachments/assets/9ba9e04e-32dd-49fe-adff-2ac4af69b479" />
