Multirate FIR Filter Design on FPGA (Decimation-by-3 & Interpolation-by-12)
---------------------------------------------------------------------------
--> Overview
This project implements a multirate digital signal processing pipeline on FPGA, combining decimation-by-3 and interpolation-by-12 stages built around a 51-tap FIR lowpass filter. The design targets a system clock of 120 MHz and uses Q1.15 fixed-point arithmetic for hardware-efficient, low-latency signal processing.

--> Key Features
1.Decimation-by-3 and interpolation-by-12 multirate filtering chain
2.51-tap FIR lowpass filter generated using the Xilinx FIR Compiler IP
3.Fixed-point (Q1.15) arithmetic for resource-efficient hardware implementation
4.Operating frequency: 120 MHz
5.Golden reference model developed in MATLAB for functional verification against the RTL/IP output

--> Tools & Technology
Xilinx Vivado 2025.2	Synthesis, implementation, IP integration
Xilinx FIR Compiler IP	FIR filter core generation
MATLAB	Golden reference model / verification
Verilog/SystemVerilog	RTL design

--> Design Approach
Defined filter specifications (passband, stopband, sampling rate) for the 51-tap lowpass filter.
Generated the FIR core using Xilinx FIR Compiler IP with Q1.15 fixed-point coefficients.
Built decimation-by-3 and interpolation-by-12 datapaths around the FIR core to change the effective sampling rate.
Developed a MATLAB golden model to generate expected outputs for verification.
Simulated and debugged the RTL in Vivado, resolving elaboration errors and IP parameter mismatches through iterative testing.

--> Future Work
Extend to variable decimation/interpolation ratios
Hardware validation on target FPGA board
Resource and timing optimization

--> Author
Chinmayapooranee GA



ChiN (Chinmayapooranee G A)
ECE Graduate, Mepco Schlenk Engineering College
