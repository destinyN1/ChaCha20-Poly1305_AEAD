//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 05/23/2025 02:03:31 PM
//// Design Name: 
//// Module Name: PerformQround
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

//typedef logic [31:0] word_t;

//perform all necessary Q rounds, track which Q round we need to perform, add initial chacha matrix to finished one and then output
module PerformQround
(
    input  word_t chachamatrixIN[3:0][3:0],
    input  logic  clk, setRounds, 
    output word_t chachamatrixOUT[3:0][3:0],
    
    output logic blockready
   // output logic [31:0] blocksproduced // can change this to a paramaterised type at some point to speciufy how many blocks are expected to be produced
);
    //intermediate value held for calculations and initial value held for adding at the end
    word_t INITchachastate [3:0][3:0];
    word_t INITINITchachastate [3:0][3:0];
    
    //temp matrix to hold values for Qround 0 - 3
    word_t TEMPpchachastate [3:0][3:0];
    
    
    //another temp matrix to hold values for Qround 4 - 7
    word_t TEMPchachastateQ4Q7 [3:0][3:0];
    
    word_t a, b, c, d;
    
    logic loadvalues;
    
    logic idle;
        
    typedef enum {Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7} Qround;
    Qround CurrQ, NextQ;
    
    typedef enum {IDLE,S0, S1, S2, S3, S4, S5, S6, S7,S8,S9,S10,S11,S12} stepper;
        stepper Currstep, Nextstep;

    int counter;
    
    //STEP state shifter
    //state logic   
    always_ff @(posedge clk) begin
        // NextQ = CurrQ;
        if (setRounds) begin  //Required to set this at Initialisation
            Currstep <= IDLE;
            CurrQ <= Q0;
            counter <= 0;
            TEMPchachastateQ4Q7 <= '{default:0};
            loadvalues <= 1; // need to keep this value high while loading the matrix 
             
        end  
        else begin      
            Currstep <= Nextstep;
            
            
            
            if((CurrQ == Q7)&& (Currstep == S12)) begin
                counter <= counter + 1;
                
            end
            else if((counter == 9) && ((Currstep == S12) && (CurrQ == Q7))) begin
                counter <= 0;
            end
        end 
    end
    
   
      
    
    
    //logic for 1 Q round
    always_ff @(posedge clk) begin
        if(setRounds) begin 
            CurrQ <= Q0;
        end
        else if (Currstep == S12) begin
        CurrQ <= NextQ;
        end
     
        //if right values are loaded perform the Qround
        if(loadvalues  == 0) begin
//         if (makeidle == 1) begin
//           idle <= 1;
//          end
//         else begin
         idle <= 0;
          
            case (Currstep)
                
                IDLE: begin
                
                end
                 
                S0: begin
                a <= a +b;    
                end
                
                S1: begin
                d = d ^ a;   
                end   
                
                S2: begin
                d <= {d[15:0],d[31:16]};    
                end
                
                S3: begin
                 c <= c + d; 
                end
                
                S4: begin
                 b = c ^b;  
                end
                
                S5: begin
                 b <= {b[19:0],b[31:20]};   
                end
                
                S6: begin
                  a <= a + b;
                end   
             
                S7: begin    
                  d <= d ^ a;  
                end
                
                S8: begin    
                   d <= {d[23:0],d[31:24]};
                end
                S9: begin   
                c <= c + d; 
                end
                S10: begin 
                b <= b ^ c;   
                end
                S11: begin 
                b <= {b[24:0],b[31:25]};   
                end 
               S12: begin
               loadvalues <= 1;
                
                
                end
            endcase
        end
        //end
        else begin 
            if (counter == 0) begin
            
            case(CurrQ)
                Q0: begin
                    a <= INITINITchachastate[0][0];
                    b <= INITINITchachastate[1][0];
                    c <= INITINITchachastate[2][0];
                    d <= INITINITchachastate[3][0];
                    loadvalues <= 0;
                   // assignnew <=1;
                    

                end 
             
                Q1: begin
                    a <= INITINITchachastate[0][1];
                    b <= INITINITchachastate[1][1];
                    c <= INITINITchachastate[2][1];
                    d <= INITINITchachastate[3][1];
                    loadvalues <= 0;
                end 
          
                Q2: begin
                    a <= INITINITchachastate[0][2];
                    b <= INITINITchachastate[1][2];
                    c <= INITINITchachastate[2][2];
                    d <= INITINITchachastate[3][2];
                    loadvalues <= 0;
                end 
          
                Q3: begin
                    a <= INITINITchachastate[0][3];
                    b <= INITINITchachastate[1][3];
                    c <= INITINITchachastate[2][3];
                    d <= INITINITchachastate[3][3];
                    loadvalues <= 0;
                    
                 
                end 
          
                Q4: begin
                //From Q4 and onwards use new values
                    a <=TEMPchachastateQ4Q7[0][0];
                    b <=TEMPchachastateQ4Q7[1][1];
                    c <=TEMPchachastateQ4Q7[2][2];
                    d <=TEMPchachastateQ4Q7[3][3];
                    loadvalues <= 0;
                end 
          
                Q5: begin
                    a <=TEMPchachastateQ4Q7[0][1];
                    b <=TEMPchachastateQ4Q7[1][2];
                    c <=TEMPchachastateQ4Q7[2][3];
                    d <=TEMPchachastateQ4Q7[3][0];
                    loadvalues <= 0;
                end 
          
                Q6: begin
                    a <=TEMPchachastateQ4Q7[0][2];
                    b <=TEMPchachastateQ4Q7[1][3];
                    c <=TEMPchachastateQ4Q7[2][0];
                    d <=TEMPchachastateQ4Q7[3][1];
                    loadvalues <= 0;
                end
          
                Q7: begin
                    a <=TEMPchachastateQ4Q7[0][3];
                    b <=TEMPchachastateQ4Q7[1][0];
                    c <=TEMPchachastateQ4Q7[2][1];
                    d <=TEMPchachastateQ4Q7[3][2];
                    loadvalues <= 0;
                end 
                 
                
            endcase    
        end
        //logic for ARX ops after first set of Qrounds
        else if ((counter > 0) && (counter <= 10)) begin
        
            case(CurrQ)
                Q0: begin
                    a <= INITchachastate[0][0];
                    b <= INITchachastate[1][0];
                    c <= INITchachastate[2][0];
                    d <= INITchachastate[3][0];
                    loadvalues <= 0;
                   // assignnew <=1;
                    

                end 
             
                Q1: begin
                    a <= INITchachastate[0][1];
                    b <= INITchachastate[1][1];
                    c <= INITchachastate[2][1];
                    d <= INITchachastate[3][1];
                    loadvalues <= 0;
                end 
          
                Q2: begin
                    a <= INITchachastate[0][2];
                    b <= INITchachastate[1][2];
                    c <= INITchachastate[2][2];
                    d <= INITchachastate[3][2];
                    loadvalues <= 0;
                end 
          
                Q3: begin
                    a <= INITchachastate[0][3];
                    b <= INITchachastate[1][3];
                    c <= INITchachastate[2][3];
                    d <= INITchachastate[3][3];
                    loadvalues <= 0;
                    
                 
                end 
          
                Q4: begin
                //From Q4 and onwards use new values
                    a <=TEMPchachastateQ4Q7[0][0];
                    b <=TEMPchachastateQ4Q7[1][1];
                    c <=TEMPchachastateQ4Q7[2][2];
                    d <=TEMPchachastateQ4Q7[3][3];
                    loadvalues <= 0;
                end 
          
                Q5: begin
                    a <=TEMPchachastateQ4Q7[0][1];
                    b <=TEMPchachastateQ4Q7[1][2];
                    c <=TEMPchachastateQ4Q7[2][3];
                    d <=TEMPchachastateQ4Q7[3][0];
                    loadvalues <= 0;
                end 
          
                Q6: begin
                    a <=TEMPchachastateQ4Q7[0][2];
                    b <=TEMPchachastateQ4Q7[1][3];
                    c <=TEMPchachastateQ4Q7[2][0];
                    d <=TEMPchachastateQ4Q7[3][1];
                    loadvalues <= 0;
                end
          
                Q7: begin
                    a <=TEMPchachastateQ4Q7[0][3];
                    b <=TEMPchachastateQ4Q7[1][0];
                    c <=TEMPchachastateQ4Q7[2][1];
                    d <=TEMPchachastateQ4Q7[3][2];
                    loadvalues <= 0;
                end 
                endcase
        
        end
        
        end
    end
    
    
  
    
    
    // Combinational logic for storing quarter-round results
    always_ff @(posedge clk) begin
     if(setRounds) begin
      TEMPpchachastate <= chachamatrixIN;
      end
      
      end

    
    always_ff @(posedge clk) begin
    
        if (counter == 0) begin
        
        case (CurrQ) 
            Q0: begin
                TEMPpchachastate[0][0] <= a;
                TEMPpchachastate[1][0] <= b;
                TEMPpchachastate[2][0] <= c;
                TEMPpchachastate[3][0] <= d;
            end
            
            Q1: begin
                TEMPpchachastate[0][1] <= a;
                TEMPpchachastate[1][1] <= b;
                TEMPpchachastate[2][1] <= c;
                TEMPpchachastate[3][1] <= d;
            end
            
            Q2: begin
                TEMPpchachastate[0][2] <= a;
                TEMPpchachastate[1][2] <= b;
                TEMPpchachastate[2][2] <= c;
                TEMPpchachastate[3][2] <= d;
            end
            
            Q3: begin
                TEMPpchachastate[0][3] <= a;
                TEMPpchachastate[1][3] <= b;
                TEMPpchachastate[2][3] <= c;
                TEMPpchachastate[3][3] <= d;
            end
            
            Q4: begin
                TEMPchachastateQ4Q7[0][0] <= a;
                TEMPchachastateQ4Q7[1][1] <= b;
                TEMPchachastateQ4Q7[2][2] <= c;
                TEMPchachastateQ4Q7[3][3] <= d;
            end
            
            Q5: begin
                TEMPchachastateQ4Q7[0][1] <= a;
                TEMPchachastateQ4Q7[1][2] <= b;
                TEMPchachastateQ4Q7[2][3] <= c;
                TEMPchachastateQ4Q7[3][0] <= d;
            end
            
            Q6: begin
                TEMPchachastateQ4Q7[0][2] <= a;
                TEMPchachastateQ4Q7[1][3] <= b;
                TEMPchachastateQ4Q7[2][0] <= c;
                TEMPchachastateQ4Q7[3][1] <= d;
            end
            
            Q7: begin
                TEMPchachastateQ4Q7[0][3] <= a;
                TEMPchachastateQ4Q7[1][0] <= b;
                TEMPchachastateQ4Q7[2][1] <= c;
                TEMPchachastateQ4Q7[3][2] <= d;
            end
            
        endcase
        end
        
        else if ((counter > 0) && (counter <= 10)) begin
        case (CurrQ) 
            Q0: begin
                INITchachastate[0][0] <= a;
                INITchachastate[1][0] <= b;
                INITchachastate[2][0] <= c;
                INITchachastate[3][0] <= d;
            end
            
            Q1: begin
                INITchachastate[0][1] <= a;
                INITchachastate[1][1] <= b;
                INITchachastate[2][1] <= c;
                INITchachastate[3][1] <= d;
            end
            
            Q2: begin
                INITchachastate[0][2] <= a;
                INITchachastate[1][2] <= b;
                INITchachastate[2][2] <= c;
                INITchachastate[3][2] <= d;
            end
            
            Q3: begin
                INITchachastate[0][3] <= a;
                INITchachastate[1][3] <= b;
                INITchachastate[2][3] <= c;
                INITchachastate[3][3] <= d;
            end
            
            Q4: begin
                TEMPchachastateQ4Q7[0][0] <= a;
                TEMPchachastateQ4Q7[1][1] <= b;
                TEMPchachastateQ4Q7[2][2] <= c;
                TEMPchachastateQ4Q7[3][3] <= d;
            end
            
            Q5: begin
                TEMPchachastateQ4Q7[0][1] <= a;
                TEMPchachastateQ4Q7[1][2] <= b;
                TEMPchachastateQ4Q7[2][3] <= c;
                TEMPchachastateQ4Q7[3][0] <= d;
            end
            
            Q6: begin
                TEMPchachastateQ4Q7[0][2] <= a;
                TEMPchachastateQ4Q7[1][3] <= b;
                TEMPchachastateQ4Q7[2][0] <= c;
                TEMPchachastateQ4Q7[3][1] <= d;
            end
            
            Q7: begin
                TEMPchachastateQ4Q7[0][3] <= a;
                TEMPchachastateQ4Q7[1][0] <= b;
                TEMPchachastateQ4Q7[2][1] <= c;
                TEMPchachastateQ4Q7[3][2] <= d;       
        end
        endcase
        end
  end  
    // Next step logic
    always_comb begin
        Nextstep = Currstep;
        
        //could also make this the state machine for Q rounds too
        // State machine logic for stepper
        case (Currstep)
            IDLE:Nextstep = S0;
            S0: Nextstep = S1;
            S1: Nextstep = S2;
            S2: Nextstep = S3;
            S3: Nextstep = S4;
            S4: Nextstep = S5;
            S5: Nextstep = S6;
            S6: Nextstep = S7;  // Loop back to start or advance Q round
            S7: Nextstep = S8;
            S8: Nextstep = S9;
            S9: Nextstep = S10;
            S10: Nextstep = S11;
            S11: Nextstep = S12;
            S12: Nextstep = IDLE;
            default: Nextstep = IDLE;
        endcase
    end
    
    //handles cases where errors pop up
    always_latch begin
        if((CurrQ == Q4) && (counter == 0)) begin  
               TEMPchachastateQ4Q7 = TEMPpchachastate;
        end
        else if (((CurrQ == Q4) && (Currstep == IDLE) && ((counter > 0)&&(counter <= 10)))) begin
         
         TEMPchachastateQ4Q7 = INITchachastate;
        end
        
        //copy values from Q4Q7 matrix to the temp so it can be used at the beginning of the new Qround
        if(((CurrQ == Q0) && (Currstep == IDLE )) && ((counter > 0) && (counter <= 10)) ) begin
        
        INITchachastate = TEMPchachastateQ4Q7;
        
        
        end
        //copy input matrix into temp matrix at the very start of the system
        else if (((CurrQ == Q0) && (Currstep == IDLE )) && (counter == 0 )) begin
            
            INITINITchachastate = chachamatrixIN;
               
        end
        
        
        end
        
    
    //CHANGE THIS FILL MATRIX STATEMENT INTO AN FF BLOCK EVENTUALLY 
    //Comb logic for moving to various Q rounds
    always_comb begin
//        for (int x = 0; x < 4; x++) begin
//            for (int y = 0; y < 4; y++) begin
//                INITINITchachastate[x][y] =chachamatrixIN[x][y];
//            end
//        end
        
        
        
        NextQ = CurrQ;

        case (CurrQ)
            Q0: begin
                NextQ = Q1;
            end            
            
            Q1: begin           
                NextQ = Q2;
            end         
            
            Q2: begin         
                NextQ = Q3;
            end           
            
            Q3: begin          
                NextQ = Q4;
            end           
            
            Q4: begin         
                NextQ = Q5;
            end    
            
            Q5: begin         
                NextQ = Q6;
            end
            
            Q6: begin          
                NextQ = Q7;
            end        
            
            Q7: begin
                NextQ = Q0;
            end  
            default: begin
        NextQ = Q0;  // Default to Q0 if unexpected value
    end
        endcase
    //essentially delayed by one clock from final valid operation state
        if ((counter == 10)) begin //&& (Currstep == IDLE) && (CurrQ == Q0)) begin
            for (int x = 0; x < 4; x++) begin
                for (int y = 0; y < 4; y++) begin
                    chachamatrixOUT[x][y] = INITINITchachastate[x][y] + TEMPchachastateQ4Q7[x][y];
                    blockready = 1;
                end
            end
        end
        else begin
            chachamatrixOUT = '{default:0};
            blockready = 0;
        end 
    end
    
endmodule