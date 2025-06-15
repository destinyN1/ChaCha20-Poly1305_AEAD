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

//will output serial data in 32 bit chunks as of now

typedef logic [31:0] word_t; 

// loosely based off of  the SerDes Architecture
module Serialiser(
    input logic clk, rst,
    input word_t indata [3:0][3:0],
    input logic load_enable,    // Signal to load new data
    output word_t outdata,
    output logic validS,         // Indicates valid output
    output logic concat_en, //signal that will tell concatenator to come out of pause and start operating 
    output logic [7:0] outdata_split
);
    
    word_t data_reg [3:0][3:0];
    logic [3:0] counter;
    logic [1:0] row, col;
    logic [1:0] byte_index;
    logic split; //signal that will indicate to the counter to stop or start counting
    
    // Counter and address generation
    always_ff @(posedge clk) begin
        if(rst) begin
            counter <= 4'b0;
            data_reg <= '{default:0};
            validS <= 0;
            split <= 0;
        end                                    //LOAD_ENABLE AND RST NEED TO BE LOW FOR COUNTER TO START INCREMENTING
        else if(load_enable) begin
            data_reg <= indata;
            counter <= 4'b0;
            byte_index <=0;
        end
        else if(counter < 4'd15) begin
        
            if(byte_index == 3) begin
        
            counter <= counter + 1'b1;
            split <=1;
            
            byte_index <= 0;
            end
            else begin
            byte_index <= byte_index + 1;
            split <= 0;
            end
        end
    end
    
    always_ff @(posedge clk) begin
    
    if (counter == 4'd15) begin
        validS <= 1;
        
     end
    end
    
    
    // Little-endian address decoding (start from bottom-right, go backwards)
    assign row = 3 - counter[3:2];    // Invert row: 3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0
    assign col = 3 - counter[1:0];    // Invert col: 3,2,1,0,3,2,1,0,3,2,1,0,3,2,1,0
    
    // Output logic
    assign outdata = data_reg[row][col];
    
  //block that will split the Outdata into 1 Byte chunks  
    always_comb begin
    
    case(byte_index)
    
    0:begin
    outdata_split = outdata[31:24];
    concat_en = 1;

    end

    1:begin
    outdata_split = outdata[23:16];
    concat_en = 1;

    end
 
    2:begin
    outdata_split = outdata[15:8];
    concat_en = 1;

    end
    
    3:begin
    outdata_split = outdata[7:0];
    concat_en = 1;

    end
    
    endcase    
        
    end
    
endmodule
    
   
 
 
    
