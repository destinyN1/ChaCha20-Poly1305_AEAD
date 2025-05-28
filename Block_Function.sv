`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 03:27:26 PM
// Design Name: 
// Module Name: Block_Function
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


module Block_Function(

input logic rst, clk,


   //inputs that are needed to form the chacha matrix
   //8, 32-bit words     (256) bit
   input word_t [0:7] Key,
   //3, 32-bit words     (96) bit
   input word_t [2:0] Nonce,
   //1, 32-bit word    (32) bit
   input word_t Block,
   //4, 32-bit words     (128) bit
   input word_t [3:0] Constant,
   
   
   //leaves block function and gets seiralized (serializer module)
   output word_t MatrixOut [3:0][3:0],
   
   //goes to block counter
   output logic [4-1:0] blocksproduced,
   
   output  logic serial_enable
   


);

typedef enum {INIT, MLOW,SETLOW, FINISHED} States;
States CS,NS;

 word_t chachatoQround [3:0][3:0];
 
 logic clrMatrix, Setrounds;
 
 logic blockready;
 
 
 
 //Reset both modules in the block function using single reset pin
 always_ff @(posedge clk) begin 


//add a note here: this could posssibly introduce some timing issues here so I will write this here for now.
  if (rst) begin
  blocksproduced <= 0;
  CS <= INIT;
  end
  
  else begin
   CS <= NS;
  if(serial_enable) begin
    blocksproduced <= blocksproduced + 1;
   
 end
 end
 end
 


//State logic for stepping through the block funtions actions
always_comb begin

//default assignment to avoid latching
NS = CS;

case (CS) 
 INIT: begin
    
    clrMatrix = 1;
    Setrounds = 1;
    NS = MLOW;
end
 
 MLOW: begin
 clrMatrix = 0;
 NS = SETLOW;

end

 SETLOW: begin
 
 Setrounds = 0;
 
  if (blockready == 1) begin
    serial_enable = 1;
    NS = INIT;
  end
  
  else begin
    serial_enable = 0;
    NS = SETLOW;
    
 
 end
end
endcase



end

PerformQround Qround(.chachamatrixIN(chachatoQround), .clk(clk), .setRounds(Setrounds), .chachamatrixOUT(MatrixOut), .blocksproduced(blocksproduced), .blockready(blockready) );
ChaChaState state(.clk(clk), .clrMatrix(clrMatrix) ,.Block(Block), .Key(Key) ,.Nonce(Nonce),.Constant(Constant), .chachatoQround(chachatoQround));
endmodule

