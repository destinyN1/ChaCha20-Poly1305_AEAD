//typedef logic [31:0] word_t;

module Q0_Q7_Test_TB;
    // Test signals
    logic clk, setRounds;
    word_t chachamatrixIN [3:0][3:0];
    word_t chachamatrixOUT [3:0][3:0];
    logic blockready;
    logic [3:0] blocksproduced;
    
    // Test variables
    word_t expected_matrix [3:0][3:0];
    int cycle_count;
    
    // Instantiate the module under test
    PerformQround uut (
        .chachamatrixIN(chachamatrixIN),
        .clk(clk),
        .setRounds(setRounds),
        .chachamatrixOUT(chachamatrixOUT),
        .blockready(blockready),
        .blocksproduced(blocksproduced)
    );
    
    
    
    //Reference Values for step by step verification
    
        word_t ref_a, ref_b, ref_c, ref_d;
        word_t expected_a, expected_b, expected_c, expected_d;
        logic [2:0] current_step;


//Reference function will perform S0-S6 (S7 is state shift) for a given Q
     task calculate_step( 
      input [2:0] step,
     input word_t a_in,b_in,c_in,d_in,
     output word_t a_out, b_out, c_out, d_out
    
    );
    
    
     case (step)
     
     
     
        3'd0: begin // S0
        $display("===================S0 TEST================\n");
        
        $display("Variables (BEFORE) temp_a = %08h, d_in = %08h", a_in, d_in); 
       $display("Variables (BEFORE) uut_a = %08h, uut_d = %08h", uut.a, uut.d); 
       $display("\n");
        
        a_in = a_in + b_in;
        d_in = d_in ^ a_in;
        
        // Check 'a'
        if (uut.a !== a_in) begin
            $display("ERROR S%0d: a mismatch! Expected uut.a =%08h, Got uut.a = %08h", 
                     step, a_in, uut.a);
        end
        else begin
            $display("PASS S%0d: a pass! Expected uut.a =%08h, Got uut.a = %08h", 
                     step, a_in, uut.a);
        end        
                 
        // Check 'd' 
        if (uut.d !== d_in) begin
            $display("ERROR S%0d: d mismatch! Expected uut.d =%08h, Got uut.d = %08h", 
                     step, d_in, uut.d);
        end
        else begin
            $display("PASS S%0d: d pass! Expected uut.d =%08h, Got uut.d = %08h", 
                     step, d_in, uut.d);
        end
        
        //check to see if both passed
        if( (uut.a == a_in) && (uut.d == d_in) ) begin
            $display("PASSED S%0d!!!", step);
        end
        else begin
            $display("FAILED S%0d!!!", step);
        end
          $display("\n");
          $display("=====================================\n");

    end
    
    
    
        
        
        3'd1: begin // S1  
                $display("===================S1 TEST================\n");

        
      $display("Variables (BEFORE) c_in = %08h, d_in = %08h", c_in, d_in); 
       $display("Variables (BEFORE) uut_c = %08h, uut_d = %08h", uut.c, uut.d); 
       $display("\n");

       

        
        
            c_in = c_in + d_in;
            d_in = {d_in[15:0], d_in[31:16]}; // ROL 16
            
            if (uut.c !== c_in) begin
            $display("ERROR S%0d: a mismatch! Expected uut.c =%08h, Got uut.c = %08h", 
                     step, c_in, uut.c);
        end
        else begin
            $display("PASS S%0d: a pass! Expected uut.c =%08h, Got uut.c = %08h", 
                     step, c_in, uut.c);
        end        
                 
        // Check 'd' 
        if (uut.d !== d_in) begin
            $display("ERROR S%0d: d mismatch! Expected uut.d =%08h, Got uut.d = %08h", 
                     step, d_in, uut.d);
        end
        else begin
            $display("PASS S%0d: d pass! Expected uut.d =%08h, Got uut.d = %08h", 
                     step, d_in, uut.d);
        end
        
        //check to see if both passed
        if( (uut.c == c_in) && (uut.d == d_in) ) begin
            $display("PASSED S%0d!!!", step);
        end
        else begin
            $display("FAILED S%0d!!!", step);
        
          $display("\n");
          $display("=====================================\n");
        end
        end
        
        
        3'd2: begin // S2
            
                 $display("===================S2 TEST================\n");

        
      $display("Variables (BEFORE) b_in = %08h, d_in = %08h", b_in, d_in); 
       $display("Variables (BEFORE) uut_b = %08h, uut_d = %08h", uut.b, uut.d); 
       $display("\n");
        
        
            b_in = b_in ^ c_in;
            d_in = d_in ^ a_in;
            
            if (uut.b !== b_in) begin
            $display("ERROR S%0d: a mismatch! Expected uut.b =%08h, Got uut.b = %08h", 
                     step, b_in, uut.b);
        end
        else begin
            $display("PASS S%0d: a pass! Expected uut.b =%08h, Got uut.b = %08h", 
                     step, b_in, uut.b);
        end        
                 
        // Check 'd' 
        if (uut.d !== d_in) begin
            $display("ERROR S%0d: d mismatch! Expected uut.d =%08h, Got uut.d = %08h", 
                     step, d_in, uut.d);
        end
        else begin
            $display("PASS S%0d: d pass! Expected uut.d =%08h, Got uut.d = %08h", 
                     step, d_in, uut.d);
        end
        
        //check to see if both passed
        if( (uut.b == b_in) && (uut.d == d_in) ) begin
            $display("PASSED S%0d!!!", step);
        end
        else begin
            $display("FAILED S%0d!!!", step);
        
          $display("\n");
          $display("=====================================\n");
        end
        end
        
        
        3'd3: begin // S3
            b_in = {b_in[19:0], b_in[31:20]}; // ROL 12
            d_in = {d_in[15:0], d_in[31:16]}; // ROL 16
        end
        
        3'd4: begin // S4
            a_in = a_in + b_in;
            d_in = {d_in[23:0], d_in[31:24]}; // ROL 8
        end
        
        3'd5: begin // S5
            c_in = c_in + d_in;
            d_in = {d_in[24:0], d_in[31:25]}; // ROL 7
        end
        
        3'd6: begin // S6
            b_in = b_in ^ c_in;
        end
        
        3'd7: begin // S7 - end of quarter round
            // No operations on a,b,c,d in S7
        end
    endcase
    
    a_out = a_in; b_out = b_in; c_out = c_in; d_out = d_in;
endtask

//TASK TO TEST S0-S6 FOR EACH Q0
    task test_arx_ops();

        word_t test_a, test_b, test_c, test_d;
  
        word_t step_a, step_b, step_c, step_d;
        logic error_found;

        $display("=== Testing ARX Operations Step by Step ===");
    
    // Initialize with known values for easier verification
        test_a = 32'h01234567;
         test_b = 32'h89abcdef; 
         test_c = 32'hfedcba98;
      test_d = 32'h76543210;
     $display("Initial values:");
    $display("  a=%08h, b=%08h, c=%08h, d=%08h", test_a, test_b, test_c, test_d);
       
    //SETUP MODULE TO PERFORM S0-S6 IN Q0   (FIRST COLUMN)    
    setRounds = 1;
    chachamatrixIN[0][0] = test_a;
    chachamatrixIN[1][0] = test_b; 
    chachamatrixIN[2][0] = test_c;
    chachamatrixIN[3][0] = test_d;    
    
    
     // Fill rest with don't cares
    for (int i = 0; i < 4; i++) begin
        for (int j = 1; j < 4; j++) begin
            chachamatrixIN[i][j] = 32'h00000000;
        end
    end
    
   $display("Matrix with filled in Values an X's:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", chachamatrixIN[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line 
    
    
    
    #20
    setRounds = 0;
    #10;
    
    //SETTING INPUT VALUES FOR CALCULATE_STEP()
    step_a = test_a; step_b = test_b; step_c = test_c; step_d = test_d;
   
   expected_a = test_a;    expected_b = test_d;    expected_c = test_c;    expected_d = test_d; 



  
  
  
  //STEP THROUGH S0-S6
    for (int step = 0; step < 7; step++) begin
       // Calculate expected values
       calculate_step(step, step_a, step_b, step_c, step_d, 
        expected_a, expected_b, expected_c, expected_d);
        
     @(posedge clk);
     @(posedge clk);
     
     
     
      
   step_a = expected_a;  // Next step uses these results as input
   step_b = expected_b;
   step_c = expected_c;
   step_d = expected_d;
   
   
   
   
end
         
                      
                      
//    //WAIT FOR OPS TO COMPLETE
//    @(posedge clk);
//    @(posedge clk);
    
    
    //COMPARE UUT VALUES AGAINST EXPECTED ONES
    
//    if (uut.a !== expected_a) begin
//            $display("ERROR S%0d: a mismatch! Expected=%08h, Got=%08h", 
//                     step, expected_a, uut.a);
//            error_found = 1;
//        end
        
//        if (uut.b !== expected_b) begin
//            $display("ERROR S%0d: b mismatch! Expected=%08h, Got=%08h", 
//                     step, expected_b, uut.b);
//            error_found = 1;
//        end
        
//        if (uut.c !== expected_c) begin
//            $display("ERROR S%0d: c mismatch! Expected=%08h, Got=%08h", 
//                     step, expected_c, uut.c);
//            error_found = 1;
//        end
        
//        if (uut.d !== expected_d) begin
//            $display("ERROR S%0d: d mismatch! Expected=%08h, Got=%08h", 
//                     step, expected_d, uut.d);
//            error_found = 1;
//        end
        
//        //CHECKING TO SEE IF ALL uut values are correct
//        $display("S%0d: a=%08h, b=%08h, c=%08h, d=%08h %s", step,
//                 uut.a, uut.b, uut.c, uut.d, 
//                 (uut.a === expected_a && uut.b === expected_b && 
//                  uut.c === expected_c && uut.d === expected_d) ? "✓" : "✗");
//                  end
endtask

    task print_input_matrix();
        $display("Input Matrix:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", chachamatrixIN[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
     task fill_matrix_random(); 
        for (int i = 0; i < 4; i++) begin
            for(int j = 0; j < 4; j++) begin
                chachamatrixIN[i][j] = $urandom();
            end
        end
    endtask
    
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
       
   
   
  
   
  initial begin
//        $display("=== ChaCha20 PerformQround Test ===");
        
        // Test 1: Random values
//        $display("Test 1: Random input values");
        //setRounds = 1;
//        fill_matrix_random();
//        print_input_matrix();
        //#20;
        
        setRounds = 0;
        
        
        
        $display("Test 2: Move through states S0-S7, Performing ARX ops");
        #20
        test_arx_ops();
        
        #20;
        
            
            
        
  $finish;
 end
  
  
  
  
  
    
    
    
    
    endmodule
    
    
    
//    // Helper task for quarter-round calculation
//    task automatic quarter_round(
//        input word_t a_in, b_in, c_in, d_in,
//        output word_t a_out, b_out, c_out, d_out
//    );
//        word_t a, b, c, d;
//        a = a_in; b = b_in; c = c_in; d = d_in;
        
//        // ChaCha20 quarter-round: 4 steps
//        a = a + b; d = d ^ a; d = {d[15:0], d[31:16]};  // Step 1
//        c = c + d; b = b ^ c; b = {b[19:0], b[31:20]};  // Step 2  
//        a = a + b; d = d ^ a; d = {d[23:0], d[31:24]};  // Step 3
//        c = c + d; b = b ^ c; b = {b[24:0], b[31:25]};  // Step 4
        
//        a_out = a; b_out = b; c_out = c; d_out = d;
//    endtask
    
//    // Calculate expected result for one complete round (Q0-Q7)
//    task automatic calculate_one_round(
//        input word_t input_matrix [3:0][3:0],
//        output word_t output_matrix [3:0][3:0]
//    );
//        word_t work_matrix [3:0][3:0];
        
//        // Copy input to working matrix
//        for (int i = 0; i < 4; i++)
//            for (int j = 0; j < 4; j++)
//                work_matrix[i][j] = input_matrix[i][j];
        
//        // Q0-Q3: Column quarter-rounds
//        for (int col = 0; col < 4; col++) begin
//            quarter_round(
//                work_matrix[0][col], work_matrix[1][col], 
//                work_matrix[2][col], work_matrix[3][col],
//                work_matrix[0][col], work_matrix[1][col], 
//                work_matrix[2][col], work_matrix[3][col]
//            );
//        end
        
//        // Q4-Q7: Diagonal quarter-rounds
//        // Q4: (0,0), (1,1), (2,2), (3,3)
//        quarter_round(
//            work_matrix[0][0], work_matrix[1][1], 
//            work_matrix[2][2], work_matrix[3][3],
//            work_matrix[0][0], work_matrix[1][1], 
//            work_matrix[2][2], work_matrix[3][3]
//        );
        
//        // Q5: (0,1), (1,2), (2,3), (3,0)
//        quarter_round(
//            work_matrix[0][1], work_matrix[1][2], 
//            work_matrix[2][3], work_matrix[3][0],
//            work_matrix[0][1], work_matrix[1][2], 
//            work_matrix[2][3], work_matrix[3][0]
//        );
        
//        // Q6: (0,2), (1,3), (2,0), (3,1)
//        quarter_round(
//            work_matrix[0][2], work_matrix[1][3], 
//            work_matrix[2][0], work_matrix[3][1],
//            work_matrix[0][2], work_matrix[1][3], 
//            work_matrix[2][0], work_matrix[3][1]
//        );
        
//        // Q7: (0,3), (1,0), (2,1), (3,2)
//        quarter_round(
//            work_matrix[0][3], work_matrix[1][0], 
//            work_matrix[2][1], work_matrix[3][2],
//            work_matrix[0][3], work_matrix[1][0], 
//            work_matrix[2][1], work_matrix[3][2]
//        );
        
//        // Copy result
//        for (int i = 0; i < 4; i++)
//            for (int j = 0; j < 4; j++)
//                output_matrix[i][j] = work_matrix[i][j];
//    endtask
    
//    initial begin
//        $display("=== Q0-Q7 Quarter-Round Operations Test ===");
        
//        // Initialize with simple test pattern
//        chachamatrixIN[0][0] = 32'h61707865;  // "expa"
//        chachamatrixIN[0][1] = 32'h3320646e;  // "nd 3" 
//        chachamatrixIN[0][2] = 32'h79622d32;  // "2-by"
//        chachamatrixIN[0][3] = 32'h6b206574;  // "te k"
        
//        chachamatrixIN[1][0] = 32'h00000001;
//        chachamatrixIN[1][1] = 32'h00000002;
//        chachamatrixIN[1][2] = 32'h00000003;
//        chachamatrixIN[1][3] = 32'h00000004;
        
//        chachamatrixIN[2][0] = 32'h00000005;
//        chachamatrixIN[2][1] = 32'h00000006;
//        chachamatrixIN[2][2] = 32'h00000007;
//        chachamatrixIN[2][3] = 32'h00000008;
        
//        chachamatrixIN[3][0] = 32'h00000009;
//        chachamatrixIN[3][1] = 32'h0000000a;
//        chachamatrixIN[3][2] = 32'h0000000b;
//        chachamatrixIN[3][3] = 32'h0000000c;
        
//        $display("\nInput Matrix:");
//        for (int i = 0; i < 4; i++) begin
//            $write("Row %0d: ", i);
//            for (int j = 0; j < 4; j++)
//                $write("%08h ", chachamatrixIN[i][j]);
//            $write("\n");
//        end
        
//        // Calculate expected result after one complete round
//        calculate_one_round(chachamatrixIN, expected_matrix);
        
//        $display("\nExpected after one round (Q0-Q7):");
//        for (int i = 0; i < 4; i++) begin
//            $write("Row %0d: ", i);
//            for (int j = 0; j < 4; j++)
//                $write("%08h ", expected_matrix[i][j]);
//            $write("\n");
//        end
        
//        // Start the module
//        setRounds = 1;
//        #20;
//        setRounds = 0;
        
//        // Wait for completion 
//        $display("\nWaiting for module to complete Q0-Q7 operations...");
        
//         cycle_count = 0;
//        while (!blockready && cycle_count < 3000) begin
//            @(posedge clk);
//            cycle_count++;
//        end
        
//        if (blockready) begin
//            $display("Module completed after %0d cycles", cycle_count);
            
//            $display("\nActual Output Matrix:");
//            for (int i = 0; i < 4; i++) begin
//                $write("Row %0d: ", i);
//                for (int j = 0; j < 4; j++)
//                    $write("%08h ", chachamatrixOUT[i][j]);
//                $write("\n");
//            end
            
//            // Note: The module does 20 rounds and adds original matrix
//            // So we need to calculate 20 rounds + original addition for comparison
//            $display("\nNOTE: Module performs 20 rounds + original matrix addition");
//            $display("This test shows the Q0-Q7 operations are working if module completes successfully");
//            $display("✓ Q0-Q7 Quarter-Round Operations Test PASSED");
            
//        end else begin
//            $display("✗ Q0-Q7 Quarter-Round Operations Test FAILED - Timeout");
//        end
        
//        $display("\n=== Test Complete ===");
//        $finish;
//    end
    
