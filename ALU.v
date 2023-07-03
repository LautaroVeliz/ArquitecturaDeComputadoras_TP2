module ALU #(
    parameter DATA_BUS = 8,
    parameter OP_BUS = 6
)
(
    input   wire                        clk,
    input   wire [DATA_BUS-1:0]         entry_bus,
    input   wire [2:0]                  enables,
    output  wire [DATA_BUS-1:0]         result_bus,
    output  wire                        carry,
    output  wire                        calc_done
);

localparam ADD_OP   = 6'h20;
localparam SUB_OP   = 6'h22;
localparam AND_OP   = 6'h24;
localparam OR_OP    = 6'h25;
localparam XOR_OP   = 6'h26;
localparam NOR_OP   = 6'h27;
localparam SRA_OP   = 6'h3;
localparam SRL_OP   = 6'h2;


reg [DATA_BUS-1:0]  op_A;
reg [DATA_BUS-1:0]  op_B;
reg [DATA_BUS-1:0]  op_code;
reg [DATA_BUS-1:0]  result;
reg [DATA_BUS-1:0]  result_next;
reg                 calc_done_reg;

wire [DATA_BUS:0]   tmp;


always @(posedge clk)
begin
    if (result != result_next)
    begin
        calc_done_reg <= 1'b1;
        result <= result_next;
    end
    else
        calc_done_reg = 1'b0;
    
    if (enables[0] == 1)
        op_A <= entry_bus;
    if (enables[1] == 1)
        op_B <= entry_bus;
    if (enables[2] == 1)
        begin
            op_code <= entry_bus;
    
            case(op_code)
                ADD_OP : result_next <= op_A + op_B;
                SUB_OP : result_next <= op_A - op_B;
                AND_OP : result_next <= op_A & op_B;
                OR_OP  : result_next <= op_A | op_B;
                XOR_OP : result_next <= op_A ^ op_B;
                NOR_OP : result_next <= ~(op_A | op_B);
                SRA_OP : result_next <= {op_A[DATA_BUS-1], op_A[DATA_BUS-1 : 1]};
                SRL_OP : result_next <= op_A >> 1;
                default: result_next <= {DATA_BUS{1'b0}};
            endcase
        end
end
    
assign result_bus = result;  
assign tmp = {1'b0,op_A} + {1'b0,op_B};  
assign carry = (op_code==ADD_OP) ? tmp[8] : 1'b0;
assign calc_done = calc_done_reg;

endmodule