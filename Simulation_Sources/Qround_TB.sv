

module Q0_Q7_Test_TB;
    // Test signals
    logic clk, setRounds;
    word_t chachamatrixIN [3:0][3:0];
    word_t chachamatrixOUT [3:0][3:0];
    

    
    logic blockready;
    logic [3:0] blocksproduced;
    
    typedef enum {IDLE, S0, S1, S2, S3, S4, S5, S6, S7,S8,S9,S10,S11,S12} ARXSTATE;
    typedef enum { Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7} QSTATE;

    
    logic [2:0] prev_currstep;
    logic [2:0] prev_currq;
      
    int Round_step; 
    int QSTEP;
    
    // Test variables
    word_t expected_matrix [3:0][3:0];
    int cycle_count;
    
    // Signal variable for the state tracker
    logic track;
    
    word_t exp_a_waveform, exp_b_waveform, exp_c_waveform, exp_d_waveform;
    word_t test_a_waveform, test_b_waveform, test_c_waveform, test_d_waveform;
    
    // Instantiate the module under test
    PerformQround uut (
        .chachamatrixIN(chachamatrixIN),
        .clk(clk),
        .setRounds(setRounds),
        .chachamatrixOUT(chachamatrixOUT),
        .blockready(blockready),
        .blocksproduced(blocksproduced)
    );
    

        `include "C1_Tasks.svh" //include tasks for C1 verification

    // Function that will print the inputmatrix
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
    
    
    task print_temp_matrix();
        $display("Temp Matrix:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", uut.TEMPpchachastate[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
     task print_tempQ0Q7_matrix();
        $display("Temp MatrixQ4Q7:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", uut.TEMPchachastateQ4Q7[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
    // Fill the matrix with rand values
    task fill_matrix_random(); 
        for (int i = 0; i < 4; i++) begin
            for(int j = 0; j < 4; j++) begin
                chachamatrixIN[i][j] = $urandom();
            end
        end
    endtask
    
    
    task fill_matrix_test_vector();
    // ChaCha20 test vector values (completely reversed)
    chachamatrixIN = '{
        '{32'h00000000, 32'h4a000000, 32'h09000000, 32'h00000001},
        '{32'h1f1e1d1c, 32'h1b1a1918, 32'h17161514, 32'h13121110},
        '{32'h0f0e0d0c, 32'h0b0a0908, 32'h07060504, 32'h03020100},
        '{32'h6b206574, 32'h79622d32, 32'h3320646e, 32'h61707865}
    }; 
endtask
    
    

    
    // Will run from Q0-Q7
    task test_arx_ops();
        // Variables that go into the simulated FSM
        word_t test_a, test_b, test_c, test_d; // INPUT
        
        // Values that the simulated FSM will produce
        // Will be compared with the DUT
        word_t exp_a, exp_b, exp_c, exp_d; // OUTPUT    
        
        // Stepper variable which will be used to move through simulated FSM  
        //logic [3:0] QSTEP;
        ;  
        
        setRounds = 1;
        #10;
        fill_matrix_test_vector();
        #10;
        print_input_matrix();        
        
 
        @(posedge clk);
       // @(posedge clk);
        setRounds = 0;
        
        
        //tracks what round we are on, goes in steps of 2 rounds
       Round_step = 1; //starting from one here to make it easier to match with how its done in python
       
       while (Round_step <= 10) begin // does 2 rounds per cycle
        
       QSTEP = 0;

       while( QSTEP <8) begin
       
       
       Move_QC0(test_a,test_b,test_c,test_d,exp_a,exp_b, exp_c,exp_d);
       
       test_a = exp_a;
       test_b = exp_b;
       test_c = exp_c;
       test_d = exp_d;
       
       
        
        calculate_step(test_a, test_b, test_c, test_d, exp_a, exp_b, exp_c, exp_d);   
        
        QSTEP = QSTEP +1;
        
      end
      QSTEP = 0;  
      Round_step = Round_step + 1;
      
      end
      Round_step = 0;   
    endtask 
    
    
    //Function that is responsible for loading correct a,b,c,d values from corresponding matrix locations
    

    
    
    // Will run from IDLE to S6       
    task calculate_step(input word_t test_a, test_b, test_c, test_d,
                       output word_t exp_a, exp_b, exp_c, exp_d);
        
        int SSTEP;
        // State tracking variables  
        SSTEP = 0;
        
        // SIMULATED FSM
        while(SSTEP < 13) begin
            @(posedge clk);
            
            stepper(test_a, test_b, test_c, test_d, exp_a, exp_b, exp_c, exp_d);
            

            
            test_a = exp_a;
            test_b = exp_b;
            test_c = exp_c;
            test_d = exp_d;
            
            if (uut.Currstep != IDLE) begin
            SSTEP = SSTEP + 1;
            end
            
            
        end
        SSTEP = 0;
    endtask     
    
    // ARX OPERATIONS 
    task stepper(input word_t test_a, test_b, test_c, test_d, 
                output word_t exp_a, exp_b, exp_c, exp_d);
        
        word_t temp_a, temp_b, temp_c, temp_d;
        temp_a = test_a; 
        temp_b = test_b; 
        temp_c = test_c; 
        temp_d = test_d;
        
        
        
        case(uut.Currstep) 
            IDLE: begin
  
            end
     
            S0: begin
           //$display("IN S0 STATE");     

                temp_a <= temp_a +temp_b;    
                end
                
                S1: begin
               // $display("IN S1 STATE");     

                temp_d = temp_d ^ temp_a;   
                end   
                
                S2: begin
               // $display("IN S2 STATE");
                temp_d <= {temp_d[15:0],temp_d[31:16]};    
                end
                
                S3: begin
               // $display("IN S3 STATE");
                 temp_c <= temp_c + temp_d; 
                end
                
                S4: begin
              //  $display("IN S4 STATE");
                 temp_b = temp_c ^temp_b;  
                end
                
                S5: begin
              //  $display("IN S5 STATE");
                 temp_b <= {temp_b[19:0],temp_b[31:20]};   
                end
                
                S6: begin
              //  $display("IN S6 STATE");
                  temp_a <= temp_a + temp_b;
                end   
             
                S7: begin
             //   $display("IN S7 STATE");    
                  temp_d <= temp_d ^ temp_a;  
                end
                
                S8: begin
              //  $display("IN S8 STATE");    
                   temp_d <= {temp_d[23:0],temp_d[31:24]};
                end
                S9: begin
             //   $display("IN S9 STATE");   
                temp_c <= temp_c + temp_d; 
                end
                S10: begin
             //   $display("IN S10 STATE"); 
                temp_b <= temp_b ^ temp_c;   
                end
                S11: begin
             //   $display("IN S11 STATE"); 
                temp_b <= {temp_b[24:0],temp_b[31:25]};   
                end
               S12: begin
             //  $display("IN S12 DO NOTIHING");
               
               if(uut.counter == 0) begin 
                    
                   printC0();
                                   
               end
               else begin
               
               printC1();
               end
               end
               
                   
 
    
          
                
                
            endcase
        
        exp_a = temp_a; 
        exp_b = temp_b; 
        exp_c = temp_c; 
        exp_d = temp_d;
        
        exp_a_waveform = exp_a;
        exp_b_waveform = temp_b;
        exp_c_waveform = temp_c;
        exp_d_waveform = temp_d;
    endtask
    
    
    
     task Move_QC0(input word_t test_a,test_b, test_c,test_d, output word_t exp_a,exp_b, exp_c,exp_d);
    
    word_t testq_a,testq_b,testq_c,testq_d;
    
    testq_a = test_a;
    testq_b = test_b;
    testq_c = test_c;
    testq_d = test_d;
    
    
    case(uut.CurrQ)
    
    Q0:begin 
    testq_a = uut.INITINITchachastate[0][0];
    testq_b = uut.INITINITchachastate[1][0]; 
    testq_c = uut.INITINITchachastate[2][0];
    testq_d = uut.INITINITchachastate[3][0];
    $display("In Q%0d \n",QSTEP);    
    $display("In Round %0d \n",Round_step);    

    
    
    
    
    

   end
    Q1:begin 
        testq_a = uut.INITINITchachastate[0][1];
        testq_b = uut.INITINITchachastate[1][1]; 
        testq_c = uut.INITINITchachastate[2][1];
        testq_d = uut.INITINITchachastate[3][1];  
        $display("In Q%0d \n",QSTEP); 
          
       
            
       end
    Q2:begin 
        testq_a = uut.INITINITchachastate[0][2];
        testq_b = uut.INITINITchachastate[1][2]; 
        testq_c = uut.INITINITchachastate[2][2];
        testq_d = uut.INITINITchachastate[3][2];
        $display("In Q%0d \n",QSTEP); 
          
     
       end       
     Q3:begin 
        testq_a = uut.INITINITchachastate[0][3];
        testq_b = uut.INITINITchachastate[1][3]; 
        testq_c = uut.INITINITchachastate[2][3];
        testq_d = uut.INITINITchachastate[3][3];
         $display("In Q%0d \n",QSTEP); 
          
 
       end       
     Q4:begin 
        testq_a = uut.TEMPchachastateQ4Q7[0][0];
        testq_b = uut.TEMPchachastateQ4Q7[1][1]; 
        testq_c = uut.TEMPchachastateQ4Q7[2][2];
        testq_d = uut.TEMPchachastateQ4Q7[3][3];
        $display("In Q%0d \n",QSTEP); 
          
       
       end      
     Q5:begin 
        testq_a = uut.TEMPchachastateQ4Q7[0][1];
        testq_b = uut.TEMPchachastateQ4Q7[1][2]; 
        testq_c = uut.TEMPchachastateQ4Q7[2][3];
        testq_d = uut.TEMPchachastateQ4Q7 [3][0];
        $display("In Q%0d \n",QSTEP); 
          
       
       end     
      Q6:begin 
        testq_a = uut.TEMPchachastateQ4Q7 [0][2];
        testq_b = uut.TEMPchachastateQ4Q7 [1][3]; 
        testq_c = uut.TEMPchachastateQ4Q7 [2][0];
        testq_d = uut.TEMPchachastateQ4Q7 [3][1];
        $display("In Q%0d \n",QSTEP); 
          
      
       end
     Q7:begin 
        testq_a = uut.TEMPchachastateQ4Q7[0][3];
        testq_b = uut.TEMPchachastateQ4Q7 [1][0]; 
        testq_c = uut.TEMPchachastateQ4Q7[2][1];
        testq_d = uut.TEMPchachastateQ4Q7[3][2];
        $display("In Q%0d \n",QSTEP); 
          
       
   end
                     
    
    endcase
    
    exp_a = testq_a;
    exp_b = testq_b;
    exp_c = testq_c;
    exp_d = testq_d;
    
    
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
        
        // NOTE WHEN FILLING THE MATRIX SETROUNDS NEED TO = 1
        // ELSE KEEP LOW ALL THE TIME WHILE FSMS ARE RUNNING
        
        $display("Test 2: Perform full 20 rounds");
        #20;
        setRounds = 1;
        #20;
        setRounds = 0;
        test_arx_ops();
        
        $display("exited");
        
        #1000;
        
        $finish;
    end
    
endmodule