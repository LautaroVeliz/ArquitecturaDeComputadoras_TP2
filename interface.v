`timescale 1ns / 1ps

module interface
    (   
        input  wire     clk, reset,
        input  wire     rx,
        output wire     tx,
        output wire [7:0] leds
    );

    // symbolic state declaration 
    localparam [2 : 0] 
        first_op_rec        = 3'b000, 
        second_op_rec       = 3'b001,
        op_select_rec       = 3'b010,
        result_load         = 3'b011,
        tranfer_result      = 3'b100,
        flags_load          = 3'b101,
        tranfer_flags       = 3'b110,
        last_state          = 3'b111;
    
    wire tx_done, rx_done, tx_start;
    wire [7:0] tx_data, rd_data;
    
    // ALU signals
    wire [7:0]  ALU_bus;
    wire [2:0]  enables;
    wire [7:0]  result;
    wire        carry;
    wire        alu_done;
    
    // regs declaration
    // state_reg y state_next: estados actual y siguiente de la maquina de estado
    // data y data_next: valor actual a transmitir y siguiente
    reg [2:0] state_reg, state_next; 
    reg [7:0] data, data_next;
    reg [2:0] enables_reg, enables_reg_next;
    reg       tx_start_reg;
    
// FSMD state & data registers 
    always @( posedge clk , posedge reset) 
        if (reset) 
            begin 
                state_reg <= first_op_rec;
                data <= 0;
                enables_reg <= 3'b0;
            end 
        else 
            begin 
                state_reg <= state_next; 
                data <= data_next; 
                enables_reg <= enables_reg_next;
            end 
            
// FSMD next-state logic
    always @* 
    begin 
        state_next = state_reg; 
        enables_reg_next = enables_reg;
        data_next = data;
        case (state_reg) 
            first_op_rec: 
            begin 
                if(rx_done)
                begin
                    data_next = rd_data;
                    enables_reg_next = 3'b1;
                    state_next = second_op_rec;
                end
            end 
            second_op_rec: 
            begin 
                if(rx_done)
                begin
                    data_next = rd_data;
                    enables_reg_next = 3'b10;
                    state_next = op_select_rec;
                end
            end 
            op_select_rec: 
            begin 
                if(rx_done)
                begin
                    data_next = rd_data;
                    enables_reg_next = 3'b100;
                    state_next = result_load;
                end
            end 
            result_load:
            begin
                if(alu_done)
                begin
                    data_next = result;
                    enables_reg_next = 3'b0;
                    state_next = tranfer_result;
                end
            end
            tranfer_result:
            begin 
                tx_start_reg = 1'b1;
                state_next = flags_load;
            end 
            flags_load:
            begin
                if(tx_done)
                begin
                    tx_start_reg = 1'b0;
                    data_next = carry;
                    state_next = tranfer_flags;
                end
            end
            tranfer_flags:
            begin
                tx_start_reg = 1'b1;
                state_next = last_state;
            end
            last_state:
            begin 
                if(tx_done)
                begin
                    tx_start_reg = 1'b0;
                    state_next = first_op_rec;
                end
            end
        endcase 
    end
    
    uart #() uart_unit
    (.clk(clk), .reset(reset), .rx(rx), .tx_start(tx_start),
    .tx_data(tx_data), .tx_done(tx_done), .rx_done(rx_done), 
    .tx(tx), .rd_data(rd_data));
    
    ALU #() alu_unit
    (.clk(clk), .entry_bus(ALU_bus), .enables(enables), .result_bus(result), .carry(carry), .calc_done(alu_done));

    assign tx_data = data;
    assign tx_start = tx_start_reg;
    
    assign ALU_bus = data;
    assign enables = enables_reg;
    
    assign leds = {4'b0, state_reg};
endmodule
