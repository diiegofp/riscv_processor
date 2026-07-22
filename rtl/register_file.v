module register_file (

    input clk, rst_n, reg_wr,
    input [4:0] rs1_addr, rs2_addr, rd_addr, 
    input [31:0] rd_data,
    output reg [31:0] rs1_data, rs2_data
);

    reg [31:0] registers [0:31]; //32 registros de 32 bits

    always @(posedge clk) //escritura
    begin
        if (reg_wr && rd_addr) registers[rd_addr] <= rd_data;
    end

    always @(*) begin //lectura
        if (!rs1_addr) rs1_data = 0;
        else  rs1_data = registers[rs1_addr];

        if (!rs2_addr) rs2_data = 0;
        else  rs2_data = registers[rs2_addr];

        end
endmodule