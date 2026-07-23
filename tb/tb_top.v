`timescale 1ns/1ps

module tb_top;

    reg clk, rst_n;
    parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;

    top dut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    wire [31:0] x0  = dut.u_regfile.registers[0];
    wire [31:0] x1  = dut.u_regfile.registers[1];
    wire [31:0] x2  = dut.u_regfile.registers[2];
    wire [31:0] x3  = dut.u_regfile.registers[3];
    wire [31:0] x4  = dut.u_regfile.registers[4];
    wire [31:0] x5  = dut.u_regfile.registers[5];
    wire [31:0] x6  = dut.u_regfile.registers[6];
    wire [31:0] x7  = dut.u_regfile.registers[7];
    wire [31:0] x8  = dut.u_regfile.registers[8];
    wire [31:0] x9  = dut.u_regfile.registers[9];
    wire [31:0] x10 = dut.u_regfile.registers[10];

    initial begin
        $fsdbDumpfile("riscv_pipe.fsdb");
        $fsdbDumpvars(0, tb_top, "+all");
    end

    integer cycle_count;
    initial cycle_count = 0;

    always @(posedge clk) begin
        cycle_count <= cycle_count + 1;
        $display("=== Cycle %0d ===", cycle_count);
        $display("  PC = 0x%08h | Instr = 0x%08h", dut.pc_out, dut.instr);
        $display("  Stall=%0b Flush=%0b BranchTaken=%0b",
                 dut.stall, dut.pipeline_flush, dut.branch_taken);
        $display("  x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d x6=%0d x7=%0d x8=%0d x9=%0d x10=%0d",
                 x1, x2, x3, x4, x5, x6, x7, x8, x9, x10);
        $display("");
    end

    integer pass, fail;

    initial begin
        clk   = 0;
        rst_n = 0;
        pass  = 0;
        fail  = 0;

        repeat (3) @(posedge clk);
        rst_n = 1;
        $display("\n========================================");
        $display("  RISC-V Pipeline Testbench Started");
        $display("========================================\n");

        repeat (30) @(posedge clk);

        $display("\n========================================");
        $display("  RESULT CHECKING");
        $display("========================================\n");

        check_reg("x1  (ADDI x1, x0, 5)",    x1,  32'd5);
        check_reg("x2  (ADDI x2, x0, 10)",   x2,  32'd10);
        check_reg("x3  (ADD  x3, x1, x2)",   x3,  32'd15);
        check_reg("x4  (SUB  x4, x3, x1)",   x4,  32'd10);
        check_reg("x5  (AND  x5, x1, x2)",   x5,  32'd0);
        check_reg("x6  (OR   x6, x1, x2)",   x6,  32'd15);
        check_reg("x7  (LW   x7, 0(x0))",    x7,  32'd15);
        check_reg("x8  (ADDI x8, x7, 1)",    x8,  32'd16);
        check_reg("x9  (skipped by BEQ)",     x9,  32'd0);
        check_reg("x10 (ADDI x10, x0, 42)",  x10, 32'd42);

        $display("\n========================================");
        $display("  SUMMARY: %0d PASSED, %0d FAILED", pass, fail);
        $display("========================================\n");

        if (fail == 0)
            $display("  >>> ALL TESTS PASSED <<<\n");
        else
            $display("  >>> SOME TESTS FAILED <<<\n");

        $finish;
    end

    task check_reg;
        input [255:0] name;
        input [31:0]  actual;
        input [31:0]  expected;
        begin
            if (actual === expected) begin
                $display("  PASS: %0s = %0d (expected %0d)", name, actual, expected);
                pass = pass + 1;
            end
            else begin
                $display("  FAIL: %0s = %0d (expected %0d)", name, actual, expected);
                fail = fail + 1;
            end
        end
    endtask

endmodule
