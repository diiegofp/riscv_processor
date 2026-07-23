module top (
    input clk,
    input rst_n
);

    wire [31:0] pc_out, pc_next, pc_plus4, instr;
    wire [31:0] branch_target;

    wire [31:0] ifid_pc, ifid_instr;

    wire [31:0] rs1_data, rs2_data, imm;
    wire        ctrl_reg_write, ctrl_mem_read, ctrl_mem_write;
    wire        ctrl_alu_src, ctrl_mem_to_reg, ctrl_branch, ctrl_jump;
    wire [1:0]  ctrl_alu_op;
    wire [3:0]  alu_ctrl;

    wire [31:0] idex_pc, idex_rs1_data, idex_rs2_data, idex_imm;
    wire [4:0]  idex_rs1_addr, idex_rs2_addr, idex_rd_addr;
    wire [2:0]  idex_funct3;
    wire [6:0]  idex_funct7;
    wire        idex_reg_write, idex_mem_read, idex_mem_write;
    wire        idex_alu_src, idex_mem_to_reg, idex_branch, idex_jump;
    wire [1:0]  idex_alu_op;

    wire [31:0] alu_result, alu_in1, alu_in2;
    wire        alu_zero;
    wire [3:0]  ex_alu_ctrl;
    wire        branch_taken;
    wire [1:0]  forward_a, forward_b;
    wire [31:0] fwd_a_data, fwd_b_data;
    wire [31:0] ex_pc_plus4;

    wire [31:0] exmem_alu_result, exmem_rs2_data, exmem_pc_plus4;
    wire [4:0]  exmem_rd_addr;
    wire        exmem_reg_write, exmem_mem_read, exmem_mem_write;
    wire        exmem_mem_to_reg, exmem_jump;

    wire [31:0] mem_read_data;

    wire [31:0] memwb_alu_result, memwb_mem_data, memwb_pc_plus4;
    wire [4:0]  memwb_rd_addr;
    wire        memwb_reg_write, memwb_mem_to_reg, memwb_jump;

    wire [31:0] wb_data;

    wire stall, hazard_flush;
    wire ifid_flush = branch_taken;           // IF/ID: solo flush por branch
    wire idex_flush = branch_taken | hazard_flush; // ID/EX: flush por branch o hazard

    // FETCH STAGE
    assign pc_plus4 = pc_out + 32'd4;
    assign pc_next = (branch_taken) ? branch_target : pc_plus4;
    assign branch_target = (idex_jump && idex_alu_src) ?
                           alu_result :
                           idex_pc + idex_imm;

    assign pipeline_flush = branch_taken | hazard_flush;

    pc u_pc (
        .clk     (clk),
        .rst_n   (rst_n),
        .stall   (stall),
        .pc_next (pc_next),
        .pc_out  (pc_out)
    );

    instr_mem u_instr_mem (
        .addr  (pc_out),
        .instr (instr)
    );

    // IF/ID PIPELINE REGISTER
    pipe_if_id u_pipe_if_id (
        .clk       (clk),
        .rst_n     (rst_n),
        .stall     (stall),
        .flush     (ifid_flush),
        .pc_in     (pc_out),
        .instr_in  (instr),
        .pc_out    (ifid_pc),
        .instr_out (ifid_instr)
    );


    // DECODE STAGE
    control_unit u_control (
        .opcode    (ifid_instr[6:0]),
        .reg_write (ctrl_reg_write),
        .mem_read  (ctrl_mem_read),
        .mem_write (ctrl_mem_write),
        .alu_src   (ctrl_alu_src),
        .mem_to_reg(ctrl_mem_to_reg),
        .branch    (ctrl_branch),
        .jump      (ctrl_jump),
        .alu_op    (ctrl_alu_op)
    );

    register_file u_regfile (
        .clk      (clk),
        .rst_n    (rst_n),
        .reg_wr   (memwb_reg_write),
        .rs1_addr (ifid_instr[19:15]),
        .rs2_addr (ifid_instr[24:20]),
        .rd_addr  (memwb_rd_addr),
        .rd_data  (wb_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    immediate_gen u_immgen (
        .instr   (ifid_instr),
        .imm_out (imm)
    );

    // ID/EX PIPELINE REGISTER
    pipe_id_ex u_pipe_id_ex (
        .clk           (clk),
        .rst_n         (rst_n),
        .flush         (idex_flush),
        .pc_in         (ifid_pc),
        .rs1_data_in   (rs1_data),
        .rs2_data_in   (rs2_data),
        .imm_in        (imm),
        .rs1_addr_in   (ifid_instr[19:15]),
        .rs2_addr_in   (ifid_instr[24:20]),
        .rd_addr_in    (ifid_instr[11:7]),
        .funct3_in     (ifid_instr[14:12]),
        .funct7_in     (ifid_instr[31:25]),
        .reg_write_in  (ctrl_reg_write),
        .mem_read_in   (ctrl_mem_read),
        .mem_write_in  (ctrl_mem_write),
        .alu_src_in    (ctrl_alu_src),
        .mem_to_reg_in (ctrl_mem_to_reg),
        .branch_in     (ctrl_branch),
        .jump_in       (ctrl_jump),
        .alu_op_in     (ctrl_alu_op),
        .pc_out        (idex_pc),
        .rs1_data_out  (idex_rs1_data),
        .rs2_data_out  (idex_rs2_data),
        .imm_out       (idex_imm),
        .rs1_addr_out  (idex_rs1_addr),
        .rs2_addr_out  (idex_rs2_addr),
        .rd_addr_out   (idex_rd_addr),
        .funct3_out    (idex_funct3),
        .funct7_out    (idex_funct7),
        .reg_write_out (idex_reg_write),
        .mem_read_out  (idex_mem_read),
        .mem_write_out (idex_mem_write),
        .alu_src_out   (idex_alu_src),
        .mem_to_reg_out(idex_mem_to_reg),
        .branch_out    (idex_branch),
        .jump_out      (idex_jump),
        .alu_op_out    (idex_alu_op)
    );


    // EXECUTE STAGE

    assign fwd_a_data = (forward_a == 2'b10) ? exmem_alu_result :
                        (forward_a == 2'b01) ? wb_data :
                        idex_rs1_data;

    assign fwd_b_data = (forward_b == 2'b10) ? exmem_alu_result :
                        (forward_b == 2'b01) ? wb_data :
                        idex_rs2_data;

    assign alu_in1 = fwd_a_data;
    assign alu_in2 = idex_alu_src ? idex_imm : fwd_b_data;
    assign ex_pc_plus4 = idex_pc + 32'd4;

    alu_decoder u_alu_dec (
        .alu_op   (idex_alu_op),
        .func3    (idex_funct3),
        .func7    (idex_funct7),
        .alu_ctrl (ex_alu_ctrl)
    );

    alu u_alu (
        .alu_in1    (alu_in1),
        .alu_in2    (alu_in2),
        .alu_ctrl   (ex_alu_ctrl),
        .alu_result (alu_result),
        .alu_zero   (alu_zero)
    );

    branch_logic u_branch (
        .rs1_data     (fwd_a_data),
        .rs2_data     (fwd_b_data),
        .funct3       (idex_funct3),
        .branch       (idex_branch),
        .jump         (idex_jump),
        .branch_taken (branch_taken)
    );

    forwarding_unit u_fwd (
        .ex_rs1_addr   (idex_rs1_addr),
        .ex_rs2_addr   (idex_rs2_addr),
        .mem_rd_addr   (exmem_rd_addr),
        .wb_rd_addr    (memwb_rd_addr),
        .mem_reg_write (exmem_reg_write),
        .wb_reg_write  (memwb_reg_write),
        .forward_a     (forward_a),
        .forward_b     (forward_b)
    );

    hazard_unit u_hazard (
        .id_rs1_addr  (ifid_instr[19:15]),
        .id_rs2_addr  (ifid_instr[24:20]),
        .ex_rd_addr   (idex_rd_addr),
        .ex_mem_read  (idex_mem_read),
        .branch_taken (branch_taken),
        .jump         (idex_jump),
        .stall        (stall),
        .flush        (hazard_flush)
    );


    // EX/MEM PIPELINE REGISTER
    pipe_ex_mem u_pipe_ex_mem (
        .clk            (clk),
        .rst_n          (rst_n),
        .alu_result_in  (alu_result),
        .rs2_data_in    (fwd_b_data),
        .pc_plus4_in    (ex_pc_plus4),
        .rd_addr_in     (idex_rd_addr),
        .reg_write_in   (idex_reg_write),
        .mem_read_in    (idex_mem_read),
        .mem_write_in   (idex_mem_write),
        .mem_to_reg_in  (idex_mem_to_reg),
        .jump_in        (idex_jump),
        .alu_result_out (exmem_alu_result),
        .rs2_data_out   (exmem_rs2_data),
        .pc_plus4_out   (exmem_pc_plus4),
        .rd_addr_out    (exmem_rd_addr),
        .reg_write_out  (exmem_reg_write),
        .mem_read_out   (exmem_mem_read),
        .mem_write_out  (exmem_mem_write),
        .mem_to_reg_out (exmem_mem_to_reg),
        .jump_out       (exmem_jump)
    );

    // MEMORY STAGE
    data_mem u_data_mem (
        .clk        (clk),
        .mem_read   (exmem_mem_read),
        .mem_write  (exmem_mem_write),
        .addr       (exmem_alu_result),
        .write_data (exmem_rs2_data),
        .read_data  (mem_read_data)
    );


    // MEM/WB PIPELINE REGISTER
    pipe_mem_wb u_pipe_mem_wb (
        .clk            (clk),
        .rst_n          (rst_n),
        .alu_result_in  (exmem_alu_result),
        .mem_data_in    (mem_read_data),
        .pc_plus4_in    (exmem_pc_plus4),
        .rd_addr_in     (exmem_rd_addr),
        .reg_write_in   (exmem_reg_write),
        .mem_to_reg_in  (exmem_mem_to_reg),
        .jump_in        (exmem_jump),
        .alu_result_out (memwb_alu_result),
        .mem_data_out   (memwb_mem_data),
        .pc_plus4_out   (memwb_pc_plus4),
        .rd_addr_out    (memwb_rd_addr),
        .reg_write_out  (memwb_reg_write),
        .mem_to_reg_out (memwb_mem_to_reg),
        .jump_out       (memwb_jump)
    );

    // WRITE BACK STAGE
    assign wb_data = memwb_jump      ? memwb_pc_plus4 :
                     memwb_mem_to_reg ? memwb_mem_data :
                     memwb_alu_result;

endmodule
