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
module Concatenator #(parameter DATA_SIZE = 8, NUM_MATRICES = 2, NO_REG = 64 * NUM_MATRICES  ) 

(

input logic  clk, rst,

input logic [DATA_SIZE-1:0] input_data_split,


output logic full,

output logic [DATA_SIZE-1:0]    concatout [0:NO_REG-1]  // Array output //X then Y 




);

logic [DATA_SIZE-1:0] storage [0: NO_REG -1];

logic [$clog2(NO_REG) - 1 : 0] write_addr;

   
 int i;
 
 
 always_ff @(posedge clk) begin
 
   if (rst) begin
   
   //SET THE ADDRESS TO ZERO AND CLEAR STORAGE ON RST
   
   //MIGHT HAVE TO DO SOMETHING ABOUT THE RESET AT SOME POINT THOUGH
   
   write_addr <= '0;
   
   for (int i = 0; i < NO_REG; i++) begin
    storage[i] <= '0;
    
    end
   full <= 0;
   
   end
   // need to add a condition here to check if the last inputr value changed, only execute the following statement if so
   else if (write_addr < NO_REG ) begin
        storage[write_addr] <= input_data_split;
        write_addr <= write_addr + 1;
    end
    else begin
    //MAYBE RESET WRITE_ADDR HERE TOO NOT SURE
    
    full <= 1; //'full' value passed to XOR module as a load_en

    
    end
    
    end

always_comb begin

if (full == 1) begin

 concatout = storage;

end

else begin

for (int i = 0; i< NO_REG; i++) begin

concatout[i] = '0;
end
end
end
        


        
        
   
  
 
 
   
endmodule
