module program_counter (

    input clk, rst_n, stall, 
    input [31:0] pc_next,
    output reg [31:0] pc_out
);

always @(posedge clk) begin
    if (!rst_n) pc_out <= 32'b0;
    else if (stall) pc_out <= pc_out;
    else pc_out <= pc_next;
end
endmodule