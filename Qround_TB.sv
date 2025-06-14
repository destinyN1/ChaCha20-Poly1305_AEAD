module Q0_Q7_Test_TB;
    // Test signals
    logic clk, setRounds;
    word_t chachamatrixIN [3:0][3:0];
    word_t chachamatrixOUT [3:0][3:0];
    
    
    logic blockready;
    logic [3:0] blocksproduced;
    
    typedef enum {IDLE, S0, S1, S2, S3, S4, S5, S6, S7} ARXSTATE;
    typedef enum { Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7} QSTATE;

    
    logic [2:0] prev_currstep;
    logic [2:0] prev_currq;
    
    
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
    
    // Reference Values for step by step verification
    
    
    //function that will perform Qrounds
    
    
    
    
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
        $display("Temp Matrix:");
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
        fill_matrix_random();
        #10;
        print_input_matrix();        
        
        //Essentially Q0
//        chachamatrixIN[0][0] = test_a;
//        chachamatrixIN[1][0] = test_b; 
//        chachamatrixIN[2][0] = test_c;
//        chachamatrixIN[3][0] = test_d;    
        
        // Fill in the test matrix with dont care values
//        for (int x = 0; x < 4; x++) begin
//            for(int y = 1; y < 4; y++) begin
//                chachamatrixIN[x][y] = 32'h00000000;
//            end
//        end
        
        @(posedge clk);
        @(posedge clk);
        setRounds = 0;
        
//        $display("Matrix with filled in Values:");
//        for (int i = 0; i < 4; i++) begin
//            $write("Row %0d: ", i);
//            for(int j = 0; j < 4; j++) begin
//                $write("%08h ", chachamatrixIN[i][j]);
//            end
//            $write("\n");
//        end
//        $display(""); // Add blank line  
        
        //need to write a sort of a while loop that will call calc_step() and then move to the next Qround
        //will write a function that moves to next Qround
           
       QSTEP = 0;

       while( QSTEP <8) begin
       
       
       Move_Q(test_a,test_b,test_c,test_d,exp_a,exp_b, exp_c,exp_d);
       
       test_a = exp_a;
       test_b = exp_b;
       test_c = exp_c;
       test_d = exp_d;
       
       
        
        calculate_step(test_a, test_b, test_c, test_d, exp_a, exp_b, exp_c, exp_d);   
        
        QSTEP = QSTEP +1;
        
      end
      QSTEP = 0;  
         
    endtask 
    
    
    //Function that is responsible for loading correct a,b,c,d values from corresponding matrix locations
    

    
    
    // Will run from IDLE to S6       
    task calculate_step(input word_t test_a, test_b, test_c, test_d,
                       output word_t exp_a, exp_b, exp_c, exp_d);
        
        int SSTEP;
        // State tracking variables  
        SSTEP = 0;
        
        // SIMULATED FSM
        while(SSTEP < 8) begin
            @(posedge clk);
            
            stepper(test_a, test_b, test_c, test_d, exp_a, exp_b, exp_c, exp_d);
            
            #5;
            
            if(((exp_a == uut.a) && (exp_b == uut.b)) && ((exp_c == uut.c) && (exp_d == uut.d))) begin
                $display("S%0d PASS \n UUT.A/EXP_A = %08h/%08h \n UUT.B/EXP_B = %08h/%08h \n UUT.C/EXP_C = %08h/%08h \n UUT.D/EXP_D = %08h/%08h \n ", 
                         SSTEP, uut.a, exp_a, uut.b, exp_b, uut.c, exp_c, uut.d, exp_d);
            end
//            else if (uut.Currstep == IDLE) begin
//                $display("IN IDLE");
//            end      
            else begin
                $display("S%0d FAIL \n UUT.A/EXP_A = %08h/%08h \n UUT.B/EXP_B = %08h/%08h \n UUT.C/EXP_C = %08h/%08h \n UUT.D/EXP_D = %08h/%08h \n ", 
                         SSTEP, uut.a, exp_a, uut.b, exp_b, uut.c, exp_c, uut.d, exp_d);            end
            
            test_a = exp_a;
            test_b = exp_b;
            test_c = exp_c;
            test_d = exp_d;
            
            if (uut.Currstep != IDLE) begin
            SSTEP = SSTEP + 1;
            end
            
            //MAYBE ADD SOME DELAY LOGIC HERE
            
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
                // IDLE STATE SO DO NOTHING
                $display("IN IDLE ");
            end
            
            S0: begin
                $display("IN S0 STATE");     
                temp_a = temp_a + temp_b;
                temp_d = temp_d ^ temp_a; 
                $display("  After S0:  temp_a = %08h, temp_d = %08h", temp_a, temp_d);
                
                
                print_input_matrix();
                 print_temp_matrix();
                 print_tempQ0Q7_matrix();
                
            end
            
            S1: begin
                $display("IN S1 STATE");
                temp_c = temp_c + temp_d;
                temp_d = {temp_d[15:0], temp_d[31:16]}; // ROL 16     
                $display("  After S1:  temp_c = %08h, temp_d = %08h", temp_c, temp_d);
            end
            
            S2: begin
                $display("IN S2 STATE");      
                temp_b = temp_b ^ temp_c;
                temp_d = temp_d ^ temp_a;
                $display("  After S2:  temp_b = %08h, temp_d = %08h", temp_b, temp_d);
            end
            
            S3: begin
                $display("IN S3 STATE");      
                temp_b = {temp_b[19:0], temp_b[31:20]}; // ROL 12
                temp_d = {temp_d[15:0], temp_d[31:16]}; // ROL 16
                $display("  After S3:  temp_b = %08h, temp_d = %08h", temp_b, temp_d);  
            end
            
            S4: begin
                $display("IN S4 STATE");      
                temp_a = temp_a + temp_b;
                temp_d = {temp_d[23:0], temp_d[31:24]}; // ROL 8
                $display("  After S4:  temp_a = %08h, temp_d = %08h", temp_a, temp_d);  
            end
            
            S5: begin
                $display("IN S5 STATE");  
                temp_c = temp_c + temp_d;
                temp_d = {temp_d[24:0], temp_d[31:25]}; // ROL 7              
                $display("  After S5:  temp_c = %08h, temp_d = %08h", temp_c, temp_d);  
            end
            
            S6: begin
                $display("IN S6 STATE");      
                temp_b = temp_b ^ temp_c;
                $display("  After S6:  temp_b = %08h", temp_b);  
            end
            
            S7: begin
           $display("IN S7 STATE, DO NOTHING");      
                
//               if(uut.CurrQ == Q3) begin
//                print_temp_matrix();
//               print_tempQ0Q7_matrix();
                    
//                   end
                    
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
    
    
    
     task Move_Q(input word_t test_a,test_b, test_c,test_d, output word_t exp_a,exp_b, exp_c,exp_d);
    
    word_t testq_a,testq_b,testq_c,testq_d;
    
    testq_a = test_a;
    testq_b = test_b;
    testq_c = test_c;
    testq_d = test_d;
    
    
    case(uut.CurrQ)
    
    Q0:begin 
    testq_a = chachamatrixIN[0][0];
    testq_b = chachamatrixIN[1][0]; 
    testq_c = chachamatrixIN[2][0];
    testq_d = chachamatrixIN[3][0];
    $display("In Q%0d \n",QSTEP);    
    
    
    $display("INPUT MATRIX \n");        
                print_input_matrix();
                #5;
          $display("TEMP MATRIX \n");    
                print_temp_matrix();    

    
    $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);    

   end
    Q1:begin 
        testq_a = chachamatrixIN[0][1];
        testq_b = chachamatrixIN[1][1]; 
        testq_c = chachamatrixIN[2][1];
        testq_d = chachamatrixIN[3][1];  
        $display("In Q%0d \n",QSTEP); 
          
        $display("INPUT MATRIX \n");        
        print_input_matrix();
                
       $display("TEMP MATRIX \n");    
       print_temp_matrix();    

                
                        

        
        $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);    
 
       end
    Q2:begin 
        testq_a = chachamatrixIN[0][2];
        testq_b = chachamatrixIN[1][2]; 
        testq_c = chachamatrixIN[2][2];
        testq_d = chachamatrixIN[3][2];
        $display("In Q%0d \n",QSTEP); 
          
        $display("INPUT MATRIX \n");        
        print_input_matrix();
                
        $display("TEMP MATRIX \n");    
        print_temp_matrix();
       
        $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);
       end       
     Q3:begin 
        testq_a = chachamatrixIN[0][3];
        testq_b = chachamatrixIN[1][3]; 
        testq_c = chachamatrixIN[2][3];
        testq_d = chachamatrixIN[3][3];
         $display("In Q%0d \n",QSTEP); 
          
        $display("INPUT MATRIX \n");        
        print_input_matrix();
                
        $display("TEMP MATRIX \n");    
        print_temp_matrix();
        
        $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);
       end       
     Q4:begin 
        testq_a = uut.TEMPchachastateQ4Q7[0][0];
        testq_b = uut.TEMPchachastateQ4Q7[1][1]; 
        testq_c = uut.TEMPchachastateQ4Q7[2][2];
        testq_d = uut.TEMPchachastateQ4Q7[3][3];
        $display("In Q%0d \n",QSTEP); 
          
        $display("TEMP MATRIX \n");        
        print_input_matrix();
                
        $display("TEMPQ4Q MATRIX \n");    
        print_tempQ0Q7_matrix();
        
        $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);
       end      
     Q5:begin 
        testq_a = uut.TEMPchachastateQ4Q7[0][1];
        testq_b = uut.TEMPchachastateQ4Q7[1][2]; 
        testq_c = uut.TEMPchachastateQ4Q7[2][3];
        testq_d = uut.TEMPchachastateQ4Q7 [3][0];
        $display("In Q%0d \n",QSTEP); 
          
        $display("INPUT MATRIX \n");        
        print_input_matrix();
                
        $display("TEMP MATRIX \n");    
        print_tempQ0Q7_matrix();
        
        $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);
       end     
      Q6:begin 
        testq_a = uut.TEMPchachastateQ4Q7 [0][2];
        testq_b = uut.TEMPchachastateQ4Q7 [1][3]; 
        testq_c = uut.TEMPchachastateQ4Q7 [2][0];
        testq_d = uut.TEMPchachastateQ4Q7 [3][1];
        $display("In Q%0d \n",QSTEP); 
          
        $display("INPUT MATRIX \n");        
        print_input_matrix();
                
        $display("TEMP MATRIX \n");    
        print_tempQ0Q7_matrix();
        $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);
       end
     Q7:begin 
        testq_a = uut.TEMPchachastateQ4Q7[0][3];
        testq_b = uut.TEMPchachastateQ4Q7 [1][0]; 
        testq_c = uut.TEMPchachastateQ4Q7[2][1];
        testq_d = uut.TEMPchachastateQ4Q7[3][2];
        $display("In Q%0d \n",QSTEP); 
          
        $display("INPUT MATRIX \n");        
        print_input_matrix();
                
        $display("TEMP MATRIX \n");    
        print_tempQ0Q7_matrix();
        
        $display("%08h/%08h/%08h/%08h/ \n",testq_a,testq_b,testq_c,testq_d);
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
        
        $display("Test 2: Move through states IDLE-S7, Performing ARX ops");
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