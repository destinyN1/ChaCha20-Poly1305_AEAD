`timescale 1ns / 1ps

module Block_Function_TB();

    // Assuming word_t is 32-bit (typical for ChaCha)
    typedef logic [31:0] word_t;
    
    // Clock and reset
    logic clk;
    logic rst;
    
    // Inputs to DUT
    word_t [0:7] Key;
    word_t [2:0] Nonce;
    word_t Block;
    word_t [3:0] Constant;
    
    // Outputs from DUT
    word_t MatrixOut [3:0][3:0];
    logic [31:0] blocksproduced;
    logic serial_enable;
    
    
    int test_count;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    
    // DUT instantiation
    Block_Function dut (
        .rst(rst),
        .clk(clk),
        .Key(Key),
        .Nonce(Nonce),
        .Block(Block),
        .Constant(Constant),
        .MatrixOut(MatrixOut),
        .blocksproduced(blocksproduced),
        .serial_enable(serial_enable)
    );
    
    task print_input_matrix();
        $display("Input Matrix:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", dut.chachatoQround[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
    task print_output_matrix();
        $display("Output Matrix:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", MatrixOut[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
    
    task run_pattern_test();
   integer pattern;
    begin
        for (pattern = 0; pattern < 16; pattern = pattern + 1) begin
        #20;
            $display("=== Testing Pattern 0x%1X ===", pattern);
            
            // FIXED: Don't overwrite constants - they should be fixed!
            Constant[0] = {8{pattern[3:0]}};  // "expa"
            Constant[1] = {8{pattern[3:0]}};  // "nd 3" 
            Constant[2] = {8{pattern[3:0]}};  // "2-by"
            Constant[3] = {8{pattern[3:0]}};  // "te k"
            
            // Apply pattern to Key only
            Key[0] = {8{pattern[3:0]}};
            Key[1] = {8{pattern[3:0]}};
            Key[2] = {8{pattern[3:0]}};
            Key[3] = {8{pattern[3:0]}};
            Key[4] = {8{pattern[3:0]}};
            Key[5] = {8{pattern[3:0]}};
            Key[6] = {8{pattern[3:0]}};
            Key[7] = {8{pattern[3:0]}};
            
            // Apply pattern to Block Counter and Nonce
            Block = {8{pattern[3:0]}};
            Nonce[0] = {8{pattern[3:0]}};
            Nonce[1] = {8{pattern[3:0]}};
            Nonce[2] = {8{pattern[3:0]}};
            
            #20;
            print_input_matrix();
            wait(dut.blockready == 1);
            print_output_matrix();
            
            test_count = test_count + 1;
            
        end
    end
endtask
    
    
    task run_random_test();
    begin
        // Generate random ChaCha20 constants (though typically these are fixed)
        // For testing purposes, we'll randomize them
        Constant[0] = $urandom();
        Constant[1] = $urandom();
        Constant[2] = $urandom();
        Constant[3] = $urandom();
        
        // Generate random 256-bit key
        Key[0] = $urandom();
        Key[1] = $urandom();
        Key[2] = $urandom();
        Key[3] = $urandom();
        Key[4] = $urandom();
        Key[5] = $urandom();
        Key[6] = $urandom();
        Key[7] = $urandom();
        
        // Generate random block counter
        Block = $urandom();
        
        // Generate random 96-bit nonce
        Nonce[0] = $urandom();
        Nonce[1] = $urandom();
        Nonce[2] = $urandom();
        
        #20;
        
        print_input_matrix();
        
        wait(dut.blockready == 1);
        print_output_matrix();
    end
endtask
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst = 1;
        Key = '{default: 0};
        Nonce = '{default: 0};
        Block = 0;
        Constant = '{default: 0};
        
        
        #10;
        rst = 0;
         //Test Case 1: Basic functionality with typical ChaCha values
//        $display("=== Test Case 1: Basic ChaCha Block Function with test vectors ===");
        
//        // Set up ChaCha20 constants (expand 32-byte k)
//        Constant[0] = 32'h61707865; // "expa"
//        Constant[1] = 32'h3320646e; // "nd 3"
//        Constant[2] = 32'h79622d32; // "2-by"
//        Constant[3] = 32'h6b206574; // "te k"
        
//        // Example key (256-bit)
//        Key[0] = 32'h03020100;
//        Key[1] = 32'h07060504;
//        Key[2] = 32'h0b0a0908;
//        Key[3] = 32'h0f0e0d0c;
//        Key[4] = 32'h13121110;
//        Key[5] = 32'h17161514;
//        Key[6] = 32'h1b1a1918;
//        Key[7] = 32'h1f1e1d1c;
        
//        // Counter (block number)
//        Block = 32'h00000001;
        
//        // Nonce (96-bit)
//        Nonce[0] = 32'h09000000;
//        Nonce[1] = 32'h4a000000;
//        Nonce[2] = 32'h00000000;
        
//        #20;
        
//        print_input_matrix();
        
//        wait(dut.blockready == 1);
//        print_output_matrix();
        
        
        
        
//        #10;
//        rst = 1;
//        #10;
//        rst = 0;
        
//        $display("=== Test Case 2:11000 random matrices ===");

        
//        test_count = 0;
        
//        while(test_count < 10) begin
        
//        $display("TEST NO.%0d", test_count);
         
//        run_random_test();
//        #20;
//        test_count = test_count + 1;
        
        
      // end
       
        $display("=== Test Case 3: Pattern Tests ===");
        test_count = 0;
        
        run_pattern_test();
       
        
  end      
  endmodule      