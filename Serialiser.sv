`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025 11:18:43 AM
// Design Name: 
// Module Name: Serialiser
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

//will output serial data in 32 bit chunks as of now


// loosely based off of  the SerDes Architecture
module Serialiser(
    input logic clk, rst,
    input word_t indata [3:0][3:0],
    input logic load_enable,    // Signal to load new data
    output word_t outdata,
    output logic validS          // Indicates valid output
);
    
    word_t data_reg [3:0][3:0];
    logic [3:0] counter;
    logic [1:0] row, col;
    
    // Counter and address generation
    always_ff @(posedge clk) begin
        if(rst) begin
            counter <= 4'b0;
            data_reg <= '{default:0};
        end
        else if(load_enable) begin
            data_reg <= indata;
            counter <= 4'b0;
        end
        else if(counter < 4'd15) begin
            counter <= counter + 1'b1;
        end
    end
    
    // Little-endian address decoding (start from bottom-right, go backwards)
    assign row = 3 - counter[3:2];    // Invert row: 3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0
    assign col = 3 - counter[1:0];    // Invert col: 3,2,1,0,3,2,1,0,3,2,1,0,3,2,1,0
    
    // Output logic
    assign outdata = data_reg[row][col];
    assign validS = (counter <= 4'd15);
    
endmodule
    
   
 
 
    
