module alu (

    input [31:0] alu_in1, alu_in2,
    input [3:0] alu_ctrl,
    output reg [31:0] alu_result,
    output alu_zero
    
);

    assign alu_zero = (alu_result == 32'b0);

    always @(*) begin
        case (alu_ctrl) 
            4'b0000: alu_result = alu_in1 + alu_in2;
            4'b0001: alu_result = alu_in1 - alu_in2;
            4'b0010: alu_result = alu_in1 & alu_in2;
            4'b0011: alu_result = alu_in1 | alu_in2;
            4'b0100: alu_result = alu_in1 ^ alu_in2;
            4'b0101: alu_result = ($signed(alu_in1) < $signed(alu_in2)) ? 32'd1 : 32'd0; //SLT
            4'b0110: alu_result = alu_in1 << alu_in2[4:0]; //SLL
            4'b0111: alu_result = alu_in1 >> alu_in2[4:0]; //SRL
            4'b1000: alu_result = $signed(alu_in1) >>> alu_in2[4:0]; //SRA
            default: alu_result = 32'b0;
        endcase
    end

endmodule