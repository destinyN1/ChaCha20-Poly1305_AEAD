`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/13/2025 01:46:10 PM
// Design Name: 
// Module Name: Serialiser_TB
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


module Serialiser_TB;

//Inputs
logic clk,rst,load_enable;
word_t indata[3:0][3:0]; 


//Outputs
word_t outdata;
logic validS;


//instantiate UUT
Serialiser uut(.clk(clk), .rst(rst), .load_enable(load_enable), .indata(indata), .outdata(outdata), .validS(validS));


initial clk = 1;
always #5 clk = ~clk;

 // Fill the matrix with rand values
    task fill_matrix_random(); 
        for (int i = 0; i < 4; i++) begin
            for(int j = 0; j < 4; j++) begin
                indata[i][j] = $urandom();
            end
        end
    endtask
    
    //print input matrix
    task print_input_data();
        $display("Indata:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", indata[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
    task print_data_reg();
        $display("data_reg:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", uut.data_reg[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask


//UNIT TESTS
initial begin

//TEST DATA LOADING ON LOAD_ENABLE

rst=0;
@(posedge clk);
rst = 1;
@(posedge clk);
rst = 0;

@(posedge clk);

load_enable=1;

//fill the input matrix
fill_matrix_random();

//test to see if the input is set
print_input_data();
//print internal storage

@(posedge clk);
print_data_reg();

//print counter value
$display("counter is %0d:",uut.counter);





//COUNTER INCREMENT 

@(posedge clk);
load_enable = 0;


#800;

rst = 1;
#10;
rst = 0;
load_enable=1;
#10;
load_enable = 0;

#700;

//TO INPUT NEW STATE MATRIX NEED TO SET RST = 1/ RST =0 / LOAD_ENABLE = 1, LOAD_ENABLE = 0




$finish;
end

endmodule
