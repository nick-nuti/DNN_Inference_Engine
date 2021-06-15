`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2020 09:03:18 PM
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb();

    reg clk96 = 0;
    reg in_ready96 = 0;
    reg[5:0][15:0] in_neuron_values96;
    //reg[5:0][15:0] in_neuron_values96one = '{16'hA949, 16'hA95D, 16'h9FC8, 16'h1419, 16'h0000, 16'h0000};
    //reg[5:0][15:0] in_neuron_values96two = '{16'h3AA3, 16'h316B, 16'hA4D7, 16'h10EA, 16'h0000, 16'h0000};
    reg [2:0][15:0] outtie96;
    reg [1:0] loaded_in96;
    wire output_ready96;
    reg [12:0] inputcounter96 = 0;
    reg [12:0] outputcounter96 = 0;
    reg [12:0] outputcheckcounter96 = 0;
    reg checky96 = 0;
    
    shortreal operation096 [2:0];
    reg [31:0] singleprec_opone96;
    shortreal operation196 [2:0];
    reg [31:0] singleprec_optwo96;
    
    localparam NUMBER_INPUTS96=6;
    localparam NUMBER_ROUNDS96=26;
    localparam NUMBER_OUTPUTS96=3;
    
    reg [15:0] neuron_inputs96 [NUMBER_ROUNDS96-1:0][NUMBER_INPUTS96-1:0];
    reg [15:0] outputs96 [NUMBER_ROUNDS96-1:0][NUMBER_OUTPUTS96-1:0];
    reg [15:0] outputs_hold96 [NUMBER_ROUNDS96-1:0][NUMBER_OUTPUTS96-1:0];
    
    top t0 (.clk96(clk96), .in_ready96(in_ready96), .in_neuron_values96(in_neuron_values96), .loaded_in96(loaded_in96), .outtie96(outtie96), .output_ready96(output_ready96));
    
    always
    #1 clk96 <= ~clk96;

    initial begin
        $readmemh("inputs.mem", neuron_inputs96);
        $readmemb("output.mem", outputs96);
    end
    
    always@(posedge output_ready96)
    begin
        $display("OUTPUT ROUND %d", outputcounter96);
        
        outputs_hold96[outputcounter96][0] = outtie96[0];
        outputs_hold96[outputcounter96][1] = outtie96[1];
        outputs_hold96[outputcounter96][2] = outtie96[2];
        
        outputcounter96 <= outputcounter96 + 1;
        if(outputcounter96 == (NUMBER_ROUNDS96-1))
        begin
            checky96 = 1;
        end
    end
    
    always@(posedge clk96)
    begin
        if((loaded_in96[0] == 1'b0)&&(inputcounter96 < NUMBER_ROUNDS96))
        begin
            in_neuron_values96[0] = neuron_inputs96[inputcounter96][0];
            in_neuron_values96[1] = neuron_inputs96[inputcounter96][1];
            in_neuron_values96[2] = neuron_inputs96[inputcounter96][2];
            in_neuron_values96[3] = neuron_inputs96[inputcounter96][3];
            in_neuron_values96[4] = neuron_inputs96[inputcounter96][4];
            in_neuron_values96[5] = neuron_inputs96[inputcounter96][5];
            
            inputcounter96 <= inputcounter96 + 1;
            in_ready96 = 1'b1;
            #2;
            in_ready96 = 1'b0;
        end
    end
    
    always@(posedge clk96)
    begin
        if(checky96 == 1'b1)
        begin
            
            for(int i = 0; i < 3; i = i + 1)
            begin
                singleprec_opone96[30:23] = ((outputs_hold96[outputcheckcounter96][i][14:10] - 4'd15) + 8'd127);
                singleprec_opone96[31] = outputs_hold96[outputcheckcounter96][i][15];
                singleprec_opone96[22:13] = outputs_hold96[outputcheckcounter96][i][9:0];
                singleprec_opone96[12:0] = 13'd0;
                operation096[i] = $bitstoshortreal(singleprec_opone96);
                //$display("singleprec_opone96 = %b", singleprec_opone96);
                
                singleprec_optwo96[30:23] = ((outputs96[outputcheckcounter96][i][14:10] - 4'd15) + 8'd127);
                singleprec_optwo96[31] = outputs96[outputcheckcounter96][i][15];
                singleprec_optwo96[22:13] = outputs96[outputcheckcounter96][i][9:0];
                singleprec_optwo96[12:0] = 13'd0;
                operation196[i] = $bitstoshortreal(singleprec_optwo96);
                //$display("singleprec_optwo96 = %b", singleprec_optwo96);
            end
            
            $display("my: %7.7f , actual: %7.7f", operation096[0], operation196[0]);
            $display("percent error = %7.7f", (((operation096[0] - operation196[0])/operation196[0])*100));
            $display("my: %7.7f , actual: %7.7f", operation096[1], operation196[1]);
            $display("percent error = %7.7f", (((operation096[1] - operation196[1])/operation196[1])*100));
            $display("my: %7.7f , actual: %7.7f", operation096[2], operation196[2]);
            $display("percent error = %7.7f", (((operation096[2] - operation196[2])/operation196[2])*100));
            
            outputcheckcounter96 = outputcheckcounter96 + 1;
            
            if(outputcheckcounter96 == (NUMBER_ROUNDS96-1))
            begin
                #10;
                $finish;
            end
        end
    end
endmodule
