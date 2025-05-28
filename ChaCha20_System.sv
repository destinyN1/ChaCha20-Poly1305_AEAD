`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 05:05:09 PM
// Design Name: 
// Module Name: ChaCha20_System
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




module ChaCha20_System(

input logic clk, rst,
   //inputs that are needed to form the chacha matrix
   //8, 32-bit words     (256) bit
   input word_t [0:7] Key,
   //3, 32-bit words     (96) bit
   input word_t [2:0] Nonce,

   //4, 32-bit words     (128) bit
   input word_t [3:0] Constant

//note how there is no block on the input here as it is an internal sig in this module
    );
    
    //appropriate block counter signals, need to keep track of the block itself, how many blocks and if a block is ready to be outputed
    word_t Block;
    logic [4-1:0] blocksproduced;
    logic blockready;
    
    //Matrix that goes into serializer and then Xor module
    word_t MatrixOutBF [3:0][3:0];
    
    //Serialiser Signals
    word_t SerialOut;
    logic  validS;
    logic load_enable;
;
    
 Block_Function BF (.serial_enable(load_enable),.clk(clk), .rst(rst), .Key(Key), .Nonce(Nonce), .Constant(Constant), .Block(Block), .MatrixOut(MatrixOutBF), .blocksproduced(blocksproduced));   
 Block_Counter BC (.clk(clk), .init(rst) , .blocksproduced(blocksproduced), . Block(Block));
 Serialiser S (.clk(clk),.rst(rst), .indata(MatrixOutBF),.validS(validS),.outdata(SerialOut),.load_enable(load_enable));   
    
    
endmodule
