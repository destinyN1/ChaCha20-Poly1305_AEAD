`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 05:05:09 PM
// Design Name: 
// Module Name: ChaCha20_Core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Core module instantiating Block_Function and Concat_Serialiser_TOP
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


typedef logic [31:0] word_t;


module BF_ConcatSer
#(parameter DATA_SIZE = 8, 
  NUM_MATRICES = 1, 
  NO_REG = 64 * NUM_MATRICES
)(
    input logic clk, 
    input logic rst,
    
    // ChaCha20 inputs
    input word_t [0:7] Key,        // 8, 32-bit words (256 bit)
    input word_t [2:0] Nonce,      // 3, 32-bit words (96 bit) 
    input word_t [3:0] Constant,   // 4, 32-bit words (128 bit)
    
    // Outputs
    output logic [DATA_SIZE-1:0] concatout [0:NO_REG-1],
    output logic full,
    output logic blockready
);

    // Internal signals
    word_t MatrixOutBF [3:0][3:0];

    // Block_Function instantiation
    Block_Function Block_Function (
        .blockready(blockready),
        .clk(clk), 
        .rst(rst), 
        .Key(Key), 
        .Nonce(Nonce), 
        .Constant(Constant), 
        .MatrixOutBF(MatrixOutBF)
    );

    // Concat_Serialiser_TOP instantiation  
    Concat_Serialiser_TOP ConcatSer (
        .clk(clk),
        .rst(rst),
        .indata(MatrixOutBF),
        .load_en(blockready),
        .concatout(concatout),
        .full(full)
    );

endmodule