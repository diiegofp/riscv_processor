# ICC2 floorplanning for RISC V

# 1. crear el diseno de la libreria (.dlib) -----------------------------------------------------------
# ocupa las reference libraries (NDM) del PDK
set pdk_path "/home/synuser17/riscv/pdk"
create_lib riscv_top.dlib \
    -technology $pdk_path/tech/saed32nm_1p9m.tf \
    -ref_libs [list \
        $pdk_path/CLIBs/saed32_hvt.ndm \
        $pdk_path/CLIBs/saed32_rvt.ndm \
        $pdk_path/CLIBs/saed32_lvt.ndm \
        $pdk_path/CLIBs/saed32_sram_lp.ndm \
    ]
# 2. lee la netlist y las restricciones -----------------------------------------------------------
read_verilog /home/synuser17/riscv/syn/top_syn.v
link_block
read_sdc /home/synuser17/riscv/syn/top.sdc

# 3. seteamos los modelos parasiticos (TLU+) -----------------------------------------------------------
# Modelos de parasiticos para estimacion de delays
# Cmax = peor caso (mas capacitancia, mas lento)
# Cmin = mejor caso (menos capacitancia, mas rapido)
read_parasitic_tech \
    -tlup $pdk_path/tech/saed32nm_1p9m_Cmax.lv.tluplus \
    -layermap $pdk_path/tech/saed32nm_tf_itf_tluplus.map \
    -name maxTLU

read_parasitic_tech \
    -tlup $pdk_path/tech/saed32nm_1p9m_Cmin.lv.tluplus \
    -layermap $pdk_path/tech/saed32nm_tf_itf_tluplus.map \
    -name minTLU


# 4. floorplan -----------------------------------------------------------
# Core utilization 0.6 (60%) — espacio para routing y buffers
# Aspect ratio 1.0 — chip cuadrado

initialize_floorplan \
    -core_utilization 0.65 \
    -core_offset {5 5 5 5}

# core_offset deja 5um de espacio alrededor del core
# para power rings

# 5. Colocacion de una Macro  -----------------------------------------------------------
# Colocar SRAMs en los bordes — dejar centro para std cells
# Instruction memory arriba a la izquierda
# Data memory abajo a la derecha
set imem [get_cells u_instr_mem/u_imem]
set dmem [get_cells u_data_mem/u_dmem]
# Reportar tamano de los macros
report_cell -physical $imem
report_cell -physical $dmem
set_attribute $imem physical_status fixed
set_attribute $dmem physical_status fixed


# 6. Red de potencia -----------------------------------------------------------
# Crear power rings alrededor del core
create_pg_ring_pattern pg_ring \
    -horizontal_layer M7 \
    -vertical_layer M8 \
    -horizontal_width 2 \
    -vertical_width 2 \
    -horizontal_spacing 1 \
    -vertical_spacing 1

set_pg_strategy ring_strategy \
    -pattern {{name: pg_ring}{nets: {VDD VSS}}} \
    -core

compile_pg -strategies ring_strategy

# Crear power stripes verticales
create_pg_std_cell_conn_pattern std_cell_pg \
    -layers {M1}

set_pg_strategy std_cell_strategy \
    -pattern {{name: std_cell_pg}{nets: {VDD VSS}}}

compile_pg -strategies std_cell_strategy

# 7. reportes
#------------------------------------------------------------
report_design -physical > /home/synuser17/riscv/pnr/floorplan.rpt
save_block -as floorplan
echo "===== FLOORPLAN COMPLETE ====="