`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2025 03:29:06 PM
// Design Name: 
// Module Name: Block_Counter_TB
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


module Block_Counter_TB;

//inputs
logic clk, init;

//outputs
logic [31:0] blocksproduced;
word_t Block;

   
    
 //Instantiate Block Counter   
 Block_Counter uut (.clk(clk), .init(init), .blocksproduced(blocksproduced), .Block(Block));
    
 //clock gen   
 initial clk = 1;
 always #5 clk = ~clk;
 
 
 
 //UNIT TESTS
 //////////////
 initial begin
 
 
 // 1. Basic Counter Behaviour and Reset Functionality
 
 //Initialise
init = 1;
blocksproduced = 0;

//should expect block to be zero

assert property(@(posedge clk) Block == '0);
 #50
 
 //let the counter start counting
 init = 0;
 
 #20
 blocksproduced = 1;

#20 
blocksproduced = 2;

#20

blocksproduced = 3;
 
#50
 
 //2. Overflow Behaviour 
 blocksproduced = 32'hFFFFFFFD;
 #20
  blocksproduced = 32'hFFFFFFFE;
#20

 blocksproduced = 32'hFFFFFFFF;
 
#50
 

 //3. Clock Edge Sensitivity
 
 init = 1; 
 blocksproduced = 0;
 
 #50
 
 
 
 
 
 
  $finish;
  end  
endmodule
