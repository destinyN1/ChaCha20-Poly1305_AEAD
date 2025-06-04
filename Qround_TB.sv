//typedef logic [31:0] word_t;

module Q0_Q7_Test_TB;
    // Test signals
    logic clk, setRounds;
    word_t chachamatrixIN [3:0][3:0];
    word_t chachamatrixOUT [3:0][3:0];
    logic blockready;
    logic [3:0] blocksproduced;
    
    
    typedef enum {IDLE, S0, S1, S2, S3, S4, S5, S6, S7} ARXSTATE;
    
    logic [2:0] prev_currstep;
    logic [2:0] prev_currq;
    
    // Test variables
    word_t expected_matrix [3:0][3:0];
    int cycle_count;
    
    
    //signal variable for the state tracker
    logic track;
    

    
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
        
       
        
        
        //Function that will print the inputmatrix
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
    
    //fill the matrix with rand values
     task fill_matrix_random(); 
        for (int i = 0; i < 4; i++) begin
            for(int j = 0; j < 4; j++) begin
                chachamatrixIN[i][j] = $urandom();
            end
        end
    endtask
    
    
    
   

//will run from Q0-Q7
  task test_arx_ops(  word_t chachamatrixIN [3:0][3:0] );
  
       
       //variables that go into the simulated FSM
       word_t test_a,test_b,test_c,test_d; //INPUT
       
       //values that the simulated FSM will produce
       //will be compared with the DUT
       word_t exp_a,exp_b,exp_c,exp_d; //OUTPUT    
       
       //stepper variable which will be used to move through simulated FSM  
        logic [3:0] QSTEP;
       
       
       
       
//       test10,test11,test12,test13,
//       test20,test21, test22, test23,
//       test30, test31, test32, test33;
        
        //word_t TESTINPUTMATRIX[3:0][3:0];
        
     chachamatrixIN[0][0] = test_a;
    chachamatrixIN[1][0] = test_b; 
    chachamatrixIN[2][0] = test_c;
    chachamatrixIN[3][0] = test_d;    
        
        //fill in the test matrix with dont care values
        for (int x = 0; x<4; x++) begin
            for(int y = 1; y<4; y++) begin
               chachamatrixIN[x][y] =32'h00000000;
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
        
        calculate_step( test_a,test_b,test_c,test_d,
  exp_a,exp_b,exp_c,exp_d);    
                 
       endtask 
       
       
//will run from IDLE to S6       
  task calculate_step( test_a, test_b, test_c, test_d,
 output exp_a, exp_b, exp_c, exp_d);
 
 int SSTEP;
 //state tracking variables  
 SSTEP = 0;

 //SIMULATED FSM
 while(SSTEP < 9) begin
    //track = 1;
@(posedge clk)

        stepper( test_a,test_b,test_c,test_d, exp_a,exp_b,exp_c,exp_d);     
    
        test_a = exp_a;
        test_b = exp_b;
        test_c = exp_c;
        test_d = exp_d;
        
        SSTEP = SSTEP + 1;

    
 end
 SSTEP = 0;
 
 endtask     
 
 
 //ARX OPERATIONS 
 task stepper( test_a,test_b,test_c,test_d, output exp_a,exp_b,exp_c,exp_d);
 
  
    case(uut.Currstep) 
    
    IDLE: begin
      //IDLE STATE SO DO NOTHING
        
            $display("IN IDLE ");
            

    
     end
     
     S0: begin
      //IDLE STATE SO DO NOTHING
        //if(uut.Currstep == IDLE) begin
            $display("IN S0 STATE");      
                       

        end
    
    // end
     
     S1: begin
      //IDLE STATE SO DO NOTHING
            $display("IN S1 STATE");      

        end

     
     S2: begin
      //IDLE STATE SO DO NOTHING
            $display("IN S2 STATE");      

    
     end
     S3: begin
      //IDLE STATE SO DO NOTHING
            $display("IN S3 STATE");      

    
     end
     
     S4: begin
      //IDLE STATE SO DO NOTHING
            $display("IN S4 STATE");      

    
     end
     
     S5: begin
            $display("IN S5 STATE");      

    
     end
     
     S6: begin
            $display("IN S6 STATE");      

    
     end
     
     S7: begin
      //IDLE STATE SO DO NOTHING
            $display("IN S7 STATE");      

    
     end
     
     
    
    endcase   
endtask
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
       
   
   
  
   
  initial begin
  
        $display("=== ChaCha20 PerformQround Test ===");
        setRounds = 0;
        
        #20;
        // Test 1: Random values
        $display("Test 1: Random input values");
        setRounds = 1;
        fill_matrix_random();
        #20;
        print_input_matrix();
        #20;
        
        ///////NOTE WHEN FILLING THE MATRIX SETROUNDS NEED TO = 1/// ELSE KEEP LOW ALL THE TIME WHILE FSMS ARE RUNNING
        
        
        
        
        
        $display("Test 2: Move through states IDLE-S7, Performing ARX ops");
      #20;
           setRounds = 1;
           #20;
           setRounds = 0;
       test_arx_ops(chachamatrixIN);
       
       $display("exited");
        
        #1000;
        
      
            
        
  $finish;
 end
  
  
  
  
  
    
    
    
    
    endmodule
    
    
    
//    // Helper task for quarter-round calculation
//    task automatic quarter_round(
//        input word_t temp_a, temp_b, temp_c,temp_d,
//        output word_t a_out, b_out, c_out, d_out
//    );
//        word_t a, b, c, d;
//        a = temp_a; b = temp_b; c = temp_c; d =temp_d;
        
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
    
