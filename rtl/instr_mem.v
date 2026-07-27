module instr_mem (
    input         clk,
    input  [31:0] addr,
    output [31:0] instr
);

    SRAMLP1RW256x32 u_imem (
        .CE  (clk),
        .A   (addr[9:2]),
        .I   (32'b0),
        .O   (instr),
        .CSB (1'b0),
        .WEB (1'b1),
        .OEB (1'b0),
        .DS  (1'b0),
        .LS  (1'b0),
        .SD  (1'b0)
    );

endmodule
