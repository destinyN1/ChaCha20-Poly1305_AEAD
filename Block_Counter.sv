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

(
input logic clk, init,
input logic [31:0] blocksproduced,
output  word_t Block



    );
    
   logic overflowflag; 
   word_t blocksproduced_prev;
    
    
 always_ff @(posedge clk) begin
 
 //inititialisation
  if (init) begin
   Block <= '{default:0};
   overflowflag <= 0;
   blocksproduced_prev <= blocksproduced;
   end
   
  else begin

//check for overflow  
   if (Block == (32'hFFFFFFFF )) begin
        overflowflag <= 1'b1;
        Block <= '{default:0};
    end 
    
    
   else if (blocksproduced != blocksproduced_prev) begin
  
//  //only increment the block counter if the the blocksproduced value has changed 
    
  
   Block <= Block + 1;
   overflowflag <= 1'b0;
   blocksproduced_prev <= blocksproduced;
 
   end
   
   if (blocksproduced == blocksproduced_prev) begin
    Block <= Block;
   
   
   end
   
    
   end
   end
   
   
  
  
    
endmodule
