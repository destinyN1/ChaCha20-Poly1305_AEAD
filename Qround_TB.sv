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
        logic [3:0] QSTEP;
        
        setRounds = 1;
        test_a = 32'haaaaaaaa;
        test_b = 32'hbbbbbbbb; 
        test_c = 32'hcccccccc;
        test_d = 32'hdddddddd;
        
        chachamatrixIN[0][0] = test_a;
        chachamatrixIN[1][0] = test_b; 
        chachamatrixIN[2][0] = test_c;
        chachamatrixIN[3][0] = test_d;    
        
        // Fill in the test matrix with dont care values
        for (int x = 0; x < 4; x++) begin
            for(int y = 1; y < 4; y++) begin
                chachamatrixIN[x][y] = 32'h00000000;
            end
        end
        
        @(posedge clk);
        @(posedge clk);
        setRounds = 0;
        
        $display("Matrix with filled in Values an X's:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", chachamatrixIN[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line  
        
        calculate_step(test_a, test_b, test_c, test_d, exp_a, exp_b, exp_c, exp_d);    
    endtask 
    
    // Will run from IDLE to S6       
    task calculate_step(input word_t test_a, test_b, test_c, test_d,
                       output word_t exp_a, exp_b, exp_c, exp_d);
        
        int SSTEP;
        // State tracking variables  
        SSTEP = 0;
        
        // SIMULATED FSM
        while(SSTEP < 8) begin
            @(posedge clk)
            
            stepper(test_a, test_b, test_c, test_d, exp_a, exp_b, exp_c, exp_d);
            
            #5;
            if(((exp_a == uut.a) && (exp_b == uut.b)) && ((exp_c == uut.c) && (exp_d == uut.d))) begin
                $display("S%0d PASS \n UUT.A/EXP_A = %08h/%08h \n UUT.B/EXP_B = %08h/%08h \n UUT.C/EXP_C = %08h/%08h \n UUT.D/EXP_D = %08h/%08h \n ", 
                         SSTEP, uut.a, exp_a, uut.b, exp_b, uut.c, exp_c, uut.d, exp_d);
            end
            else if (uut.Currstep == IDLE) begin
                $display("IN IDLE");
            end      
            else begin
                $display("S%0d FAIL \n UUT.A/EXP_A = %08h/%08h \n UUT.B/EXP_B = %08h/%08h \n UUT.C/EXP_C = %08h/%08h \n UUT.D/EXP_D = %08h/%08h \n ", 
                         SSTEP, uut.a, exp_a, uut.b, exp_b, uut.c, exp_c, uut.d, exp_d);            end
            
            test_a = exp_a;
            test_b = exp_b;
            test_c = exp_c;
            test_d = exp_d;
            
            SSTEP = SSTEP + 1;
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
                // IDLE STATE SO DO NOTHING
                $display("IN S0 STATE");     
                temp_a = temp_a + temp_b;
                temp_d = temp_d ^ temp_a; 
                $display("  After S0:  temp_a = %08h, temp_d = %08h", temp_a, temp_d);
            end
            
            S1: begin
                // IDLE STATE SO DO NOTHING
                $display("IN S1 STATE");
                temp_c = temp_c + temp_d;
                temp_d = {temp_d[15:0], temp_d[31:16]}; // ROL 16     
                $display("  After S1:  temp_c = %08h, temp_d = %08h", temp_c, temp_d);
            end
            
            S2: begin
                // IDLE STATE SO DO NOTHING
                $display("IN S2 STATE");      
                temp_b = temp_b ^ temp_c;
                temp_d = temp_d ^ temp_a;
                $display("  After S2:  temp_b = %08h, temp_d = %08h", temp_b, temp_d);
            end
            
            S3: begin
                // IDLE STATE SO DO NOTHING
                $display("IN S3 STATE");      
                temp_b = {temp_b[19:0], temp_b[31:20]}; // ROL 12
                temp_d = {temp_d[15:0], temp_d[31:16]}; // ROL 16
                $display("  After S3:  temp_b = %08h, temp_d = %08h", temp_b, temp_d);  
            end
            
            S4: begin
                // IDLE STATE SO DO NOTHING
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