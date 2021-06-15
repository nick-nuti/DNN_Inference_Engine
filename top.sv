`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2020 09:02:59 PM
// Design Name: 
// Module Name: top
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


module top #(parameter NUMBER_INPUTS96 = 6, parameter NUMBER_HIDDEN_NEURONS96 = 4, parameter NUMBER_OUTPUT_NEURONS96 = 3)(
    input clk96,
    input in_ready96,
    input [NUMBER_INPUTS96-1:0][15:0] in_neuron_values96,
    output reg [1:0] loaded_in96,
    output reg [NUMBER_OUTPUT_NEURONS96-1:0][15:0] outtie96,
    output reg output_ready96
    );
    
    reg already_been_set9696 = 1'b1;
    reg [1:0] been_set96 = 2'b00;
    reg [NUMBER_INPUTS96:0][15:0] input_buff96 = 96'd0;
    reg [NUMBER_HIDDEN_NEURONS96:0][15:0] mid_buff96 = 96'd0;
    reg [3:0] hopper96 = 1'd0;
    reg [3:0] hopper96_two = 1'd0;
    //reg layer = 0;
    
    reg [NUMBER_HIDDEN_NEURONS96-1:0][2:0]input_valid_in96 = 0;
    reg [15:0] input_a_mac96 = 0;
    reg [NUMBER_HIDDEN_NEURONS96-1:0][15:0] input_b_mac96 = 0;
    reg [NUMBER_HIDDEN_NEURONS96-1:0][15:0] input_c_mac96 = 0;
    reg [NUMBER_HIDDEN_NEURONS96-1:0] input_layer_valid96;// = 0;
    reg [NUMBER_HIDDEN_NEURONS96-1:0][15:0] input_layer_output96 = 0;
    reg [NUMBER_HIDDEN_NEURONS96-1:0][15:0] in_accumulated96 = 0;
    
    reg [NUMBER_OUTPUT_NEURONS96-1:0][2:0]input_valid_hidden96 = 0;
    reg [15:0] hidden_a_mac96 = 0;
    reg [NUMBER_OUTPUT_NEURONS96-1:0][15:0] hidden_b_mac96 = 0;
    reg [NUMBER_OUTPUT_NEURONS96-1:0][15:0] hidden_c_mac96 = 0;
    reg [NUMBER_OUTPUT_NEURONS96-1:0] hidden_layer_valid96;// = 0;
    reg [NUMBER_OUTPUT_NEURONS96-1:0][15:0] hidden_layer_output96 = 0;
    reg [NUMBER_OUTPUT_NEURONS96-1:0][15:0] hidden_accumulated96 = 0;

    reg [15:0] weights_in96 [NUMBER_INPUTS96:0][NUMBER_HIDDEN_NEURONS96-1:0];
    reg [15:0] weights_hidden96 [NUMBER_HIDDEN_NEURONS96:0][NUMBER_OUTPUT_NEURONS96-1:0];
  
    initial begin
        $readmemh("weights_in.mem", weights_in96);
        $readmemh("weights_hidden.mem", weights_hidden96);
    end
    
    initial begin
        output_ready96 <= 1'b0;
        loaded_in96 <= 2'b00;
    end
    
    genvar neuron_index;
    generate
        for(neuron_index = 0; neuron_index < NUMBER_HIDDEN_NEURONS96; neuron_index += 1)
        begin
            floating_point_0 fp0 (
              .aclk(clk96),                
              .s_axis_a_tvalid(input_valid_in96[neuron_index][0]), .s_axis_a_tdata(input_a_mac96),
              .s_axis_b_tvalid(input_valid_in96[neuron_index][1]), .s_axis_b_tdata(input_b_mac96[neuron_index]),
              .s_axis_c_tvalid(input_valid_in96[neuron_index][2]), .s_axis_c_tdata(input_c_mac96[neuron_index]),
              .m_axis_result_tvalid(input_layer_valid96[neuron_index]), .m_axis_result_tdata(input_layer_output96[neuron_index])
            );
        end
        
        for(neuron_index = 0; neuron_index < NUMBER_OUTPUT_NEURONS96; neuron_index += 1)
        begin
            floating_point_0 fp1 (
              .aclk(clk96),                       
              .s_axis_a_tvalid(input_valid_hidden96[neuron_index][0]), .s_axis_a_tdata(hidden_a_mac96),
              .s_axis_b_tvalid(input_valid_hidden96[neuron_index][1]), .s_axis_b_tdata(hidden_b_mac96[neuron_index]),
              .s_axis_c_tvalid(input_valid_hidden96[neuron_index][2]), .s_axis_c_tdata(hidden_c_mac96[neuron_index]),
              .m_axis_result_tvalid(hidden_layer_valid96[neuron_index]), .m_axis_result_tdata(hidden_layer_output96[neuron_index])
            );
        end
    endgenerate
    
    always@(posedge clk96)
    begin
        //load inputs
        if((in_ready96 == 1)&&(loaded_in96[0] == 1'b0))
        begin
            
            for(int i = 0; i < NUMBER_INPUTS96+1; i += 1)
            begin
                 if(i == 0) input_buff96[i] <= 16'h3C00;
                else input_buff96[i] <= in_neuron_values96[i-1];
            end
             
            loaded_in96[0] <= 1'b1;
        end
        //

        ///inputs to hidden layer
        if(loaded_in96[0] == 1)
        begin
            if(hopper96 < (NUMBER_INPUTS96+1))
            begin
                if(been_set96[0] == 0)
                begin
                    input_a_mac96 <= input_buff96[hopper96];
                    
                    for(int in_buff = 0; in_buff < NUMBER_HIDDEN_NEURONS96; in_buff += 1)
                    begin
                        input_b_mac96[in_buff] <= weights_in96[hopper96][in_buff];
                        input_c_mac96[in_buff] <= in_accumulated96[in_buff];
                        input_valid_in96[in_buff] <= 3'b111;
                    end
                end
                
                else
                begin
                    for(int in_buff = 0; in_buff < NUMBER_HIDDEN_NEURONS96; in_buff += 1)
                    begin
                        input_valid_in96[in_buff] <= 3'b000;
                    end
                end
            end
            
            if(hopper96 == (NUMBER_INPUTS96+1)) 
            begin
                // relu
                for(int in_buff = 0; in_buff < NUMBER_HIDDEN_NEURONS96; in_buff += 1)
                begin
                    if(in_buff == 0) mid_buff96[in_buff] <= 16'h3C00;
                    else
                    begin
                        if(in_accumulated96[in_buff-1][15] == 1'b1) mid_buff96[in_buff] <= 16'h0000;
                        else mid_buff96[in_buff] <= in_accumulated96[in_buff-1];
                    end
                end
                
                loaded_in96 <= 2'b10;
            end
        end
        ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
        ////hidden layer to output layer
        if(loaded_in96[1] == 1)
        begin
            if(hopper96_two == 0) output_ready96 <= 1'd0;

            if(hopper96_two < (NUMBER_HIDDEN_NEURONS96+1))
            begin
                if(been_set96[1] == 0)
                begin
                    hidden_a_mac96 <= mid_buff96[hopper96_two];
                    
                    for(int in_buff_two = 0; in_buff_two < NUMBER_OUTPUT_NEURONS96; in_buff_two += 1)
                    begin
                        hidden_b_mac96[in_buff_two] <= weights_hidden96[hopper96_two][in_buff_two];
                        hidden_c_mac96[in_buff_two] <= hidden_accumulated96[in_buff_two];
                        input_valid_hidden96[in_buff_two] <= 3'b111;
                    end
                end
                
                else
                begin
                    for(int in_buff_two = 0; in_buff_two < NUMBER_OUTPUT_NEURONS96; in_buff_two += 1)
                    begin
                        input_valid_hidden96[in_buff_two] <= 3'b000;
                    end
                end
            end
            
            if(hopper96_two == (NUMBER_HIDDEN_NEURONS96+1)) 
            begin
                // relu
                for(int in_buff_two = 0; in_buff_two < NUMBER_OUTPUT_NEURONS96; in_buff_two += 1)
                begin
                    if(hidden_accumulated96[in_buff_two][15] == 1'b1) outtie96[in_buff_two] <= 16'd0;
                    else outtie96[in_buff_two] <= hidden_accumulated96[in_buff_two];
                end
                
                loaded_in96[1] <= 1'b0;
                output_ready96 <= 1'd1;
                //#10;
                //$finish;
            end
        end
    end
    ////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
    always@(posedge clk96)
    begin
        if((loaded_in96[0] == 1)&&(hopper96 < (NUMBER_INPUTS96+1)))
        begin
            if(&input_layer_valid96 == 1'b1)
            begin
                for(int in_buff = 0; in_buff < NUMBER_HIDDEN_NEURONS96; in_buff += 1)
                begin
                    in_accumulated96[in_buff] <= input_layer_output96[in_buff];
                end
                
                been_set96[0] <= 1'b0;
                hopper96 <= hopper96 + 1'b1;
            end
            
            else been_set96[0] <= already_been_set9696; 
        end
        
        if((loaded_in96[0] == 1)&&(hopper96 == (NUMBER_INPUTS96+1))) hopper96 <= 0; //*********watch for this possibly being a problem; make sure this and and line 149 happen in the same clock cycle
        
        else if(loaded_in96[0] == 0) // used to zero-out accumulation register used for input c and output for "input-to-hidden MACs"
        begin
            for(int in_buff = 0; in_buff < NUMBER_HIDDEN_NEURONS96; in_buff += 1)
            begin
                in_accumulated96[in_buff] <= 16'd0;
            end
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
        if((loaded_in96[1] == 1)&&(hopper96_two < (NUMBER_HIDDEN_NEURONS96+1)))
        begin
            if(&hidden_layer_valid96 == 1'b1)
            begin
                for(int in_buff_two = 0; in_buff_two < NUMBER_OUTPUT_NEURONS96; in_buff_two += 1)
                begin
                    hidden_accumulated96[in_buff_two] <= hidden_layer_output96[in_buff_two];
                end
                
                been_set96[1] <= 1'b0;
                hopper96_two <= hopper96_two + 1'b1;
            end
            
            else been_set96[1] <= already_been_set9696;
        end
        
        if((loaded_in96[1] == 1)&&(hopper96_two == (NUMBER_HIDDEN_NEURONS96+1))) hopper96_two <= 0;
        
        else if(loaded_in96[1] == 0)
        begin
            for(int in_buff_two = 0; in_buff_two < NUMBER_OUTPUT_NEURONS96; in_buff_two += 1)
            begin
                hidden_accumulated96[in_buff_two] <= 16'd0;
            end
        end
    end
    
endmodule
