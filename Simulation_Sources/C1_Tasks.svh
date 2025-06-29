`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2025 11:39:06 AM
// Design Name: 
// Module Name: C1_Tasks
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

 
    
 task print_INIT_matrix();
        $display("INIT/TEMP Matrix:");
        for (int i = 0; i < 4; i++) begin
            $write("Row %0d: ", i);
            for(int j = 0; j < 4; j++) begin
                $write("%08h ", uut.INITchachastate[i][j]);
            end
            $write("\n");
        end
        $display(""); // Add blank line
    endtask
    
 //print matrices for counter = 0

 task printC0();   
  if(uut.CurrQ inside {Q0, Q1, Q2, Q3,Q4,Q5,Q6}) begin 
             
               #5; 
                  if(uut.CurrQ inside {Q0, Q1, Q2, Q3}) begin 
        print_temp_matrix();    
      end
       else begin 
        print_tempQ0Q7_matrix();
    end
     //  #5;
     end
     else begin 
     #5;
     print_tempQ0Q7_matrix();
     end
endtask

//print matrices for counter > 0
task printC1();   
  if(uut.CurrQ inside {Q0, Q1, Q2, Q3,Q4,Q5,Q6}) begin 
             
             //  #5; //keep this value as this is the one that works the best
                  if(uut.CurrQ inside {Q0, Q1, Q2, Q3}) begin 
        print_INIT_matrix();    
      end
       else begin //if (uut.CurrQ inside {Q4, Q5, Q6, Q7}) begin
        print_tempQ0Q7_matrix();
    end
     //  #5;
     end
     else begin 
     #5;
     print_tempQ0Q7_matrix();
     end
endtask
      
    
    task Move_QC1(input word_t test_a,test_b, test_c,test_d, output word_t exp_a,exp_b, exp_c,exp_d);
    
    word_t testq_a,testq_b,testq_c,testq_d;
    
    testq_a = test_a;
    testq_b = test_b;
    testq_c = test_c;
    testq_d = test_d;
    
    
    case(uut.CurrQ)
    
    Q0:begin 
    testq_a = uut.INITchachastate[0][0];
    testq_b = uut.INITchachastate[1][0]; 
    testq_c = uut.INITchachastate[2][0];
    testq_d = uut.INITchachastate[3][0];
    $display("In Q%0d \n",QSTEP);    
    
    
    
    

   end
    Q1:begin 
        testq_a = uut.INITchachastate[0][1];
        testq_b = uut.INITchachastate[1][1]; 
        testq_c = uut.INITchachastate[2][1];
        testq_d = uut.INITchachastate[3][1];  
        $display("In Q%0d \n",QSTEP); 
          
       
            
       end
    Q2:begin 
        testq_a = uut.INITchachastate[0][2];
        testq_b = uut.INITchachastate[1][2]; 
        testq_c = uut.INITchachastate[2][2];
        testq_d = uut.INITchachastate[3][2];
        $display("In Q%0d \n",QSTEP); 
          
     
       end       
     Q3:begin 
        testq_a = uut.INITchachastate[0][3];
        testq_b = uut.INITchachastate[1][3]; 
        testq_c = uut.INITchachastate[2][3];
        testq_d = uut.INITchachastate[3][3];
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
    

