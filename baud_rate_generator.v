`timescale 1ns / 1ps

module baud_rate_generator 
    #( 
        parameter   N = 4, // number of bits in counter 
                    M = 10 // mod-M 
    ) 
    ( 
        input   wire clk, reset, 
        output  wire max_tick
    ); 
    
    //signal declaration 
    reg     [N-1:0] r_reg; 
    wire    [N-1:0] r_next ; 

    // body 
    // register 
    always @ (posedge clk , posedge reset) 
        if (reset) 
            r_reg <= 0; 
        else 
            r_reg <= r_next; 
            
    // next-state logic 
    assign r_next = (r_reg==(M-1)) ? 0 : r_reg + 1; 
    // output logic
    assign max_tick = (r_reg==(M-1)) ? 1'b1 : 1'b0; 
endmodule