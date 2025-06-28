`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025 11:18:43 AM
// Design Name: 
// Module Name: Serialiser
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

//will output serial data in 32 bit chunks as of now


// loosely based off of  the SerDes Architecture
module Serialiser(
    input logic clk, rst,
    input word_t indata [3:0][3:0],
    input logic load_enable,    // Signal to load new data
    input logic full, //signal comes from concat to serialiser to tell it when and when it should not increment
    output word_t outdata,
    output logic validS,         // Indicates valid output
    output logic concat_en, //signal that will tell concatenator to come out of pause and start operating 
    output logic [7:0] outdata_split
);
    
    word_t data_reg [3:0][3:0];
    logic [4:0] counter;

    logic [1:0] row, col;
    logic [1:0] byte_index;
    logic lastloop;
       
    // Counter and address generation
    always_ff @(posedge clk) begin
        if(rst) begin
            counter <= 4'b0;
            data_reg <= '{default:0};
            validS <= 0;
            lastloop <= 0;
            concat_en <= 0;
            
            end                                    // RST NEED TO BE LOW FOR COUNTER TO START INCREMENTING
        else if(load_enable) begin
            data_reg <= indata;
            byte_index <= 0;
            concat_en <= 1;
           
        end
        else if((counter < 5'd15)&& full == 0) begin
               
          concat_en<=0;   
            if(byte_index == 3) begin
        
            counter <= counter + 1'b1;
            
            byte_index <= 0;
            end
            else if((!concat_en)&& full == 0) begin
            byte_index <= byte_index + 1;
            
            end
        end
    end
    

    
   always_comb begin
    if (counter < 5'd15) begin
    // Little-endian address decoding (start from bottom-right, go backwards)
     row = 3 - counter[3:2];    // Invert row: 3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0
     col = 3 - counter[1:0]; 
     outdata = data_reg[row][col];// Invert col: 3,2,1,0,3,2,1,0,3,2,1,0,3,2,1,0
    
    end
    
    else begin
    
    outdata = data_reg[0][0];
    
   
    end
    end
    
    always_ff @(posedge clk) begin
        if (counter >= 5'd15) begin 
        
            byte_index <= byte_index + 1; 
            
               
   end 
   end
   
   //stop inmcrementing the counter once we get to the last byte of the last word
   always_latch begin 
   
   if ((byte_index == 3) && (counter >= 5'd15)) begin
    
    byte_index = 0;
   end
       end
    
   always_latch begin
    if(concat_en)begin
    byte_index = 0;
    end
    end
    
    
  //block that will split the Outdata into 1 Byte chunks  
    always_latch begin
    
    if(!concat_en) begin
    
    case(byte_index)
    
    0:begin
    outdata_split = outdata[31:24];

    end

    1:begin
    outdata_split = outdata[23:16];

    end
 
    2:begin
    outdata_split = outdata[15:8];

    end
    
    3:begin
    outdata_split = outdata[7:0];

    end
    
    endcase     
        
    end
    end
    
endmodule
    
   
 
 
    
