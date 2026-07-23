module data_mem (
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] memory [0:255];

    wire [7:0] word_addr = addr[9:2];

    assign read_data = mem_read ? memory[word_addr] : 32'b0;

    always @(posedge clk) begin
        if (mem_write)
            memory[word_addr] <= write_data;
    end

endmodule
