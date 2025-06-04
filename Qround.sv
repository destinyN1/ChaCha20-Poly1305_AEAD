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

  typedef logic [31:0] word_t;


//perform all necessary Q rounds, track which Q round we need to perform, add initial chacha matrix to finished one and then output
module PerformQround
(
    input  word_t chachamatrixIN[3:0][3:0],
    input  logic  clk, setRounds, makeidle,
    output word_t chachamatrixOUT[3:0][3:0],
    
    output logic blockready,
    output logic [3:0] blocksproduced // can change this to a paramaterised type at some point to speciufy how many blocks are expected to be produced
);
    //intermediate value held for calculations and initial value held for adding at the end
    word_t INITchachastate [3:0][3:0];
    word_t TEMPpchachastate [3:0][3:0];
    
    word_t a, b, c, d;
    
    logic loadvalues;
    
    logic idle;
        
    typedef enum {Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7} Qround;
    Qround CurrQ, NextQ;
    
    typedef enum {IDLE,S0, S1, S2, S3, S4, S5, S6, S7} stepper;
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
            loadvalues <= 1; // need to keep this value high while loading the matrix 
          
        end  
        else begin      
            Currstep <= Nextstep;
            if(CurrQ == Q7) begin
                counter <= counter + 1;
                loadvalues <= 1;
                
            end
            else if(counter == 20) begin
                counter <= 0;
                blocksproduced = blocksproduced + 1;
            end
        end 
    end
    
    //logic for 1 Q round
    always_ff @(posedge clk) begin
        if(setRounds) begin 
            CurrQ <= Q0;
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
                    a <= a + b;
                    d <= d^(a+b); 
                end
                
                S1: begin
                    c <= c + d;
                    d <= {d[15:0], d[31:16]};
                end   
                
                S2: begin
                    b <= b ^ c;
                    d <= d ^ a;
                end
                
                S3: begin
                    b <= {b[19:0], b[31:20]};
                    d <= {d[15:0], d[31:16]};
                end
                
                S4: begin
                    a <= a + b;
                    d <= {d[23:0], d[31:24]};
                end
                
                S5: begin
                    c <= c + d;
                    d <= {d[24:0], d[31:25]};
                end
                
                S6: begin
                    b <= b ^ c;
                end   
             
                S7: begin    
                    CurrQ <= NextQ;
                    loadvalues <= 1;
                end
            endcase
        end
        //end
        else begin 
            case(CurrQ)
                Q0: begin
                    a <= chachamatrixIN[0][0];
                    b <= chachamatrixIN[1][0];
                    c <= chachamatrixIN[2][0];
                    d <= chachamatrixIN[3][0];
                    loadvalues <= 0;

                end 
             
                Q1: begin
                    a <= chachamatrixIN[0][1];
                    b <= chachamatrixIN[1][1];
                    c <= chachamatrixIN[2][1];
                    d <= chachamatrixIN[3][1];
                    loadvalues <= 0;
                end 
          
                Q2: begin
                    a <= chachamatrixIN[0][2];
                    b <= chachamatrixIN[1][2];
                    c <= chachamatrixIN[2][2];
                    d <= chachamatrixIN[3][2];
                    loadvalues <= 0;
                end 
          
                Q3: begin
                    a <= chachamatrixIN[0][3];
                    b <= chachamatrixIN[1][3];
                    c <= chachamatrixIN[2][3];
                    d <= chachamatrixIN[3][3];
                    loadvalues <= 0;
                end 
          
                Q4: begin
                    a <= chachamatrixIN[0][0];
                    b <= chachamatrixIN[1][1];
                    c <= chachamatrixIN[2][2];
                    d <= chachamatrixIN[3][3];
                    loadvalues <= 0;
                end 
          
                Q5: begin
                    a <= chachamatrixIN[0][1];
                    b <= chachamatrixIN[1][2];
                    c <= chachamatrixIN[2][3];
                    d <= chachamatrixIN[3][0];
                    loadvalues <= 0;
                end 
          
                Q6: begin
                    a <= chachamatrixIN[0][2];
                    b <= chachamatrixIN[1][3];
                    c <= chachamatrixIN[2][0];
                    d <= chachamatrixIN[3][1];
                    loadvalues <= 0;
                end
          
                Q7: begin
                    a <= chachamatrixIN[0][3];
                    b <= chachamatrixIN[1][0];
                    c <= chachamatrixIN[2][1];
                    d <= chachamatrixIN[3][2];
                    loadvalues <= 0;
                end  
            endcase    
        end
    end
    
    // Combinational logic for storing quarter-round results
    always_comb begin
     if(setRounds)
      TEMPpchachastate = chachamatrixIN;
      else
      
        case (CurrQ) 
            Q0: begin
                TEMPpchachastate[0][0] = a;
                TEMPpchachastate[1][0] = b;
                TEMPpchachastate[2][0] = c;
                TEMPpchachastate[3][0] = d;
            end
            
            Q1: begin
                TEMPpchachastate[0][1] = a;
                TEMPpchachastate[1][1] = b;
                TEMPpchachastate[2][1] = c;
                TEMPpchachastate[3][1] = d;
            end
            
            Q2: begin
                TEMPpchachastate[0][2] = a;
                TEMPpchachastate[1][2] = b;
                TEMPpchachastate[2][2] = c;
                TEMPpchachastate[3][2] = d;
            end
            
            Q3: begin
                TEMPpchachastate[0][3] = a;
                TEMPpchachastate[1][3] = b;
                TEMPpchachastate[2][3] = c;
                TEMPpchachastate[3][3] = d;
            end
            
            Q4: begin
                TEMPpchachastate[0][0] = a;
                TEMPpchachastate[1][1] = b;
                TEMPpchachastate[2][2] = c;
                TEMPpchachastate[3][3] = d;
            end
            
            Q5: begin
                TEMPpchachastate[0][1] = a;
                TEMPpchachastate[1][2] = b;
                TEMPpchachastate[2][3] = c;
                TEMPpchachastate[3][0] = d;
            end
            
            Q6: begin
                TEMPpchachastate[0][2] = a;
                TEMPpchachastate[1][3] = b;
                TEMPpchachastate[2][0] = c;
                TEMPpchachastate[3][1] = d;
            end
            
            Q7: begin
                TEMPpchachastate[0][3] = a;
                TEMPpchachastate[1][0] = b;
                TEMPpchachastate[2][1] = c;
                TEMPpchachastate[3][2] = d;
            end
        endcase
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
            S7: Nextstep = IDLE;
            default: Nextstep = IDLE;
        endcase
    end
    
    //Comb logic for moving to various Q rounds
    always_comb begin
        for (int x = 0; x < 4; x++) begin
            for (int y = 0; y < 4; y++) begin
                INITchachastate[x][y] = chachamatrixIN[x][y];
            end
        end
        
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
        endcase
    
        if (counter == 20) begin
            for (int x = 0; x < 4; x++) begin
                for (int y = 0; y < 4; y++) begin
                    chachamatrixOUT[x][y] = INITchachastate[x][y] + TEMPpchachastate[x][y];
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