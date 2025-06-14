`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2025 04:45:12 PM
// Design Name: 
// Module Name: Concatenator_TB
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


module Concatenator_TB;

parameter DATA_SIZE = 8;
parameter NUM_MATRICES = 2;
parameter NO_REG = 64*NUM_MATRICES;

logic clk,rst,full;

logic [DATA_SIZE - 1: 0] input_data_split;

logic [DATA_SIZE-1:0] concatout [0:NO_REG - 1];



initial clk = 0;
always #5 clk = ~clk;

initial begin

//VERIFY RST
rst = 0;

@(posedge clk);
rst = 1;

//FULL AND STORAGE SHOULD BE ZERO NOW

#10;


//VERIFY FILLING OF EACH STORAGE ELEMENT WITH ADDR INCREMENT

rst = 0;





$finish;
end




endmodule
