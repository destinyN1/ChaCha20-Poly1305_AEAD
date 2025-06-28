`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2025 01:21:42 PM
// Design Name: 
// Module Name: chachamatrix_TB
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

module chachamatrix_TB;
    logic clk, clrMatrix;
    
    //inputs that are needed to form the chacha matrix
    //8, 32-bit words     (256) bit
    word_t [0:7] Key;
    //3, 32-bit words     (96) bit
    word_t [2:0] Nonce;
    //1, 32-bit word    (32) bit
    word_t Block;
    //4, 32-bit words     (128) bit
    word_t [3:0] Constant;
    //output the matrix after initial block is formed
    word_t chachatoQround [3:0][3:0];
    
    // Fixed module instantiation with correct port names
    ChaChaState uut (
        .clk(clk), 
        .clrMatrix(clrMatrix), 
        .Key(Key), 
        .Nonce(Nonce), 
        .Block(Block), 
        .Constant(Constant), 
        .chachatoQround(chachatoQround)
    );
    
    // Clock generation
    initial clk = 1;
    always #5 clk = ~clk;
    
    initial begin
        ///////UNIT TESTS//////////
        //Initialize the system
        clrMatrix = 1;
        #20;
        clrMatrix = 0;
        
        //State Formation Test
        // Generate random inputs
        foreach (Key[i])      Key[i]      = $urandom;
        foreach (Nonce[i])    Nonce[i]    = $urandom;
        Block = $urandom;
        foreach (Constant[i]) Constant[i] = $urandom;
        
        // Wait for matrix to update
        @(posedge clk);
        @(posedge clk);
        
        // Display matrix output
        $display("ChaCha matrix after input:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for (int j = 0; j < 4; j++)
                $write("%h ", chachatoQround[i][j]);
            $write("\n");
        end
        
        $display("\nInput values used:");
        $display("Constants: %h %h %h %h", Constant[0], Constant[1], Constant[2], Constant[3]);
        $display("Key: %h %h %h %h %h %h %h %h", Key[0], Key[1], Key[2], Key[3], Key[4], Key[5], Key[6], Key[7]);
        $display("Block: %h", Block);
        $display("Nonce: %h %h %h", Nonce[0], Nonce[1], Nonce[2]);
        
        ///////DYNAMIC INPUT CHANGE TESTS//////////
        $display("\n=== DYNAMIC INPUT CHANGE TESTS ===");
        
        // Test 1: Change only the block counter
        $display("\nTest 1: Changing Block Counter");
        Block = 32'h12345678;
        @(posedge clk);
        $display("New Block: %h", Block);
        $display("Matrix Row 3: %h %h %h %h", chachatoQround[3][0], chachatoQround[3][1], chachatoQround[3][2], chachatoQround[3][3]);
        
        // Test 2: Change only the nonce
        $display("\nTest 2: Changing Nonce");
        Nonce[0] = 32'hAABBCCDD;
        Nonce[1] = 32'hEEFF0011;
        Nonce[2] = 32'h22334455;
        @(posedge clk);
        $display("New Nonce: %h %h %h", Nonce[0], Nonce[1], Nonce[2]);
        $display("Matrix Row 3: %h %h %h %h", chachatoQround[3][0], chachatoQround[3][1], chachatoQround[3][2], chachatoQround[3][3]);
        
        // Test 3: Change part of the key
        $display("\nTest 3: Changing Key Values");
        Key[0] = 32'hDEADBEEF;
        Key[4] = 32'hCAFEBABE;
        @(posedge clk);
        $display("Changed Key[0]: %h, Key[4]: %h", Key[0], Key[4]);
        $display("Matrix Row 1: %h %h %h %h", chachatoQround[1][0], chachatoQround[1][1], chachatoQround[1][2], chachatoQround[1][3]);
        $display("Matrix Row 2: %h %h %h %h", chachatoQround[2][0], chachatoQround[2][1], chachatoQround[2][2], chachatoQround[2][3]);
        
        // Test 4: Change constants
        $display("\nTest 4: Changing Constants");
        Constant[0] = 32'h61707865;  // "expa" in ASCII (ChaCha20 constant)
        Constant[1] = 32'h3320646E;  // "nd 3" in ASCII
        Constant[2] = 32'h79622D32;  // "2-by" in ASCII  
        Constant[3] = 32'h6B206574;  // "te k" in ASCII
        @(posedge clk);
        $display("New Constants: %h %h %h %h", Constant[0], Constant[1], Constant[2], Constant[3]);
        $display("Matrix Row 0: %h %h %h %h", chachatoQround[0][0], chachatoQround[0][1], chachatoQround[0][2], chachatoQround[0][3]);
        
        // Test 5: Multiple simultaneous changes
        $display("\nTest 5: Multiple Simultaneous Changes");
        Block = Block + 1;  // Increment block counter
        Nonce[0] = Nonce[0] ^ 32'hFFFFFFFF;  // XOR nonce
        Key[7] = $urandom;  // Random key change
        @(posedge clk);
        $display("Multiple changes applied");
        $display("Full matrix after changes:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for (int j = 0; j < 4; j++)
                $write("%h ", chachatoQround[i][j]);
            $write("\n");
        end
        
        // Test 6: Rapid input changes
        $display("\nTest 6: Rapid Input Changes (5 cycles)");
        for (int cycle = 0; cycle < 5; cycle++) begin
            Block = Block + 1;
            @(posedge clk);
            $display("Cycle %0d - Block: %h, Matrix[3][0]: %h", cycle, Block, chachatoQround[3][0]);
        end
        
        // Test 7: Clear during operation
        $display("\nTest 7: Clear During Operation");
        $display("Before clear - Matrix[0][0]: %h", chachatoQround[0][0]);
        clrMatrix = 1;
        @(posedge clk);
        $display("After clear - Matrix[0][0]: %h", chachatoQround[0][0]);
        clrMatrix = 0;
        
        // Restore some values after clear
        foreach (Constant[i]) Constant[i] = $urandom;
        @(posedge clk);
        $display("After restore - Matrix[0][0]: %h", chachatoQround[0][0]);
        
        $display("\n=== ALL TESTS COMPLETED ===");
        $finish;
    end
endmodule