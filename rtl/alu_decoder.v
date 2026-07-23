module alu_decoder (
    
    input [1:0] alu_op,
    input [2:0] func3,
    input [6:0] func7,
    output reg [3:0] alu_ctrl

    );

    always @ (*)
        case (alu_op)
            2'b00:alu_ctrl = 4'b0000;
            2'b01: alu_ctrl = 4'b0001;
            2'b10: begin
                case (func3) 
                    3'b000: begin
                        if (func7[5]) alu_ctrl = 4'b0001;
                        else alu_ctrl = 4'b0000;
                    end
                    3'b001: alu_ctrl = 4'b0110; //sll
                    3'b010: alu_ctrl = 4'b0101; //slt
                    3'b101: begin
                        if (func7[5]) alu_ctrl = 4'b1000; //sra
                        else alu_ctrl = 4'b0111; //srl
                    end
                    3'b100: alu_ctrl = 4'b0100; //xor
                    3'b110: alu_ctrl = 4'b0011; //or
                    3'b111: alu_ctrl = 4'b0010; //and
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
endmodule