module immediate_gen (

    input [31:0] instr,
    output reg [31:0] imm_out
    );

    always @ (*) 
        case (instr[6:0])
            //S-type
            7'b0100011: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]}; //20 bits signo  +  7 bits altos + 5 bits bajos = 32
            // I-type
            7'b0010011, 7'b0000011, 7'b1100111: imm_out = {{20{instr[31]}}, instr[31:20]};
            //B-type
            7'b1100011: imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // 19 bits signo + 13 bits del offset = 32
            //U-type
            7'b0110111, 7'b0010111: imm_out = {instr[31:12], 12'b0}; //20 bits del inmediato + 12 ceros = 32
            //J-type
            7'b1101111: imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; //11 bits signo + 21 bits del offset = 32
            //defecto
            default: imm_out = 32'b0;
        endcase
endmodule