module forwarding_unit (
    input  [4:0] ex_rs1_addr,
    input  [4:0] ex_rs2_addr,
    input  [4:0] mem_rd_addr,
    input  [4:0] wb_rd_addr,
    input        mem_reg_write,
    input        wb_reg_write,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    always @(*) begin
        if (mem_reg_write && mem_rd_addr != 5'b0 && mem_rd_addr == ex_rs1_addr)
            forward_a = 2'b10;
        else if (wb_reg_write && wb_rd_addr != 5'b0 && wb_rd_addr == ex_rs1_addr)
            forward_a = 2'b01;
        else
            forward_a = 2'b00;
    end

    always @(*) begin
        if (mem_reg_write && mem_rd_addr != 5'b0 && mem_rd_addr == ex_rs2_addr)
            forward_b = 2'b10;
        else if (wb_reg_write && wb_rd_addr != 5'b0 && wb_rd_addr == ex_rs2_addr)
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end

endmodule
