#============================================================
# SYNTHESIS SCRIPT — RISC-V Pipeline
# Tool: Synopsys Design Compiler
# PDK:  SAED 32nm
#============================================================

#------------------------------------------------------------
# Step 1: Setup Libraries
#------------------------------------------------------------
set search_path "../pdk/DBs ../rtl"

set target_library "saed32hvt_ss0p75v125c.db saed32rvt_ss0p75v125c.db saed32lvt_ss0p75v125c.db"

set sram_library "saed32sramlp_ss0p75v125c_i0p75v.db"

set link_library "* $target_library $sram_library"

#------------------------------------------------------------
# Step 2: Read Design
#------------------------------------------------------------
analyze -format verilog {
    pc.v
    register_file.v
    alu.v
    alu_decoder.v
    control_unit.v
    immediate_gen.v
    branch_logic.v
    forwarding_unit.v
    hazard_unit.v
    instr_mem.v
    data_mem.v
    pipe_if_id.v
    pipe_id_ex.v
    pipe_ex_mem.v
    pipe_mem_wb.v
    top.v
}

elaborate top
current_design top
link

#------------------------------------------------------------
# Step 3: Design Constraints
#------------------------------------------------------------
create_clock -name clk -period 10 [get_ports clk]
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold  0.1 [get_clocks clk]

set_input_delay  -clock clk 2.0 [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -clock clk 2.0 [all_outputs]

set_max_area 0

# No tocar las SRAM — son macros fijos
set_dont_touch [get_cells u_instr_mem/u_imem]
set_dont_touch [get_cells u_data_mem/u_dmem]

#------------------------------------------------------------
# Step 4: Compile
#------------------------------------------------------------
compile_ultra

#------------------------------------------------------------
# Step 5: Reports
#------------------------------------------------------------
report_timing -max_paths 10 > ../syn/timing.rpt
report_area -hierarchy       > ../syn/area.rpt
report_power                 > ../syn/power.rpt
report_qor                   > ../syn/qor.rpt
report_constraint -all       > ../syn/constraints.rpt

#------------------------------------------------------------
# Step 6: Write Outputs
#------------------------------------------------------------
write -format verilog -hierarchy -output ../syn/top_syn.v
write_sdc ../syn/top.sdc
write -format ddc -hierarchy -output ../syn/top.ddc

echo "===== SYNTHESIS COMPLETE ====="
exit
