


//takes in a plaintext from a file and store it, then outp
module Plain_Text #(parameter DATA_SIZE = 8, NUM_MATRICES = 1, NO_REG = 64 * NUM_MATRICES  )  (

input logic rst, clk, write_en, read_en, //XOR_READY goes into XOR module once storage is full and will do the  XOR op
input logic [7:0] char_in_PT,
output logic [DATA_SIZE-1:0] char_out [0:NO_REG -1],
output logic XOR_READY
 );
     
   logic [DATA_SIZE - 1: 0] Ascii_storage [0: NO_REG - 1];
   logic [$clog2(NO_REG) : 0] write_addr, read_addr;
   logic full;
   
   always_ff @(posedge clk) begin
   
   if(rst) begin
   
   write_addr <= 0;
   read_addr <= 0;
   
   for (int i = 0; i < NO_REG; i++) begin
    Ascii_storage[i] <= 0;    
   end  
   end   
             
     else if ((write_en  == 1) && read_en == 0) begin
     full<=0;
    Ascii_storage[write_addr] <= char_in_PT;
    write_addr = write_addr + 1;
         
     end
      end
      
    always_comb begin
    
    if ( (write_en  == 0) && read_en == 1) begin
        
     char_out = Ascii_storage;
        
        end
    else begin
  for (int i = 0; i< NO_REG; i++) begin

char_out[i] = '0;
end
    end  
    end  
endmodule