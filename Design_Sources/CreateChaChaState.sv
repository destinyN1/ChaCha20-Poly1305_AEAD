`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 03:25:12 PM
// Design Name: 
// Module Name: CreateChaChaState
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


//take in key, constant, nonce and blockcounter and make the matrix
//can also add some functionality here to read the key,nonce, etc from file to as well using 'initial'
module ChaChaState(
   input logic clk, clrMatrix,
   //inputs that are needed to form the chacha matrix
   //8, 32-bit words     (256) bit
   input word_t [0:7] Key,
   //3, 32-bit words     (96) bit
   input word_t [2:0] Nonce,
   //1, 32-bit word    (32) bit
   input word_t Block,
   //4, 32-bit words     (128) bit
   input word_t [3:0] Constant,
   //output the matrix after initial block is formed
   output word_t chachatoQround [3:0][3:0]
);

   //fill first row with constants
   always_ff @(posedge clk) begin
       //maybe can default to just having output to zero
       if (clrMatrix)
           chachatoQround <= '{default:0};       
       else
           for (int i = 0; i < 4; i++)
               chachatoQround[0][i] <= Constant[i];
   

   //fill second and third row with key
           for (int j = 0; j < 8; j++)
            chachatoQround[1+j/4][j%4] <= Key[j];
  
  //fill last row with Nonce and block
           chachatoQround[3][0] <= Block;
          
           chachatoQround[3][1] <= Nonce[0];           
           chachatoQround[3][2] <= Nonce[1];
           chachatoQround[3][3] <= Nonce[2];
           
   end
      
      
      
endmodule
