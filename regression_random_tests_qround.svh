

//header serves to contain functions needed for blockfunction verification

//call function to reset the qround

task clear_init()
setrounds = 0;
#10;
setrounds = 1;
#10;

setrounds = 0;

endtask


task wait_blockread()

wait(blockready == 1);

$display ("TEST NO.%0d, blockready asserted and test finished",testno);


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


