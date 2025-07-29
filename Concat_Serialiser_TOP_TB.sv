// Testbench for Concat_Serialiser_TOP module
`timescale 1ns / 1ps 

// Define word_t if not defined elsewhere
//typedef logic [31:0] word_t;

module Concat_Serialiser_TOP_TB(

input logic full
);

    // Parameters matching the DUT
    parameter DATA_SIZE = 8;
    parameter NUM_MATRICES = 1;
    parameter NO_REG = 64 * NUM_MATRICES;
    
    // Testbench signals
    logic clk;
    logic rst;
    logic load_en;
    word_t indata[3:0][3:0];
    logic [DATA_SIZE-1:0] concatout [0:NO_REG-1];
    
    // Test tracking variables
    int test_count = 0;
    int matrix_count = 0;
    
    // Instantiate the DUT (Device Under Test)
    Concat_Serialiser_TOP #(
        .DATA_SIZE(DATA_SIZE),
        .NUM_MATRICES(NUM_MATRICES),
        .NO_REG(NO_REG)
    ) dut (
        .clk(clk),
        .rst(rst),
        .load_en(load_en),
        .indata(indata),
        .concatout(concatout),
        .full(full)
    );
    
    
    task fill_matrix_random(); 
        for (int i = 0; i < 4; i++) begin
            for(int j = 0; j < 4; j++) begin
                indata[i][j] = $urandom();
            end
        end
    endtask
    
    // Clock generation (10ns period = 100MHz)
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
    
    //testing simple reset functionality
    rst = 0;
    
    #10;
    
    rst = 1;
    
    #10;
    rst = 0;
    
    #20;
    
    load_en = 1;
    fill_matrix_random();
    
   #10;
   load_en = 0; //setting to zero to start serialiser function.
    
    
    
    #1000;
    
    wait (dut.full == 1);
    
    
    rst = 1;
    
    #100;
    
    
    
    
    
    
    $finish;
    end
    endmodule