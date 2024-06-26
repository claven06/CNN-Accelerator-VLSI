
sh  mkdir -p    ./work
set cache_write work
set cache_read  work
define_design_lib WORK -path work

# Set the search and library paths
set search_path "$search_path . .. ../../lib/stdcell_lvt/db_nldm"
set_app_var target_library "saed32lvt_ss0p75vn40c.db"
set_app_var link_library "* saed32lvt_ss0p75vn40c.db"
set_min_library saed32lvt_ss0p75vn40c.db -min_version saed32lvt_ff1p16vn40c.db

# Elaborate Design
set DESIGN    "CONV_ACC"

# SVF For Formality
set_svf ../rpt/${DESIGN}_formal.svf



analyze -format verilog -vcs "-f ./filelist_synth.f"
elaborate        ${DESIGN}
current_design    ${DESIGN}

link

uniquify -force -dont_skip_empty_designs

# Operating Condition
# set_operating_conditions -analysis_type on_chip_variation
# set_wire_load_model -name smic18_wl10
# set_wire_load_mode  top

# DRC Rules
set_max_area        0
set_max_fanout        32  [get_designs $DESIGN]
set_max_transition  1.0 [get_designs $DESIGN]
set_max_capacitance 1.0 [get_designs $DESIGN]

# Constraints
set_drive    0.5000 [all_inputs]
set_load    0.0005 [all_outputs]

create_clock -name CCLK_CLK -period 3.0 [get_ports clk]

set_input_delay  0.5 -max -clock {CCLK_CLK} [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.5 -max -clock {CCLK_CLK} [all_outputs]

set_clock_uncertainty 0.0001 -setup [all_clocks]

# Check Design
check_design

redirect ../rpt/${DESIGN}_check_design.rpt "check_design"

# flatten it all, this forces all the hierarchy to be flattened out
##set_flatten true -effort high
uniquify

# Compile Design
# compile
# compile_ultra -scan -timing -retime
compile_ultra


# Write Netlist
change_names -rules verilog -hierarchy
write_file -hierarchy -format verilog -output ../rpt/${DESIGN}.syn.v
write -format ddc -hierarchy -output ../rpt/${DESIGN}_mapped.ddc
write_sdf ../rpt/CONV_ACC_time.sdf

# Reports
redirect ../rpt/${DESIGN}_timing_setup.rpt    "report_timing"
redirect ../rpt/${DESIGN}_timing_hold.rpt    "report_timing -delay_type min"
redirect ../rpt/${DESIGN}_area.rpt      "report_area -hier"
redirect ../rpt/${DESIGN}_qor.rpt       "report_qor"
redirect ../rpt/${DESIGN}_power.rpt      "report_power -groups {io_pad memory black_box clock_network register sequential combinational} -analysis_effort medium"
redirect ../rpt/${DESIGN}_clock.rpt "report_clock"
redirect ../rpt/${DESIGN}_units.rpt "report_units"
set_svf -off

exit
