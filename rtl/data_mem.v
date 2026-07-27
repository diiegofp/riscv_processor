module data_mem (
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);

    SRAMLP1RW256x32 u_dmem (
        .CE  (clk),
        .A   (addr[9:2]),
        .I   (write_data),
        .O   (read_data),
        .CSB (~(mem_read | mem_write)),
        .WEB (~mem_write),
        .OEB (~mem_read),
        .DS  (1'b0),
        .LS  (1'b0),
        .SD  (1'b0)
    );

endmodule
