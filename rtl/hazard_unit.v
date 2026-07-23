module hazard_unit (
    input  [4:0] id_rs1_addr,
    input  [4:0] id_rs2_addr,
    input  [4:0] ex_rd_addr,
    input        ex_mem_read,
    input        branch_taken,
    input        jump,
    output reg   stall,
    output reg   flush
);

    always @(*) begin
        if (ex_mem_read && ex_rd_addr != 5'b0 &&
            (ex_rd_addr == id_rs1_addr || ex_rd_addr == id_rs2_addr)) begin
            stall = 1'b1;
            flush = 1'b1;
        end
        else begin
            stall = 1'b0;
            flush = 1'b0;
        end
    end

endmodule
