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




module ChaCha20_System  #(parameter DATA_SIZE = 8, NUM_MATRICES = 1, NO_REG = 64 * NUM_MATRICES  )(

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
    logic [31:0] blocksproduced;
    logic blockready;
    
    //Matrix that goes into serializer and then Xor module
    word_t MatrixOutBF [3:0][3:0];
    
    //Serialiser Signals
    word_t SerialOut;
    logic  validS;
    logic load_enable;
    
    
    
    // XOR SIGNALS
    logic XOR_READY;
    logic [DATA_SIZE-1:0] char_in [0:NO_REG -1];
    logic [DATA_SIZE-1:0]  Ciphertext [0:NO_REG-1];

    
    
    //Concatenator and Serialiser signals
    
    //C signals
    logic [DATA_SIZE-1:0] input_data_split;
    logic [DATA_SIZE-1:0]    concatout [0:NO_REG-1];
    logic full;
    
    
    
    
    //Plain Text signals
    logic write_en, read_en;
    logic [DATA_SIZE-1:0] char_out [0:NO_REG -1];
    logic [7:0] char_in_PT;
;
    
// Block_Function Block_Function (.serial_enable(load_enable),.clk(clk), .rst(rst), .Key(Key), .Nonce(Nonce), .Constant(Constant), .MatrixOut(MatrixOutBF));   
// Block_Counter Block_Counter (.clk(clk), .init(rst) , .blocksproduced(blocksproduced), . Block(Block));
// Serialiser Serialiser (.clk(clk),.rst(rst), .indata(MatrixOutBF),.validS(validS),.outdata(SerialOut),.load_enable(load_enable)); 
// XOR_module Xor_Module (.clk(clk), .XOR_READY(XOR_READY),.char_in(char_out),.Ciphertext(Ciphertext),.concatout(concatout));  
// Concatenator Concatenator (.clk(clk), .rst(rst),.input_data_split(SerialOut),.concatout(concatout) );
 //Plain_Text Plain_Text (.rst(rst),.clk(clk), .XOR_READY(XOR_READY),.char_out(char_out),.char_in_PT(char_in_PT));


 Block_Function Block_Function (.blockready(blockready),.clk(clk), .rst(rst), .Key(Key), .Nonce(Nonce), .Constant(Constant), .MatrixOut(MatrixOutBF));   
    
 Concat_Serialiser_TOP ConcatSer (.clk(clk),.rst(rst),.indata(MatrixOutBF),.load_en(blockready),.concatout(concatout),.full(full));
     
endmodule
