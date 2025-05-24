`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 04:25:28 PM
// Design Name: 
// Module Name: Block_Counter
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

typedef logic [31:0] word_t;

module Block_Counter 
#(parameter B = 4)
(
input logic clk, init,
input logic [B-1:0] blocksproduced,
output  word_t Block


    );
    
 always_ff @(posedge clk) begin
  if (init) begin
   Block <= '{default:0};
   end
  else begin
   Block <= Block + 4'b1;
   end
   
   end
   
  
  
    
endmodule
