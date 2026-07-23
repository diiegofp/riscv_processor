module instr_mem (
    input  [31:0] addr,
    output [31:0] instr
);

    reg [31:0] memory [0:255];

    assign instr = memory[addr[9:2]];

    initial begin
        $readmemh("program.hex", memory);
    end

endmodule
