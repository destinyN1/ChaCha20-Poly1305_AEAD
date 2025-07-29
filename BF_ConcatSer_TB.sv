module BF_ConcatSer_TB;

    // Parameters
    parameter DATA_SIZE = 8;
    parameter NUM_MATRICES = 1;
    parameter NO_REG = 64 * NUM_MATRICES;

    // Inputs
    logic clk;
    logic rst;
    word_t [0:7] Key;
    word_t [2:0] Nonce;
    word_t [3:0] Constant;


    // Outputs
    logic [DATA_SIZE-1:0] concatout [0:NO_REG-1];
    logic full;
    logic blockready;


initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    // DUT instantiation
    BF_ConcatSer #(
        .DATA_SIZE(DATA_SIZE),
        .NUM_MATRICES(NUM_MATRICES),
        .NO_REG(NO_REG)
    ) dut (
        .clk(clk),
        .rst(rst),
        .Key(Key),
        .Nonce(Nonce),
        .Constant(Constant),
        .concatout(concatout),
        .full(full),
        .blockready(blockready)
    );
    
    
    
    task print_final_matrix();
        $display("Input Matrix:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", dut.MatrixOutBF[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
    task print_input_qround_matrix();
        $display("Input Matrix:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", dut.Block_Function.Qround.chachamatrixIN[i][j]);
            end
            $write("\n");
        end 
        $display(""); // Add blank line
    endtask
    
    
     initial begin
        // Initialize signals
        rst = 1;
        Key = '{default: 0};
        Nonce = '{default: 0};
      //  Block = 0;
        Constant = '{default: 0};
        
        
        #10;
        rst = 0;
      //   Test Case 1: Basic functionality with typical ChaCha values
       $display("=== Test Case 1: Basic ChaCha Block Function with test vectors ===");
        
       // Set up ChaCha20 constants (expand 32-byte k)
       Constant[0] = 32'h61707865; // "expa"
       Constant[1] = 32'h3320646e; // "nd 3"
       Constant[2] = 32'h79622d32; // "2-by"
       Constant[3] = 32'h6b206574; // "te k"
        
       // Example key (256-bit)
       Key[0] = 32'h03020100;
       Key[1] = 32'h07060504;
       Key[2] = 32'h0b0a0908;
       Key[3] = 32'h0f0e0d0c;
       Key[4] = 32'h13121110;
       Key[5] = 32'h17161514;
       Key[6] = 32'h1b1a1918;
       Key[7] = 32'h1f1e1d1c;
        
       // Counter (block number)
       //Block = 32'h00000001;
        
       // Nonce (96-bit)
       Nonce[0] = 32'h09000000;
       Nonce[1] = 32'h4a000000;
       Nonce[2] = 32'h00000000;
        
      #20;
        
        print_input_qround_matrix();
        
        wait(dut.blockready == 1);
        print_final_matrix();
    
    
$finish;

end
endmodule