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

logic [$clog2(NO_REG) : 0] write_addr; //need to have some unused bits here so we can get to NO_REG  + 1

   
logic [DATA_SIZE-1:0] CURR_input_data_split, PREV_input_data_split;

logic [1:0] pause_counter;
logic in_pause;
 
 
 always_ff @(posedge clk) begin
 
   if (rst) begin
   
   //SET THE ADDRESS TO ZERO AND CLEAR STORAGE ON RST
   
   //MIGHT HAVE TO DO SOMETHING ABOUT THE RESET AT SOME POINT THOUGH
   
   write_addr <= '0;
   
   for (int i = 0; i < NO_REG; i++) begin
    storage[i] <= '0;
    
    end
   full <= 0;
   pause_counter <= 0;
   in_pause <= 0;
   
   CURR_input_data_split <= input_data_split;
   PREV_input_data_split <= '0; //might be a very particular edge case where input_data_split is zero so need to add some logic to account for this

   end
   // if(!in_pause)  begin // could add a pause mechanism or just tell the concatenator to reset every time it its full
   // need to add a condition here to check if the last inputr value changed, only execute the following statement if so
   else if (write_addr <= NO_REG -1  ) begin
   
    full <= 0;
    CURR_input_data_split <= input_data_split;

    
   
       if((CURR_input_data_split != PREV_input_data_split) || (CURR_input_data_split == '0) || write_addr == 0) begin
        storage[write_addr] <= input_data_split;
        write_addr <= write_addr + 1;
        end
        
        

       end
     else begin
      full <= 1;
      write_addr <= 0;
      PREV_input_data_split <= 0;
      
      
      
      
      end
    end
    
   // end
    
    //MAYBE RESET WRITE_ADDR HERE TOO NOT SURE
 
    
    

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
