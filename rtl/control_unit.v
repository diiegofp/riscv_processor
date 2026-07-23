module control_unit (
    input [6:0] opcode, //categoria de instruccion
    output reg reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch, jump, //alu_src reg o imm???
    output reg [1:0] alu_op
    );

    always @(*) begin

        //defaults
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        alu_src    = 0;
        mem_to_reg = 0;
        branch     = 0;
        jump       = 0;
        alu_op = 2'b00;
        
        case (opcode)
            7'b0110011: begin // R-type (alu con registros)
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                alu_src    = 0;
                mem_to_reg = 0;
                branch     = 0;
                jump       = 0;
                alu_op = 2'b10;
            end
            7'b0010011: begin // I-type aritméticas (alu con inemdiatos)
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                alu_src    = 1;
                mem_to_reg = 0;
                branch     = 0;
                jump       = 0;
                alu_op = 2'b10;
            end
            7'b0000011: begin // LW
                reg_write  = 1;
                mem_read   = 1;
                mem_write  = 0;
                alu_src    = 1;
                mem_to_reg = 1;
                branch     = 0;
                jump       = 0;
                alu_op = 2'b00;
            end
            7'b0100011: begin // SW
                reg_write  = 0;
                mem_read   = 0;
                mem_write  = 1;
                alu_src    = 1;
                mem_to_reg = 0;
                branch     = 0;
                jump       = 0;
                alu_op = 2'b00;
            end
            7'b1100011: begin // BRANCHES
                reg_write  = 0;
                mem_read   = 0;
                mem_write  = 0;
                alu_src    = 0;
                mem_to_reg = 0;
                branch     = 1;
                jump       = 0;
                alu_op = 2'b01;
            end
            7'b1101111: begin // JAL 
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                alu_src    = 0;
                mem_to_reg = 0;
                branch     = 0;
                jump       = 1;
                alu_op = 2'b00;
            end
            7'b1100111: begin // JALR
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                alu_src    = 1;
                mem_to_reg = 0;
                branch     = 0;
                jump       = 1;
                alu_op = 2'b00;
            end
            7'b0110111: begin // LUI
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                alu_src    = 1;
                mem_to_reg = 0;
                branch     = 0;
                jump       = 0;
                alu_op = 2'b00;
            end
            7'b0010111: begin // AUIPC
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                alu_src    = 1;
                mem_to_reg = 0;
                branch     = 0;
                jump       = 0;
                alu_op = 2'b00;
            end
        endcase
    end
endmodule