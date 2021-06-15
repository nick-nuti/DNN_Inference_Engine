# DNN_Inference_Engine

___Information about inner-workings of the project will be added later.___

General Explanation:
- Pipelined System Verilog Floating-point Matrix MAC with One-Neuron Shift-in
- Uses stored ".mem" files to multiply-accumulate an input matrix with two sets of weight matrices
- Test bench takes all output data and displays the accuracy of the "black box" system; data accuracy has an error ranging from ~0% to ~2% on average

*** NOTE: This project was designed based on testbench requirements, BUT is synthesizable and usable on a Xilinx PYNQ-Z1 ***

***TESTED USING VIVADO 2020.2 ; DIFFERENCES IN VERSION MAY CAUSE PROJECT TO NOT WORK DUE TO FLOATING-POINT MAC IPs***

Easiest way to run the project:

1. Download *DNN_Inference_Engine.xpr.zip*
2. Extract it and open *miniproject2.xpr* in Vivado
3. Run a simulation and view the results in the "LOG" tab
