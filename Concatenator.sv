`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025 11:19:11 AM
// Design Name: 
// Module Name: Concatenator
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


//WILL MAKE THIS A SYNCHRONOUS BUFFER
//DATA_SIZE = 8 bits, THIS IS THE SIZE OF OUR INPUT COMING FROM THE SERIALISER
//NO_REG = 64 * NO_MATRICES, LETS US SPECIFY HOW MANY SERIALISED STATE MATRICES WE CAN STORE
module Concatenator #(parameter DATA_SIZE = 8, NO_REG = 320  ) 

(

input logic  clk, rst,

input logic [DATA_SIZE-1:0] input_data_split,


output logic full




);

logic [DATA_SIZE-1:0] storage [0: NO_REG -1];

logic [$clog2(NO_REG) - 1 : 0] write_addr;

   
 
 
 
 always_ff @(posedge clk) begin
 
   if (rst) begin
   
   //SET THE ADDRESS TO ZERO AND CLEAR STORAGE ON RST
   
   //MIGHT HAVE TO DO SOMETHING ABOUT THE RESET AT SOME POINT THOUGH
   
   write_addr = '0;
   
   for (int i = 0; i < NO_REG; i++) begin
    storage[i] <= '0;
    
    end
   full <= 0;
   
   end
   
   else if (write_addr < NO_REG - 1) begin
        storage[write_addr] <= input_data_split;
        write_addr <= write_addr + 1;
    end
    else begin
    
    full <= 1;
    
    end
    
    end
        
       
        
        
   
  
 
 
   
endmodule
