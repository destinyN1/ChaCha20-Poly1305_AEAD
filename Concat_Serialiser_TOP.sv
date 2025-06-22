`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2025 01:32:04 PM
// Design Name: 
// Module Name: Concat_Serialiser_TOP
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

//typedef logic [31:0] word_t;

module Concat_Serialiser_TOP #(parameter DATA_SIZE = 8, NUM_MATRICES = 1, NO_REG = 64 * NUM_MATRICES  )(
 
 input logic clk, rst,load_en,
 input word_t indata[3:0][3:0],
//can maybe use this as a signal to reset the concat
 
 output logic [DATA_SIZE-1:0]    concatout [0:NO_REG-1],  // Array output //X then Y 
 output logic full
 
 
    );
    
    logic concat_en;
    logic [7:0] outdata_split;
    word_t outdata;  // Added missing signal
    logic Crst; // will reset the C when full is high
    

    
 Serialiser S (
        .clk(clk),
        .rst(rst),
        .indata(indata),
        .load_enable(load_en),  // Fixed: was load_enable instead of load_en
        .outdata(outdata),      // Added missing connection
        .validS(validS),        // Added missing connection
        .concat_en(concat_en),
        .full(full),
        .outdata_split(outdata_split)  // Fixed: was using wrong signal name
    );  
    
     Concatenator #(
        .DATA_SIZE(8),
        .NUM_MATRICES(1),
        .NO_REG(64*NUM_MATRICES)
    ) C (
        .clk(clk), 
        .rst(rst),  // Added missing rst connection
        .concat_en(concat_en),
        .input_data_split(outdata_split),  // Fixed: was using wrong signal name
        .full(full),
        .concatout(concatout)
    );
     
    
endmodule
