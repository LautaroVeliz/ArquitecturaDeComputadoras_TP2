`timescale 1ns / 1ps
module uart 
    #(  // Default setting: 
        // 19,200 baud, 8 data bits , I stop bit, 2'2 FIFO 
        parameter   DBIT = 8,       // # data bits 
                    SB_TICK = 16,   // # ticks for stop bits , 
                                    // 16/24/32 for 1/1.5/2 bits 
                    DVSR = 326,     // baud rate divisor 
                                    // DVSR = 50M/(16* baud rate) Corregido a 100M
                    DVSR_BIT = 9,   // # bits of DVSR 
                    FIFO_W = 2      // # addr bits of FIFO 
                                    // # words in FIFO=2"FIFO_W 
    )
    ( 
    input wire clk, reset, rx, tx_start, 
    input wire [7:0] tx_data, 
    output wire tx_done, rx_done, tx, 
    output wire [7:0] rd_data
    ); 

    // signal declaration 
    wire tick;
    
    //body 
    baud_rate_generator #(.M(DVSR), .N(DVSR_BIT)) baud_gen_unit 
        (. clk(clk) , .reset (reset), .max_tick(tick));

    uart_rx #(.DBIT(DBIT) , .SB_TICK(SB_TICK)) uart_rx_unit 
        (.clk(clk), .reset (reset), .rx(rx), .s_tick(tick), 
        .rx_done_tick(rx_done), .dout(rd_data)); 

    uart_tx #(.DBIT(DBIT) , .SB_TICK(SB_TICK)) uart_tx_unit
        (.clk(clk), .reset(reset), .tx_start(tx_start),
        .s_tick(tick), .din(tx_data),
        .tx_done_tick(tx_done), .tx(tx));
    
endmodule