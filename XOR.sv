`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025 11:18:19 AM
// Design Name: 
// Module Name: XOR
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


module XOR #(parameter DATA_SIZE = 8, NUM_MATRICES = 3, NO_REG = 64 * NUM_MATRICES  )(

input logic clk,XOR_READY,

input logic [DATA_SIZE-1:0] char_in [0:NO_REG -1],
input logic [DATA_SIZE-1:0]    concatout [0:NO_REG-1],

output logic [DATA_SIZE-1:0]  Ciphertext [0:NO_REG-1]

    );
    
   always_ff @(posedge clk) begin
   
   if (XOR_READY) begin
   
   for(int i = 0; i<NO_REG; i++) begin
   
   Ciphertext[i] <= char_in[i] ^ concatout[i];
   
   end
   end
   end
    
    
endmodule
